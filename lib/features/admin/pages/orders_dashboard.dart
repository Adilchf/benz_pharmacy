import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrdersDashboard extends StatelessWidget {
  const OrdersDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text("Admin - Orders")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('orders').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!.docs;
          if (orders.isEmpty) return const Center(child: Text("No orders yet"));

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final order = orders[i].data() as Map<String, dynamic>;
              final id = orders[i].id;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(order['productName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Customer: ${order['customerName']}"),
                      Text("Phone: ${order['phone']}"),
                      Text("Address: ${order['address']}"),
                      Text("Status: ${order['status']}"),
                      const SizedBox(height: 6),
                      ElevatedButton(
                        onPressed: () async {
                          final newStatus = order['status'] == 'pending'
                              ? 'confirmed'
                              : order['status'] == 'confirmed'
                                  ? 'delivered'
                                  : 'pending';
                          await _firestore.collection('orders').doc(id).update({'status': newStatus});
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            foregroundColor: Colors.white),
                        child: const Text("Change Status"),
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
