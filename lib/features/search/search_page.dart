import 'package:flutter/material.dart';

import '../home/reminder_detail_page.dart';
import '../home/reminder_item.dart';
import '../home/reminder_ui.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.items});

  final List<ReminderItem> items;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const _categories = <String>[
    'ทั้งหมด',
    'รถ',
    'ส่วนตัว',
    'บ้าน',
    'ครอบครัว',
    'สินค้า/รับประกัน',
    'งาน/ราชการ',
    'อื่น ๆ',
  ];

  final _searchController = TextEditingController();
  String _selectedCategory = _categories.first;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ReminderItem> _filteredItems() {
    final query = _searchController.text.trim().toLowerCase();

    // กรองจากชื่อรายการเป็นหลัก และใช้หมวดเป็นเงื่อนไขร่วม
    return widget.items.where((item) {
      final matchesName = query.isEmpty || item.title.toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == 'ทั้งหมด' || item.category == _selectedCategory;
      return matchesName && matchesCategory;
    }).toList();
  }

  String _formatDueLabel(DateTime dueDate) {
    final day = dueDate.day.toString().padLeft(2, '0');
    final month = dueDate.month.toString().padLeft(2, '0');
    final year = dueDate.year + 543;
    return 'ครบกำหนด $day/$month/$year';
  }

  Future<void> _openDetail(BuildContext context, ReminderItem item) async {
    final result = await Navigator.of(context).push<Object>(
      MaterialPageRoute(
        builder: (_) => ReminderDetailPage(item: item),
      ),
    );

    // ส่งผลแก้ไข/ลบกลับ Home เพื่ออัปเดตรายการหลัก
    if (result != null && context.mounted) {
      Navigator.of(context).pop(result);
    }
  }

  String _resultCountLabel(int count) {
    if (count == 0) return 'ไม่พบรายการ';
    return 'พบ $count รายการ';
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredItems();
    final mutedStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔎 ค้นหาเอกสาร'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ReminderUi.pagePadding,
              ReminderUi.pagePadding,
              ReminderUi.pagePadding,
              ReminderUi.sectionGap,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(ReminderUi.cardPadding),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'ค้นหาด้วยชื่อรายการ',
                        hintText: 'เช่น ใบขับขี่, พ.ร.บ. รถยนต์',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'กรองหมวด',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(ReminderUi.filterCategoryLabel(category)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ReminderUi.pagePadding,
              0,
              ReminderUi.pagePadding,
              ReminderUi.sectionGap,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_resultCountLabel(results.length), style: mutedStyle),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const _SearchEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      ReminderUi.pagePadding,
                      4,
                      ReminderUi.pagePadding,
                      ReminderUi.pagePadding,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return Card(
                        key: ValueKey(item.id),
                        margin: const EdgeInsets.only(bottom: ReminderUi.sectionGap),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          title: Text(item.title),
                          subtitle: Text(
                            '${ReminderUi.categoryLabel(item.category)} • ${_formatDueLabel(item.dueDate)}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openDetail(context, item),
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

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    final mutedStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ReminderUi.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'ไม่พบรายการที่ตรงกับการค้นหา',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ลองเปลี่ยนคำค้นหา หรือเลือกหมวดทั้งหมด',
              style: mutedStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
