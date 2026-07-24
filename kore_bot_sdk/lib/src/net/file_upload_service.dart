import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import '../config/bot_config.dart';
import 'http_client_factory.dart';

class UploadedAttachment {
  const UploadedAttachment({
    required this.fileName,
    required this.fileType,
    required this.fileId,
    required this.fileExtn,
    this.thumbnailURL,
    this.localFilePath,
  });

  final String fileName;
  final String fileType;
  final String fileId;
  final String fileExtn;
  final String? thumbnailURL;
  final String? localFilePath;

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'fileType': fileType,
        'fileId': fileId,
        'fileExtn': fileExtn,
        if (thumbnailURL != null) 'thumbnailURL': thumbnailURL,
        if (localFilePath != null) 'localFilePath': localFilePath,
      };
}

/// Kore file upload: token → chunk(s) → merge → fileId (then send on WS).
class FileUploadService {
  FileUploadService(this.config, {http.Client? httpClient})
      : _http = httpClient ??
            createBotHttpClient(
              allowBadCertificates: config.allowBadCertificates,
            );

  final BotConfig config;
  final http.Client _http;

  static const int chunkSize = 1024 * 1024; // 1 MB

  Future<UploadedAttachment> upload({
    required String accessToken,
    required String botUserId,
    required String fileName,
    required Uint8List bytes,
    String? localPath,
    String? mimeType,
  }) async {
    final auth = 'bearer $accessToken';
    final ext = p.extension(fileName).replaceFirst('.', '');
    final fileType = _fileTypeFor(ext, mimeType);

    final fileToken = await _fetchToken(auth);
    final totalChunks = max(1, (bytes.length / chunkSize).ceil());

    for (var i = 0; i < totalChunks; i++) {
      final start = i * chunkSize;
      final end = min(bytes.length, start + chunkSize);
      await _uploadChunk(
        auth: auth,
        botUserId: botUserId,
        fileToken: fileToken,
        fileName: fileName,
        chunkNo: i,
        chunk: bytes.sublist(start, end),
      );
    }

    final merge = await _merge(
      auth: auth,
      botUserId: botUserId,
      fileToken: fileToken,
      fileName: fileName,
      fileExtn: ext.isEmpty ? 'bin' : ext,
      totalChunks: totalChunks,
    );

    return UploadedAttachment(
      fileName: fileName,
      fileType: fileType,
      fileId: merge['fileId'] as String,
      fileExtn: ext.isEmpty ? 'bin' : ext,
      thumbnailURL: merge['thumbnailURL'] as String?,
      localFilePath: localPath,
    );
  }

  Future<String> _fetchToken(String auth) async {
    final uri = Uri.parse('${config.normalizedServerUrl}/api/1.1/attachment/file/token');
    final response = await _http.post(uri, headers: {'Authorization': auth});
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('File token failed (${response.statusCode}): ${response.body}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final token = body['fileToken'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('File token missing in response');
    }
    return token;
  }

  Future<void> _uploadChunk({
    required String auth,
    required String botUserId,
    required String fileToken,
    required String fileName,
    required int chunkNo,
    required List<int> chunk,
  }) async {
    final uri = Uri.parse(
      '${config.normalizedServerUrl}/api/1.1/users/$botUserId/file/$fileToken/chunk',
    );
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = auth;
    request.fields['chunkNo'] = '$chunkNo';
    request.fields['fileToken'] = fileToken;
    request.files.add(
      http.MultipartFile.fromBytes(
        'chunk',
        chunk,
        filename: fileName,
        contentType: MediaType('application', 'octet-stream'),
      ),
    );
    final streamed = await _http.send(request);
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception('Chunk upload failed (${streamed.statusCode}): $body');
    }
  }

  Future<Map<String, dynamic>> _merge({
    required String auth,
    required String botUserId,
    required String fileToken,
    required String fileName,
    required String fileExtn,
    required int totalChunks,
  }) async {
    final uri = Uri.parse(
      '${config.normalizedServerUrl}/api/1.1/users/$botUserId/file/$fileToken',
    );
    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = auth;
    request.fields['totalChunks'] = '$totalChunks';
    request.fields['fileExtension'] = fileExtn;
    request.fields['fileToken'] = fileToken;
    request.fields['filename'] = fileName;
    request.fields['fileContext'] = 'workflows';
    request.fields['thumbnailUpload'] = 'false';

    final streamed = await _http.send(request);
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception('Merge failed (${streamed.statusCode}): $body');
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    if (json['fileId'] == null) {
      throw Exception('Merge response missing fileId');
    }
    return json;
  }

  /// Matches SPM `uploadAttachment` fileType mapping.
  String _fileTypeFor(String ext, String? mime) {
    final lower = ext.toLowerCase();
    final m = (mime ?? '').toLowerCase();
    if (m.startsWith('image/') ||
        {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'}.contains(lower)) {
      return 'image';
    }
    if (m.startsWith('video/') ||
        {'mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v'}.contains(lower)) {
      return 'video';
    }
    if (lower == 'pdf') return 'pdf';
    if (lower == 'mp3' || m == 'audio/mpeg') return 'mp3';
    if (m.startsWith('audio/') ||
        {'wav', 'aac', 'm4a', 'ogg'}.contains(lower)) {
      return 'audio';
    }
    return 'attachment';
  }
}

/// SPM-style outbound body: optional caption + emoji + file name.
String buildAttachmentMessageBody({
  required String fileName,
  required String fileType,
  String caption = '',
}) {
  final emoji = switch (fileType) {
    'image' => '\u{1F4F7}', // 📷
    'video' => '🎥',
    'pdf' => '📄',
    'mp3' => '🎵',
    'audio' => '🎵',
    _ => '📁',
  };
  final line = '\n $emoji $fileName';
  final trimmed = caption.trim();
  if (trimmed.isEmpty) return line;
  return '$trimmed$line';
}
