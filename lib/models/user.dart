import 'package:cloud_firestore/cloud_firestore.dart';

class UserX {
  final List<dynamic> cart;
  final String id;
  final String sellerId;
  final String email;
  final String mobile;
  final String displayName;
  final String door;
  final String street;
  final String locality;
  final String city;
  final String zip;
  final Timestamp timestamp;

  UserX(
      {required this.cart,
      required this.id,
      required this.sellerId,
      required this.email,
      required this.mobile,
      required this.displayName,
      required this.door,
      required this.street,
      required this.locality,
      required this.city,
      required this.zip,
      required this.timestamp});

  factory UserX.fromDocument(DocumentSnapshot doc) {
    return UserX(
        cart: doc['cart'],
        id: doc['id'],
        sellerId: doc['sellerId'],
        email: doc['email'],
        mobile: doc['mobile'],
        displayName: doc['displayName'],
        door: doc['door'],
        street: doc['street'],
        locality: doc['locality'],
        city: doc['city'],
        zip: doc['zip'],
        timestamp: doc['timestamp']);
  }
}
