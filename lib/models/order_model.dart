import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String productId;
  final String productName;
  final String customerName;
  final String phone;
  final String address;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.productId,
    required this.productName,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromMap(Map<String, dynamic> data, String id) => Order(
        id: id,
        productId: data['productId'],
        productName: data['productName'],
        customerName: data['customerName'],
        phone: data['phone'],
        address: data['address'],
        status: data['status'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'customerName': customerName,
        'phone': phone,
        'address': address,
        'status': status,
        'createdAt': createdAt,
      };
}
