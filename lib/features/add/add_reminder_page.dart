import 'package:flutter/material.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  static const _categories = <String>[
    'รถ',
    'ส่วนตัว',
    'บ้าน',
    'ครอบครัว',
    'สินค้า/รับประกัน',
    'งาน/ราชการ',
    'อื่น ๆ',
  ];

  static const _reminderOptions = <int>[30, 15, 7, 1];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final Set<int> _selectedReminderDays = {};

  String _selectedCategory = _categories.first;
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 20),
      helpText: 'เลือกวันครบกำหนด',
      cancelText: 'ยกเลิก',
      confirmText: 'ตกลง',
    );

    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  void _saveSample() {
    // validate เฉพาะข้อมูลสำคัญในขั้นนี้ ก่อนจะไปเชื่อมฐานข้อมูลจริงในอนาคต
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกวันครบกำหนด')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกตัวอย่างแล้ว — ขั้นนี้ยังไม่เก็บข้อมูลถาวร'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year + 543;
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มรายการ'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'ชื่อรายการ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกชื่อรายการ';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'หมวด',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  })
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDueDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _dueDate == null
                    ? 'เลือกวันครบกำหนด'
                    : 'วันครบกำหนด: ${_formatDate(_dueDate!)}',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'เตือนล่วงหน้า',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            // เลือกได้หลายค่าเพื่อรองรับการแจ้งเตือนหลายช่วงเวลา
            ..._reminderOptions.map((days) {
              return CheckboxListTile(
                value: _selectedReminderDays.contains(days),
                contentPadding: EdgeInsets.zero,
                title: Text('$days วัน'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (isChecked) {
                  setState(() {
                    if (isChecked ?? false) {
                      _selectedReminderDays.add(days);
                    } else {
                      _selectedReminderDays.remove(days);
                    }
                  });
                },
              );
            }),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'หมายเหตุ',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saveSample,
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }
}
