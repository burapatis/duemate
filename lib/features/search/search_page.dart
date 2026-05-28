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

  @override
  Widget build(BuildContext context) {
    final results = _filteredItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหา'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
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
                              child: Text(category),
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
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text('ไม่พบรายการที่ตรงกับการค้นหา'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            child: Icon(ReminderUi.categoryIcon(item.category)),
                          ),
                          title: Text(item.title),
                          subtitle: Text(
                            '${ReminderUi.categoryEmoji(item.category)} ${item.category} • ${_formatDueLabel(item.dueDate)}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReminderDetailPage(item: item),
                              ),
                            );
                          },
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
