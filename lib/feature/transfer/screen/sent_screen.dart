import 'package:flutter/material.dart';
import 'package:sharewave/feature/transfer/service/transfer_service.dart';

class SentScreen extends StatefulWidget {
  const SentScreen({super.key});

  @override
  State<SentScreen> createState() => _SentScreenState();
}

class _SentScreenState extends State<SentScreen> {
  final _transferService = TransferService();
  List<dynamic> _files = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  void _loadFiles() async {
    setState(() => _isLoading = true);
    final files = await _transferService.getSentFiles();
    setState(() {
      _files = files;
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DOWNLOADED':
        return Colors.green;
      case 'DONE':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'DOWNLOADED':
        return Icons.check_circle;
      case 'DONE':
        return Icons.cloud_done;
      case 'PENDING':
        return Icons.pending;
      default:
        return Icons.info;
    }
  }

  String _formatSize(dynamic size) {
    if (size == null) return 'Unknown';
    double bytes = double.parse(size.toString());
    if (bytes < 1024 * 1024)
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sent Files'),
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
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No files sent yet!',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    final status = file['status'] ?? 'PENDING';
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
                          style:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Size: ${_formatSize(file['fileSize'])}'),
                            Text('To: ${file['otherPartyEmail'] ?? ''}'),
                            Row(
                              children: [
                                Icon(
                                  _getStatusIcon(status),
                                  size: 14,
                                  color: _getStatusColor(status),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  status == 'DOWNLOADED'
                                      ? 'Downloaded ✅'
                                      : status,
                                  style: TextStyle(
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}