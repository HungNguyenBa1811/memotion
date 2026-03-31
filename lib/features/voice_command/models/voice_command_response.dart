class VoiceCommandResponse {
  const VoiceCommandResponse({
    required this.code,
    required this.message,
    this.audio,
    required this.key,
    this.transcript,
  });

  final int code;
  final String message;
  final String? audio;
  final String key;
  final String? transcript;

  factory VoiceCommandResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = data is Map<String, dynamic> ? data : <String, dynamic>{};

    final rawCode = json['code'];
    final parsedCode = switch (rawCode) {
      final int value => value,
      _ => int.tryParse(rawCode?.toString() ?? '') ?? 0,
    };

    return VoiceCommandResponse(
      code: parsedCode,
      message: json['message']?.toString() ?? '',
      audio: dataMap['audio']?.toString(),
      key: dataMap['key']?.toString() ?? 'UNKNOWN',
      transcript: dataMap['transcript']?.toString(),
    );
  }
}
