import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String cash;
  final String description;
  final String item;
  final String mediaUrl;
  final String postId;
  final String seller;
  final String category;
  final String link;
  final bool isBought;
  final Timestamp timestamp;

  Item(
      {required this.cash,
      required this.description,
      required this.item,
      required this.mediaUrl,
      required this.postId,
      required this.link,
      required this.category,
      required this.isBought,
      required this.seller,
      required this.timestamp});

  factory Item.fromDocument(DocumentSnapshot doc) {
    return Item(
        cash: doc['cash'],
        description: doc['description'],
        item: doc['item'],
        mediaUrl: doc['mediaUrl'],
        postId: doc['postId'],
        category: doc['category'],
        link: doc['link'],
        isBought: doc['isBought'],
        seller: doc['seller'],
        timestamp: doc['timestamp']);
  }
}
