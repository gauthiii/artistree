import 'package:cloud_firestore/cloud_firestore.dart';

class OrderData {
  final String orderId;
  final String postId;
  final String item;
  final String mediaUrl;
  final String userId;
  final String cus;
  final String cost;
  final String tax;
  final String dis;
  final String status;
  final int quantity;
  final List<dynamic> cnotif;
  final List<dynamic> anotif;
  final Timestamp timestamp;

  OrderData(
      {required this.orderId,
      required this.postId,
      required this.item,
      required this.mediaUrl,
      required this.userId,
      required this.cost,
      required this.tax,
      required this.dis,
      required this.cus,
      required this.status,
      required this.quantity,
      required this.cnotif,
      required this.anotif,
      required this.timestamp});

  factory OrderData.fromDocument(DocumentSnapshot doc) {
    return OrderData(
        orderId: doc['orderId'],
        postId: doc['postId'],
        item: doc['item'],
        mediaUrl: doc['mediaUrl'],
        userId: doc['userId'],
        cost: doc['cost'],
        tax: doc['tax'],
        dis: doc['dis'],
        cus: doc['cus'],
        cnotif: doc['cnotif'],
        anotif: doc['anotif'],
        status: doc['status'],
        quantity: doc['quantity'],
        timestamp: doc['timestamp']);
  }
}
