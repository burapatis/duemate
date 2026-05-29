import 'package:flutter/material.dart';

import '../home/reminder_item.dart';
import '../home/reminder_ui.dart';

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

    // ส่งค่ากลับหน้า Home เพื่ออัปเดตรายการแบบ in-memory ใน v0.1.0
    final item = ReminderItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: _selectedCategory,
      dueDate: _dueDate!,
      reminderDays: _selectedReminderDays.toList()..sort(),
      note: _noteController.text.trim(),
      priority: _selectedCategory == 'งาน/ราชการ' || _selectedCategory == 'รถ'
          ? 'สูง'
          : 'กลาง',
    );

    Navigator.of(context).pop(item);
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
        title: const Text('➕ เพิ่มรายการ'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(ReminderUi.pagePadding),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(ReminderUi.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝 ข้อมูลหลัก',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
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
                              child: Text(ReminderUi.categoryLabel(category)),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: ReminderUi.sectionGap),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(ReminderUi.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔔 ตั้งค่าเตือนล่วงหน้า',
                      style: Theme.of(context).textTheme.titleMedium,
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: ReminderUi.sectionGap),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(ReminderUi.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📌 หมายเหตุ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: ReminderUi.sectionGap),
                    TextFormField(
                      controller: _noteController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'รายละเอียดเพิ่มเติม (ถ้ามี)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: ReminderUi.blockGap),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saveSample,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('บันทึก'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
