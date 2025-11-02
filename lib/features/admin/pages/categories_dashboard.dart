import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesDashboard extends StatefulWidget {
  const CategoriesDashboard({super.key});

  @override
  State<CategoriesDashboard> createState() => _CategoriesDashboardState();
}

class _CategoriesDashboardState extends State<CategoriesDashboard> {
  final _firestore = FirebaseFirestore.instance;
  final _nameCtrl = TextEditingController();

  Future<void> _addCategory([String? id, String? currentName]) async {
    _nameCtrl.text = currentName ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == null ? "Add Category" : "Edit Category"),
        content: TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: "Category Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC1E79),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final name = _nameCtrl.text.trim();
              if (name.isEmpty) return;

              if (id == null) {
                await _firestore.collection('categories').add({'name': name});
              } else {
                await _firestore
                    .collection('categories')
                    .doc(id)
                    .update({'name': name});
              }
              if (mounted) Navigator.pop(context);
            },
            child: Text(id == null ? "Add" : "Update"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Category"),
        content: const Text("Are you sure you want to delete this category?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('categories').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B3B3B),
        title: const Text("Categories Management",
            style: TextStyle(color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEC1E79),
        onPressed: () => _addCategory(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('categories').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child:
                    CircularProgressIndicator(color: Color(0xFFEC1E79)));
          }

          final categories = snapshot.data!.docs;

          if (categories.isEmpty) {
            return const Center(
              child: Text("No categories yet",
                  style: TextStyle(color: Color(0xFF3B3B3B))),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final doc = categories[i];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'];

              return Card(
                elevation: 2,
                child: ListTile(
                  title: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () =>
                            _addCategory(doc.id, data['name']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteCategory(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
