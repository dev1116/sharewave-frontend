import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/token_storage.dart';

class TransferService {

  // File Upload
  Future<String> uploadFile(String filePath, String receiverEmail) async {
    try {
      String? token = await TokenStorage.getToken();
      File file = File(filePath);
      int fileSize = await file.length();
      int chunkSize = 10 * 1024 * 1024; // 10MB
      int totalChunks = (fileSize / chunkSize).ceil();
      if (totalChunks == 0) totalChunks = 1;

      String? roomId;

      for (int i = 0; i < totalChunks; i++) {
        // Chunk nikalo
        int start = i * chunkSize;
        int end = (start + chunkSize > fileSize) ? fileSize : start + chunkSize;
        List<int> chunkBytes = await file.openRead(start, end).toList()
            .then((chunks) => chunks.expand((x) => x).toList());

        var request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConstants.upload),
        );

        request.headers['Authorization'] = 'Bearer $token';
        request.fields['receiverEmail'] = receiverEmail;
        request.fields['chunkIndex'] = i.toString();
        request.fields['totalChunks'] = totalChunks.toString();

        if (roomId != null) {
          request.fields['roomId'] = roomId;
        }

        request.files.add(http.MultipartFile.fromBytes(
          'chunk',
          chunkBytes,
          filename: file.path.split('/').last,
        ));

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        var data = jsonDecode(responseBody);

        if (response.statusCode == 200) {
          roomId = data['roomId'];
        } else {
          return 'Error: ${data.toString()}';
        }
      }

      return 'success';
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Received Files
  Future<List<dynamic>> getReceivedFiles() async {
    try {
      String? token = await TokenStorage.getToken();
      final response = await http.get(
        Uri.parse(ApiConstants.receivedFiles),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Download File
  Future<String> downloadFile(String roomId, String fileName) async {
    try {
      String? token = await TokenStorage.getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.download}/$roomId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // File save karo
        final dir = await getDownloadDirectory();
        final filePath = '${dir.path}/$fileName';
        File savedFile = File(filePath);
        await savedFile.writeAsBytes(response.bodyBytes);
        return filePath;
      }
      return 'Error downloading!';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<Directory> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    }
    return Directory.systemTemp;
  }
}