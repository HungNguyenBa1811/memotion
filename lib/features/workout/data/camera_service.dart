/// Camera Service for Pose Detection
/// 
/// Handles camera initialization, frame capture, and streaming
/// Optimized for real-time pose detection at 30fps
/// 
/// Author: MEMOTION Team
/// Version: 1.0.0

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

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
  int _frameCount = 0;

  // Frame streaming
  Timer? _frameTimer;
  void Function(Uint8List frameBytes, int timestamp)? _onFrame;

  // Configuration
  static const int targetFps = 30;
  static const int frameIntervalMs = 1000 ~/ targetFps;
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
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Find front or back camera
      final camera = _cameras!.firstWhere(
        (c) => c.lensDirection == 
          (useFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
        orElse: () => _cameras!.first,
      );

      CameraLogger.info('Using camera: ${camera.name} (${camera.lensDirection})');

      // Create controller
      _controller = CameraController(
        camera,
        resolution,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Initialize
      await _controller!.initialize();
      _isInitialized = true;

      CameraLogger.info('Camera initialized successfully');
    } catch (e) {
      CameraLogger.error('Failed to initialize camera', e);
      _isInitialized = false;
      rethrow;
    }
  }

  /// Start streaming frames
  /// [onFrame] callback receives JPEG bytes and timestamp
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

    CameraLogger.info('Starting frame streaming at ${targetFps}fps');

    _onFrame = onFrame;
    _frameCount = 0;
    _isStreaming = true;

    // Use timer for consistent frame rate
    _frameTimer = Timer.periodic(
      Duration(milliseconds: frameIntervalMs),
      (_) => _captureAndSendFrame(),
    );
  }

  /// Stop streaming
  Future<void> stopStreaming() async {
    CameraLogger.info('Stopping frame streaming');
    
    _frameTimer?.cancel();
    _frameTimer = null;
    _isStreaming = false;
    _onFrame = null;

    CameraLogger.info('Stopped after $_frameCount frames');
  }

  /// Capture a single frame
  Future<Uint8List?> captureFrame() async {
    if (!_isInitialized || _controller == null) {
      return null;
    }

    try {
      final XFile image = await _controller!.takePicture();
      return await image.readAsBytes();
    } catch (e) {
      CameraLogger.error('Failed to capture frame', e);
      return null;
    }
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

  // ==================== PRIVATE METHODS ====================

  void _captureAndSendFrame() async {
    if (!_isStreaming || _onFrame == null) return;

    try {
      final bytes = await captureFrame();
      if (bytes != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _onFrame!(bytes, timestamp);
        _frameCount++;

        // Log every second
        if (_frameCount % targetFps == 0) {
          CameraLogger.info('Captured frame #$_frameCount');
        }
      }
    } catch (e) {
      // Don't spam logs for capture errors
      if (_frameCount % 30 == 0) {
        CameraLogger.error('Frame capture error', e);
      }
    }
  }
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
