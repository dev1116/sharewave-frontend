import 'package:flutter/material.dart';
import 'package:sharewave/feature/transfer/screen/receive_screen.dart';
import 'package:sharewave/feature/transfer/screen/send_screen.dart'; // ← Yeh fix karo
import '../../auth/screen/login_screen.dart';
import '../../../core/storage/token_storage.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'ShareWave',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        actions: [
          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await TokenStorage.clearToken();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            const Icon(Icons.waves, size: 100, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'ShareWave',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Text(
              'Fast P2P File Transfer',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 60),

            // Send Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SendScreen()),
                ),
                icon: const Icon(Icons.upload, size: 28),
                label: const Text('Send File', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Receive Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton.icon(
               onPressed: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const ReceiveScreen()),
),
                icon: const Icon(Icons.download, size: 28),
                label: const Text(
                  'Receive File',
                  style: TextStyle(fontSize: 18),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
