import 'package:flutter/material.dart';

import '../../theme/app_brand_colors.dart';
import '../home/reminder_item.dart';
import '../home/reminder_ui.dart';
import 'reminder_templates.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key, this.editItem, this.copyFrom});

  /// ถ้ามีค่า = โหมดแก้ไขรายการเดิม (ใช้ id เดิมตอนบันทึก)
  final ReminderItem? editItem;

  /// คัดลอกจากรายการเดิม — สร้างรายการใหม่ (id ใหม่ตอนบันทึก)
  final ReminderItem? copyFrom;

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  static List<String> get _categories => ReminderUi.documentCategories;

  static const _reminderOptions = <int>[30, 15, 7, 1];
  static const _defaultAddReminderDays = <int>[7];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final Set<int> _selectedReminderDays = {};

  String _selectedCategory = _categories.first;
  DateTime? _dueDate;
  bool _isHandlingBack = false;
  String _selectedTemplateId = ReminderTemplate.custom.id;

  bool get _isEditing => widget.editItem != null;
  bool get _isCopying => widget.copyFrom != null && !_isEditing;

  /// โหมด Edit เท่านั้น — เปรียบเทียบฟอร์มกับค่าเดิม
  bool get _hasUnsavedChanges {
    if (!_isEditing) return false;

    final original = widget.editItem!;
    if (_titleController.text.trim() != original.title) return true;
    if (_noteController.text.trim() != original.note) return true;
    if (_selectedCategory != original.category) return true;
    if (!_isSameCalendarDay(_dueDate, original.dueDate)) return true;
    if (!_isSameReminderDays(_selectedReminderDays, original.reminderDays)) {
      return true;
    }
    return false;
  }

  /// โหมด Add — มีข้อมูลที่กรอกแล้วแต่ยังไม่บันทึก
  bool get _hasUnsavedAddDraft {
    if (_isEditing) return false;

    if (_titleController.text.trim().isNotEmpty) return true;
    if (_noteController.text.trim().isNotEmpty) return true;
    if (_selectedCategory != ReminderUi.documentCategories.first) return true;
    if (_dueDate != null) return true;
    if (!_isSameReminderDays(_selectedReminderDays, _defaultAddReminderDays)) {
      return true;
    }
    return false;
  }

  bool get _shouldConfirmBeforePop =>
      _isEditing ? _hasUnsavedChanges : _hasUnsavedAddDraft;

  bool _isSameCalendarDay(DateTime? date, DateTime original) {
    if (date == null) return false;
    return date.year == original.year &&
        date.month == original.month &&
        date.day == original.day;
  }

  bool _isSameReminderDays(Set<int> current, List<int> original) {
    if (current.length != original.length) return false;
    return current.containsAll(original);
  }

  Future<bool?> _confirmDiscardChanges() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('ยังไม่ได้บันทึกการแก้ไข'),
          content: const Text(
            'ถ้ากลับตอนนี้ ข้อมูลที่แก้ไขจะไม่ถูกบันทึก',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('กลับไปแก้ต่อ'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('ออกโดยไม่บันทึก'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _confirmDiscardAddDraft() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('ยังไม่ได้บันทึกรายการ'),
          content: const Text(
            'ถ้ากลับตอนนี้ ข้อมูลที่กรอกไว้จะไม่ถูกบันทึก',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('กลับไปกรอกต่อ'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('ออกโดยไม่บันทึก'),
            ),
          ],
        );
      },
    );
  }

  /// ปุ่มกลับ AppBar และ system back — เตือนเมื่อ Add/Edit มีข้อมูลที่ยังไม่บันทึก
  Future<void> _handleBack() async {
    if (_isHandlingBack) return;
    _isHandlingBack = true;

    try {
      if (!_shouldConfirmBeforePop) {
        if (!mounted) return;
        Navigator.of(context).pop();
        return;
      }

      final shouldDiscard = _isEditing
          ? await _confirmDiscardChanges()
          : await _confirmDiscardAddDraft();
      if (shouldDiscard == true && mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        _isHandlingBack = false;
      }
    }
  }

  void _applyTemplate(ReminderTemplate template) {
    setState(() {
      _selectedTemplateId = template.id;
      if (template.id == ReminderTemplate.custom.id) return;

      if (template.titleSuggestion.isNotEmpty) {
        _titleController.text = template.titleSuggestion;
      }
      _selectedCategory = template.category;
      _selectedReminderDays
        ..clear()
        ..addAll(template.reminderDays);
    });
  }

  void _prefillFromItem(ReminderItem source, {bool forCopy = false}) {
    _titleController.text = forCopy
        ? '${source.title} (สำเนา)'
        : source.title;
    _noteController.text = source.note;
    _selectedCategory = source.category;
    if (!forCopy) {
      _dueDate = source.dueDate;
    }
    _selectedReminderDays
      ..clear()
      ..addAll(source.reminderDays);
  }

  @override
  void initState() {
    super.initState();
    final editItem = widget.editItem;
    final copyFrom = widget.copyFrom;

    if (editItem != null) {
      _prefillFromItem(editItem);
      return;
    }

    if (copyFrom != null) {
      _prefillFromItem(copyFrom, forCopy: true);
      return;
    }

    _selectedReminderDays.add(7);
  }

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

  Future<bool?> _confirmSaveWithoutReminder() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('ยังไม่ได้เลือกการแจ้งเตือน'),
          content: const Text(
            'รายการนี้จะถูกบันทึกไว้ แต่แอปจะไม่ตั้งแจ้งเตือนล่วงหน้า',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('กลับไปเลือกเตือน'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('บันทึกโดยไม่เตือน'),
            ),
          ],
        );
      },
    );
  }

  /// บันทึกและส่ง ReminderItem กลับ parent
  void _performSave() {
    final item = ReminderItem(
      id: _isEditing
          ? widget.editItem!.id
          : DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: _selectedCategory,
      dueDate: _dueDate!,
      reminderDays: _selectedReminderDays.toList()..sort(),
      note: _noteController.text.trim(),
      priority: ReminderUi.isHighPriorityCategory(_selectedCategory)
          ? 'สูง'
          : 'กลาง',
      isCompleted: _isEditing ? widget.editItem!.isCompleted : false,
    );

    Navigator.of(context).pop(item);
  }

  Future<void> _saveSample() async {
    // validate เฉพาะข้อมูลสำคัญในขั้นนี้ ก่อนจะไปเชื่อมฐานข้อมูลจริงในอนาคต
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกวันครบกำหนด')),
      );
      return;
    }

    if (_selectedReminderDays.isEmpty) {
      final shouldSave = await _confirmSaveWithoutReminder();
      if (shouldSave != true || !mounted) return;
    }

    _performSave();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year + 543;
    return '$day/$month/$year';
  }

  TextStyle _sectionTitleStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return theme.textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.w700,
      color: isLight
          ? const Color(0xFF1B1B2F)
          : theme.colorScheme.onSurface,
    );
  }

  TextStyle _chipLabelStyle(BuildContext context, {required bool selected}) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return TextStyle(
      fontFamily: 'Sarabun',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: selected
          ? Colors.white
          : (isLight
              ? const Color(0xFF1B1B2F)
              : theme.colorScheme.onSurface),
    );
  }

  TextStyle _hintTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: 0.75,
              ),
          fontWeight: FontWeight.w500,
        );
  }

  InputDecoration _fieldDecoration({
    required String labelText,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: labelText,
      helperText: helperText,
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldLabelColor = Theme.of(context).colorScheme.onSurface;
    return PopScope(
      canPop: !_shouldConfirmBeforePop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
      appBar: AppBar(
        // macOS: AppBar back แบบ default อาจไม่รับ tap — ใช้ leading ชัดเจน
        automaticallyImplyLeading: false,
        leading: ReminderUi.backButton(onPressed: _handleBack),
        title: Text(
          _isEditing
              ? 'แก้ไขรายการ'
              : _isCopying
                  ? 'คัดลอกรายการ'
                  : 'เพิ่มรายการ',
        ),
      ),
      body: TapRegion(
        // ปิด keyboard เมื่อแตะนอกช่องกรอก — ไม่แย่ง tap จาก TextField (Android)
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(ReminderUi.pagePadding),
            children: [
            if (!_isEditing) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(ReminderUi.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เลือกแม่แบบ (ถ้ามี)',
                        style: _sectionTitleStyle(context),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ReminderTemplate.presets.map((template) {
                          final selected =
                              _selectedTemplateId == template.id;
                          final theme = Theme.of(context);
                          final isLight =
                              theme.brightness == Brightness.light;
                          return ChoiceChip(
                            label: Text(
                              '${template.emoji} ${template.label}',
                              style: _chipLabelStyle(
                                context,
                                selected: selected,
                              ),
                            ),
                            selected: selected,
                            showCheckmark: false,
                            selectedColor: AppBrandColors.primaryBlue,
                            backgroundColor: isLight
                                ? const Color(0xFFF3F5F9)
                                : theme.colorScheme.surfaceContainerHighest,
                            side: BorderSide(
                              color: selected
                                  ? AppBrandColors.primaryBlue
                                  : (isLight
                                      ? const Color(0xFFB0BEC5)
                                      : theme.colorScheme.outline),
                            ),
                            onSelected: (_) => _applyTemplate(template),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: ReminderUi.sectionGap),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(ReminderUi.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝 ข้อมูลหลัก',
                      style: _sectionTitleStyle(context),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const ValueKey('reminder_title_field'),
                      controller: _titleController,
                      style: TextStyle(
                        color: fieldLabelColor,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _fieldDecoration(labelText: 'ชื่อรายการ'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกชื่อรายการ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: const ValueKey('reminder_category_field'),
                      initialValue: _categories.contains(_selectedCategory)
                          ? _selectedCategory
                          : ReminderUi.documentCategories.last,
                      decoration: _fieldDecoration(
                        labelText: 'หมวดเอกสาร',
                        helperText:
                            'เลือกหมวดที่ใกล้เคียงที่สุด — ไม่ต้องพิมพ์เอง',
                      ),
                      items: _categories
                          .map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                ReminderUi.categoryLabel(category),
                                style: TextStyle(
                                  color: fieldLabelColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
                      style: OutlinedButton.styleFrom(
                        foregroundColor: fieldLabelColor,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      label: Text(
                        _dueDate == null
                            ? 'เลือกวันครบกำหนด'
                            : 'วันครบกำหนด: ${_formatDate(_dueDate!)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
                      style: _sectionTitleStyle(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'เลือกอย่างน้อย 1 รายการ หากต้องการให้แอปแจ้งเตือน',
                      style: _hintTextStyle(context),
                    ),
                    const SizedBox(height: 8),
                    // เลือกได้หลายค่าเพื่อรองรับการแจ้งเตือนหลายช่วงเวลา
                    ..._reminderOptions.map((days) {
                      return CheckboxListTile(
                        value: _selectedReminderDays.contains(days),
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '$days วัน',
                          style: TextStyle(
                            color: fieldLabelColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                      style: _sectionTitleStyle(context),
                    ),
                    const SizedBox(height: ReminderUi.sectionGap),
                    TextFormField(
                      key: const ValueKey('reminder_note_field'),
                      controller: _noteController,
                      minLines: 3,
                      maxLines: 5,
                      style: TextStyle(
                        color: fieldLabelColor,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _fieldDecoration(
                        labelText: 'รายละเอียดเพิ่มเติม (ถ้ามี)',
                      ).copyWith(alignLabelWithHint: true),
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
      ),
    ),
    );
  }
}
