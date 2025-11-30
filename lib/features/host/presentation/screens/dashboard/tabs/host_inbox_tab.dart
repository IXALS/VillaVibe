import 'package:flutter/material.dart';

class HostInboxTab extends StatelessWidget {
  const HostInboxTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Host Dashboard - Inbox'),
      ),
    );
  }
}
