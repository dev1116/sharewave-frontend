import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:sharewave/feature/transfer/service/transfer_service.dart';


class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

 // ← Yeh add karo
class _SendScreenState extends State<SendScreen> {
  final _emailController = TextEditingController();
  final _transferService = TransferService();
  
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isLoading = false;
  String _status = '';
  Uint8List? _selectedFileBytes;

  // File pick karo

void _pickFile() {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '*/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoad.listen((event) {
          setState(() {
            _selectedFileName = file.name;
            _selectedFileBytes = reader.result as Uint8List;
            _status = 'File selected: ${file.name}';
          });
        });
      }
    });
}

  // Upload karo
void _upload() async {
    if (_selectedFileBytes == null && _selectedFilePath == null) {
      setState(() => _status = 'Pehle file select karo!');
      return;
    }
    if (_emailController.text.isEmpty) {
      setState(() => _status = 'Receiver email daalo!');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Uploading...';
    });

    String result;

    // Browser ke liye bytes use karo
    if (_selectedFileBytes != null) {
      result = await _transferService.uploadFileWeb(
        _selectedFileBytes!,
        _selectedFileName!,
        _emailController.text.trim(),
      );
    } else {
      result = await _transferService.uploadFile(
        _selectedFilePath!,
        _emailController.text.trim(),
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _status = result == 'success'
          ? 'File uploaded successfully! 🎉'
          : result;
    });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send File'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File Select
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.shade50,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_file,
                        size: 50, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFileName ?? 'Tap to select file',
                      style: const TextStyle(color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Receiver Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Receiver Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),

            // Status
            if (_status.isNotEmpty)
              Text(
                _status,
                style: TextStyle(
                  color: _status.contains('success')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            const SizedBox(height: 16),

            // Upload Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _upload,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isLoading ? 'Uploading...' : 'Send File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}