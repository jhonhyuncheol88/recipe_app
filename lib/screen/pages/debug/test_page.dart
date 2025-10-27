import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Page'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '✅ Test Page Loaded',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Button A'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Button B'),
            ),
          ],
        ),
      ),
    );
  }
}
