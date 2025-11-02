import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import 'order_form_page.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B3B3B),
        title: Text(product.name, style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(product.imageUrl,
                  width: double.infinity, height: 300, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            Text(product.name,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B3B3B))),
            const SizedBox(height: 8),
            Text("\$${product.price}",
                style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFFEC1E79),
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(product.description,
                style: const TextStyle(
                    fontSize: 16, color: Color(0xFF3B3B3B), height: 1.5)),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7AC943),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => OrderFormPage(product: product))),
                child: const Text("Order Now",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
