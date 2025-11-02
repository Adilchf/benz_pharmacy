import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/product_model.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = "All";
  List<String> _categories = ["All"];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    final allCats = snapshot.docs
        .map((d) => (d.data() as Map<String, dynamic>)['category'] ?? '')
        .where((c) => c.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    setState(() {
      _categories = ["All", ...allCats];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount =
        screenWidth > 900 ? 4 : screenWidth > 600 ? 3 : 2;
    final aspectRatio = screenWidth > 600 ? 1.1 : 0.9;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B3B3B),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/benz_logo.jpg', height: 36),
            const SizedBox(width: 8),
            const Text(
              "BENZ PHARM",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white),
            ),
          ],
        ),
      ),
      drawer: screenWidth < 800
          ? Drawer(
              backgroundColor: const Color(0xFF3B3B3B),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: _categories
                    .map(
                      (cat) => ListTile(
                        title: Text(cat,
                            style: TextStyle(
                              color: _selectedCategory == cat
                                  ? const Color(0xFF7AC943)
                                  : Colors.white,
                              fontWeight: _selectedCategory == cat
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            )),
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
              ),
            )
          : null,
      body: Row(
        children: [
          // ─────────── SIDEBAR ───────────
          if (screenWidth >= 800)
            Container(
              width: 200,
              color: const Color(0xFF3B3B3B),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: _categories
                    .map(
                      (cat) => ListTile(
                        title: Text(cat,
                            style: TextStyle(
                              color: _selectedCategory == cat
                                  ? const Color(0xFF7AC943)
                                  : Colors.white,
                              fontWeight: _selectedCategory == cat
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            )),
                        onTap: () =>
                            setState(() => _selectedCategory = cat),
                      ),
                    )
                    .toList(),
              ),
            ),

          // ─────────── PRODUCT GRID ───────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFEC1E79)));
                }

                final allProducts = snapshot.data!.docs
                    .map((d) => Product.fromMap(
                        d.data() as Map<String, dynamic>, d.id))
                    .toList();

                final products = _selectedCategory == "All"
                    ? allProducts
                    : allProducts
                        .where((p) =>
                            p.category?.toLowerCase() ==
                            _selectedCategory.toLowerCase())
                        .toList();

                if (products.isEmpty) {
                  return Center(
                      child: Text(
                    "No products in $_selectedCategory yet",
                    style: const TextStyle(
                        color: Color(0xFF3B3B3B), fontSize: 16),
                  ));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, i) {
                    final p = products[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailPage(product: p))),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                              child: Image.network(
                                p.imageUrl,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Color(0xFF3B3B3B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "\$${p.price}",
                                    style: const TextStyle(
                                      color: Color(0xFFEC1E79),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
