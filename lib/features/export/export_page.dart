import 'package:flutter/material.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ส่งออก'),
      ),
      body: const Center(
        child: Text('ส่งออกรายการ'),
      ),
    );
  }
}
