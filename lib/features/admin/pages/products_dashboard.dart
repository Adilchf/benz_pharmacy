import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy_benz/features/admin/pages/categories_dashboard.dart';
import '../../../models/product_model.dart';
import 'orders_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductsDashboard extends StatefulWidget {
  const ProductsDashboard({super.key});

  @override
  State<ProductsDashboard> createState() => _ProductsDashboardState();
}

class _ProductsDashboardState extends State<ProductsDashboard> {
  final _firestore = FirebaseFirestore.instance;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  void _addOrEditProduct([Product? product]) {
    final _formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: product?.name);
    final descCtrl = TextEditingController(text: product?.description);
    final priceCtrl = TextEditingController(text: product != null ? '${product.price}' : '');
    final imageCtrl = TextEditingController(text: product?.imageUrl);

    // Available categories
    final categories = ["Skin Care", "Hair Care", "Health", "Makeup", "Vitamins", "Fragrances"];

    String selectedCategory = product?.category ?? categories.first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          product == null ? "Add New Product" : "Edit Product",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B3B3B),
          ),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name"),
                  validator: (v) => v == null || v.isEmpty ? "Enter product name" : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty ? "Enter description" : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price"),
                  validator: (v) => v == null || v.isEmpty ? "Enter price" : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: imageCtrl,
                  decoration: const InputDecoration(labelText: "Image URL (from Unsplash, Cloudinary, etc.)"),
                  validator: (v) => v == null || v.isEmpty ? "Enter image URL" : null,
                ),
                const SizedBox(height: 8),
                // 🟩 Category dropdown
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: "Category"),
                  dropdownColor: Colors.white,
                  items: categories
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) selectedCategory = val;
                  },
                ),
                const SizedBox(height: 10),
                if (imageCtrl.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(imageCtrl.text, height: 100, fit: BoxFit.cover),
                    ),
                  ),
              ],
            ),
          ),
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
              if (!_formKey.currentState!.validate()) return;

              final data = {
                'name': nameCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'price': double.tryParse(priceCtrl.text) ?? 0,
                'imageUrl': imageCtrl.text.trim(),
                'category': selectedCategory, // ✅ Save category
              };

              if (product == null) {
                await _firestore.collection('products').add(data);
              } else {
                await _firestore.collection('products').doc(product.id).update(data);
              }
              if (mounted) Navigator.pop(context);
            },
            child: Text(product == null ? "Add Product" : "Update Product"),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Products"),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OrdersDashboard(),
              ),
            ),
            child: const Text("Orders", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoriesDashboard(),
              ),
            ),
            child: const Text("Categories", style: TextStyle(color: Colors.white)),
          ),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () => _addOrEditProduct(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final products = snapshot.data!.docs.map((d) => Product.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final p = products[i];
              return ListTile(
                leading: Image.network(p.imageUrl, width: 50, fit: BoxFit.cover),
                title: Text(p.name),
                subtitle: Text("\$${p.price}"),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _addOrEditProduct(p)),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteProduct(p.id)),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
