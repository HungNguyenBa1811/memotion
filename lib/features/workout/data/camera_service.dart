/// Camera Service for Pose Detection
///
/// Handles camera initialization and real-time frame streaming
/// Uses startImageStream() + persistent isolate for 30fps JPEG encoding
///
/// Author: MEMOTION Team
/// Version: 3.0.0

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Logger for camera operations
class CameraLogger {
  static const String _tag = '📷 Camera';

  static void info(String message) {
    developer.log('[$_tag] $message');
  }

  static void error(String message, [Object? error]) {
    developer.log('[$_tag][ERROR] $message', error: error);
  }
}

/// Camera service for real-time frame capture
class CameraService {
  // Singleton
  static CameraService? _instance;
  static CameraService get instance {
    _instance ??= CameraService._();
    return _instance!;
  }

  CameraService._();

  // Camera controller
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isStreaming = false;
  bool _isProcessing = false;
  int _frameCount = 0;

  // Frame streaming callback
  void Function(Uint8List frameBytes, int timestamp)? _onFrame;

  // Persistent encoder isolate
  Isolate? _encoderIsolate;
  SendPort? _encoderSendPort;
  ReceivePort? _encoderReceivePort;

  // Configuration
  static const int targetFps = 30;
  static const int _jpegQuality = 80;
  static const ResolutionPreset resolution = ResolutionPreset.medium;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isStreaming => _isStreaming;
  CameraController? get controller => _controller;
  int get frameCount => _frameCount;

  /// Initialize camera
  Future<void> initialize({bool useFrontCamera = true}) async {
    CameraLogger.info('Initializing camera...');

    try {
      // Dispose previous controller if any to prevent camera leak
      if (_controller != null) {
        CameraLogger.info('Disposing previous camera controller before re-init');
        await stopStreaming();
        await _controller!.dispose();
        _controller = null;
        _isInitialized = false;
      }

      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Find front or back camera
      final camera = _cameras!.firstWhere(
        (c) => c.lensDirection ==
            (useFrontCamera
                ? CameraLensDirection.front
                : CameraLensDirection.back),
        orElse: () => _cameras!.first,
      );

      CameraLogger.info(
          'Using camera: ${camera.name} (${camera.lensDirection})');

      // Create controller — YUV420 for startImageStream, low res for speed
      _controller = CameraController(
        camera,
        resolution,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      _isInitialized = true;

      CameraLogger.info('Camera initialized (${resolution.name})');
    } catch (e) {
      CameraLogger.error('Failed to initialize camera', e);
      _isInitialized = false;
      rethrow;
    }
  }

  /// Start streaming frames using startImageStream + persistent isolate
  Future<void> startStreaming({
    required void Function(Uint8List frameBytes, int timestamp) onFrame,
  }) async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    if (_isStreaming) {
      CameraLogger.info('Already streaming');
      return;
    }

    CameraLogger.info('Starting image stream (target ~${targetFps}fps)');

    _onFrame = onFrame;
    _frameCount = 0;
    _isStreaming = true;

    // Spawn persistent encoder isolate
    await _spawnEncoderIsolate();

    _controller!.startImageStream(_onImageAvailable);
  }

