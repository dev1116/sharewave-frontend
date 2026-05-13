import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:sharewave/feature/transfer/service/transfer_service.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final _transferService = TransferService();
  List<dynamic> _files = [];
  bool _isLoading = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _loadFiles(); // Screen khulte hi files load karo
  }

  void _loadFiles() async {
    setState(() => _isLoading = true);

    final files = await _transferService.getReceivedFiles();

    setState(() {
      _files = files;
      _isLoading = false;
      if (files.isEmpty) _status = 'Koi file nahi mili!';
    });
  }

  void _downloadFile(String roomId, String fileName) async {
    setState(() => _status = 'Downloading $fileName...');

    final result = await _transferService.downloadFileWeb(roomId, fileName);

    setState(() => _status = result);
  }

  String _formatSize(dynamic size) {
    if (size == null) return 'Unknown';
    double bytes = double.parse(size.toString());
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Files'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _status.isEmpty ? 'Koi file nahi mili!' : _status,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (_status.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        color: Colors.blue.shade50,
                        child: Text(
                          _status,
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _files.length,
                        itemBuilder: (context, index) {
                          final file = _files[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(
                                Icons.insert_drive_file,
                                color: Colors.blue,
                                size: 40,
                              ),
                              title: Text(
                                file['fileName'] ?? 'Unknown',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Size: ${_formatSize(file['fileSize'])}'),
                                  Text('From: ${file['senderEmail'] ?? ''}'),
                                  Text('Status: ${file['status'] ?? ''}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.download,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _downloadFile(
                                  file['roomId'],
                                  file['fileName'],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}