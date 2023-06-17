import 'package:cloud_firestore/cloud_firestore.dart';

class Feed {
  final String orderId;
  final String feedId;
  final String notifId;
  final String status;
  final String mediaUrl;

  final String cus;

  final Timestamp timestamp;

  Feed(
      {required this.orderId,
      required this.status,
      required this.feedId,
      required this.notifId,
      required this.mediaUrl,
      required this.cus,
      required this.timestamp});

  factory Feed.fromDocument(DocumentSnapshot doc) {
    return Feed(
        orderId: doc['orderId'],
        notifId: doc['notifId'],
        feedId: doc['feedId'],
        mediaUrl: doc['mediaUrl'],
        cus: doc['cus'],
        timestamp: doc['timestamp'],
        status: doc['status']);
  }
}