  /// Stop streaming
  Future<void> stopStreaming() async {
    CameraLogger.info('Stopping frame streaming');

    _isStreaming = false;
    _onFrame = null;

    try {
      if (_controller != null &&
          _controller!.value.isInitialized &&
          _controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
    } catch (e) {
      CameraLogger.error('Error stopping image stream', e);
    }

    _killEncoderIsolate();

    CameraLogger.info('Stopped after $_frameCount frames');
  }

  /// Dispose camera resources
  Future<void> dispose() async {
    await stopStreaming();
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _instance = null;
    CameraLogger.info('Camera disposed');
  }

  // ==================== PERSISTENT ISOLATE ====================

  /// Spawn a long-lived isolate for JPEG encoding
  Future<void> _spawnEncoderIsolate() async {
    _killEncoderIsolate(); // Clean up any existing one

    _encoderReceivePort = ReceivePort();

    _encoderIsolate = await Isolate.spawn(
      _encoderEntryPoint,
      _encoderReceivePort!.sendPort,
    );

    final completer = Completer<SendPort>();

    _encoderReceivePort!.listen((message) {
      if (message is SendPort) {
        // First message: isolate's SendPort for us to send frames to
        completer.complete(message);
      } else if (message is Uint8List) {
        // Encoded JPEG bytes received back
        _onEncodedFrame(message);
      }
    });

    _encoderSendPort = await completer.future;
    CameraLogger.info('Encoder isolate spawned');
  }

  /// Kill the encoder isolate
  void _killEncoderIsolate() {
    _encoderIsolate?.kill(priority: Isolate.immediate);
    _encoderIsolate = null;
    _encoderSendPort = null;
    _encoderReceivePort?.close();
    _encoderReceivePort = null;
  }

  /// Handle encoded JPEG frame from isolate
  void _onEncodedFrame(Uint8List jpegBytes) {
    _isProcessing = false;

    if (!_isStreaming || _onFrame == null) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _onFrame!(jpegBytes, timestamp);
    _frameCount++;

    if (_frameCount <= 5 || _frameCount % 60 == 0) {
      debugPrint(
          '📸 [CAM] Captured & sent frame #$_frameCount (${jpegBytes.length} bytes)');
    }
  }



  // ==================== FRAME HANDLING ====================

  /// Called for every preview frame from the camera (~30fps from hardware)
  void _onImageAvailable(CameraImage cameraImage) {
    if (!_isStreaming || _onFrame == null) return;

    // Skip if previous frame is still being encoded
    if (_isProcessing) return;
    if (_encoderSendPort == null) return;

    _isProcessing = true;

    // Copy plane bytes and send to persistent isolate for YUV→RGB→JPEG
    final planes = cameraImage.planes;
    final sensorOrientation = _controller!.description.sensorOrientation;
    final isFrontCamera =
        _controller!.description.lensDirection == CameraLensDirection.front;

    _encoderSendPort!.send(_FramePayload(
      yBytes: Uint8List.fromList(planes[0].bytes),
      yRowStride: planes[0].bytesPerRow,
      uBytes: planes.length > 1 ? Uint8List.fromList(planes[1].bytes) : null,
      uRowStride: planes.length > 1 ? planes[1].bytesPerRow : 0,
      uPixelStride: planes.length > 1 ? planes[1].bytesPerPixel ?? 1 : 1,
      vBytes: planes.length > 2 ? Uint8List.fromList(planes[2].bytes) : null,
      vRowStride: planes.length > 2 ? planes[2].bytesPerRow : 0,
      vPixelStride: planes.length > 2 ? planes[2].bytesPerPixel ?? 1 : 1,
      width: cameraImage.width,
      height: cameraImage.height,
      sensorOrientation: sensorOrientation,
      isFrontCamera: isFrontCamera,
    ));
  }

  // ==================== ISOLATE ENTRY POINT ====================

  /// Encoder isolate main loop — receives frame data, sends back JPEG
  static void _encoderEntryPoint(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message is _FramePayload) {
        final jpeg = _encodeFrameToJpeg(message);
        if (jpeg != null) {
          mainSendPort.send(jpeg);
        }
      }
    });
  }

  /// Convert YUV420 to RGB JPEG with rotation — runs in encoder isolate
  static Uint8List? _encodeFrameToJpeg(_FramePayload payload) {
    try {
      final width = payload.width;
      final height = payload.height;
      final yBytes = payload.yBytes;
      final uBytes = payload.uBytes;
      final vBytes = payload.vBytes;
      final yRowStride = payload.yRowStride;
      final uvRowStride = payload.uRowStride;
      final uPixelStride = payload.uPixelStride;
      final vPixelStride = payload.vPixelStride;

      var image = img.Image(width: width, height: height);

      for (int y = 0; y < height; y++) {
        final yRowOffset = y * yRowStride;
        final uvRowOffset = (y >> 1) * uvRowStride;

        for (int x = 0; x < width; x++) {
          final yValue = yBytes[yRowOffset + x];
          // Account for pixel stride (1 for planar I420, 2 for semi-planar NV12/NV21)
          final uvOffset = uvRowOffset + (x >> 1) * uPixelStride;
          final uValue = uBytes != null ? uBytes[uvOffset] : 128;
          final vvOffset = uvRowOffset + (x >> 1) * vPixelStride;
          final vValue = vBytes != null ? vBytes[vvOffset] : 128;

          final c = yValue - 16;
          final d = uValue - 128;
          final e = vValue - 128;

          int r = ((298 * c + 409 * e + 128) >> 8).clamp(0, 255);
          int g = ((298 * c - 100 * d - 208 * e + 128) >> 8).clamp(0, 255);
          int b = ((298 * c + 516 * d + 128) >> 8).clamp(0, 255);

          image.setPixelRgb(x, y, r, g, b);
        }
      }

      // Rotate to upright orientation (sensor is mounted sideways on phones)
      if (payload.sensorOrientation != 0) {
        image = img.copyRotate(image, angle: payload.sensorOrientation);
      }

      return Uint8List.fromList(img.encodeJpg(image, quality: _jpegQuality));
    } catch (e) {
      return null;
    }
  }
}

/// Full YUV420 frame payload sent to isolate
class _FramePayload {
  final Uint8List yBytes;
  final int yRowStride;
  final Uint8List? uBytes;
  final int uRowStride;
  final int uPixelStride;
  final Uint8List? vBytes;
  final int vRowStride;
  final int vPixelStride;
  final int width;
  final int height;
  final int sensorOrientation;
  final bool isFrontCamera;

  _FramePayload({
    required this.yBytes,
    required this.yRowStride,
    this.uBytes,
    this.uRowStride = 0,
    this.uPixelStride = 1,
    this.vBytes,
    this.vRowStride = 0,
    this.vPixelStride = 1,
    required this.width,
    required this.height,
    this.sensorOrientation = 0,
    this.isFrontCamera = false,
  });
}

/// Camera preview widget provider for Riverpod
class CameraPreviewData {
  final CameraController? controller;
  final bool isInitialized;
  final String? error;

  const CameraPreviewData({
    this.controller,
    this.isInitialized = false,
    this.error,
  });
}
