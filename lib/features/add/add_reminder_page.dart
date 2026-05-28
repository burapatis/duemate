import 'package:flutter/material.dart';

class AddReminderPage extends StatelessWidget {
  const AddReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มรายการ'),
      ),
      body: const Center(
        child: Text('เพิ่มรายการใหม่'),
      ),
    );
  }
}
