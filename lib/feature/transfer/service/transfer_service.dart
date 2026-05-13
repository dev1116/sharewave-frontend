import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import 'package:sharewave/core/constants/api_constants.dart';
import 'package:sharewave/core/storage/token_storage.dart';


class TransferService {

  // Mobile ke liye file upload
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
        int start = i * chunkSize;
        int end = (start + chunkSize > fileSize) ? fileSize : start + chunkSize;
        List<int> chunkBytes = await file
            .openRead(start, end)
            .toList()
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

  // Browser ke liye file upload
  Future<String> uploadFileWeb(
      Uint8List fileBytes, String fileName, String receiverEmail) async {
    try {
      String? token = await TokenStorage.getToken();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.upload),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['receiverEmail'] = receiverEmail;
      request.fields['chunkIndex'] = '0';
      request.fields['totalChunks'] = '1';

      request.files.add(http.MultipartFile.fromBytes(
        'chunk',
        fileBytes,
        filename: fileName,
      ));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return 'success';
      }
      return 'Error: $responseBody';
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
        if (!Platform.isAndroid && !Platform.isIOS) {
          // Browser ke liye
          return 'downloaded';
        }
        // Mobile ke liye
        final dir = Directory('/storage/emulated/0/Download');
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

  // Browser ke liye download
Future<String> downloadFileWeb(String roomId, String fileName) async {
  try {
    String? token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.download}/$roomId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // Browser mein automatic download
      final blob = html.Blob([response.bodyBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      // anchor variable directly use karo

      final anchor = html.AnchorElement(href: url)
  ..setAttribute('download', fileName)
  ..click();
      html.Url.revokeObjectUrl(url);
      return 'Downloaded: $fileName ✅';
    }
    return 'Error downloading!';
  } catch (e) {
    return 'Error: $e';
  }
}
}