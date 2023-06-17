import 'dart:async';

import 'package:artistree/item_screen.dart';
import 'package:artistree/models/item.dart';
import 'package:artistree/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../alert.dart';
import '../home.dart';
import '../main.dart';

class G extends StatefulWidget {
  final Item post;
  final String x, y;
  final String mode;

  G({required this.post, required this.x, required this.y, required this.mode});

  @override
  _GState createState() => _GState();
}

class _GState extends State<G> {
  bool isCart = false;
  var format = NumberFormat.currency(locale: 'HI');
  late Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => x());
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  text() {
    return (widget.x == "item" && widget.y != "")
        ? RichText(
            text: TextSpan(
              text: widget.post.item.substring(
                  0,
                  widget.post.item
                      .toUpperCase()
                      .indexOf(widget.y.toUpperCase())),
              style: TextStyle(
                fontFamily: "Poppins-Regular",
                color: Colors.black,
                fontSize: (widget.mode == "big") ? 16.0 : 14.4,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: widget.post.item.substring(
                        widget.post.item
                            .toUpperCase()
                            .indexOf(widget.y.toUpperCase()),
                        widget.post.item
                                .toUpperCase()
                                .indexOf(widget.y.toUpperCase()) +
                            widget.y.length),
                    style: TextStyle(
                      backgroundColor: Colors.yellow,
                      fontFamily: "Poppins-Regular",
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: (widget.mode == "big") ? 16.0 : 14.4,
                    )),
                TextSpan(
                    text: widget.post.item.substring(
                        widget.post.item
                                .toUpperCase()
                                .indexOf(widget.y.toUpperCase()) +
                            widget.y.length,
                        widget.post.item.length),
                    style: TextStyle(
                      fontFamily: "Poppins-Regular",
                      color: Colors.black,
                      fontSize: (widget.mode == "big") ? 16.0 : 14.4,
                    )),
              ],
            ),
          )
        : RichText(
            text: TextSpan(
              text: widget.post.item,
              style: TextStyle(
                fontFamily: "Poppins-Regular",
                color: Colors.black,
                fontSize: (widget.mode == "big") ? 16.0 : 14.4,
              ),
              children: const <TextSpan>[],
            ),
          );
  }

  text1() {
    return (widget.x == "seller" && widget.y != "")
        ? RichText(
            text: TextSpan(
              text:
                  "Sold by ${widget.post.seller.substring(0, widget.post.seller.toUpperCase().indexOf(widget.y.toUpperCase()))}",
              style: TextStyle(
                  fontFamily: "Poppins-Regular",
                  fontSize: (widget.mode == "big") ? 13.0 : 11.7,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[700]),
              children: <TextSpan>[
                TextSpan(
                    text: widget.post.seller.substring(
                        widget.post.seller
                            .toUpperCase()
                            .indexOf(widget.y.toUpperCase()),
                        widget.post.seller
                                .toUpperCase()
                                .indexOf(widget.y.toUpperCase()) +
                            widget.y.length),
                    style: TextStyle(
                        backgroundColor: Colors.yellow,
                        fontFamily: "Poppins-Regular",
                        fontSize: (widget.mode == "big") ? 13.0 : 11.7,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700])),
                TextSpan(
                    text: widget.post.seller.substring(
                        widget.post.seller
                                .toUpperCase()
                                .indexOf(widget.y.toUpperCase()) +
                            widget.y.length,
                        widget.post.seller.length),
                    style: TextStyle(
                        fontFamily: "Poppins-Regular",
                        fontSize: (widget.mode == "big") ? 13.0 : 11.7,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[700])),
              ],
            ),
          )
        : RichText(
            text: TextSpan(
              text: "Sold by ${widget.post.seller}",
              style: TextStyle(
                  fontFamily: "Poppins-Regular",
                  fontSize: (widget.mode == "big") ? 13.0 : 11.7,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[700]),
              children: const <TextSpan>[],
            ),
          );
  }

  x() {
    setState(() {
      for (String element in currentUser.cart) {
        if (element.contains(widget.post.postId)) {
          isCart = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
            color: _getColorFromHex("#f0f4ff"),
            child: Column(
              children: [
                AspectRatio(
                    aspectRatio: 1 / 1,
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: widget.post.mediaUrl,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )),
                Padding(
                    padding: const EdgeInsets.all(2),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          (widget.x != "NAN" && widget.y != "NAN")
                              ? text()
                              : Text(
                                  widget.post.item,
                                  style: TextStyle(
                                      fontFamily: "Poppins-Regular",
                                      fontSize:
                                          (widget.mode == "big") ? 16.0 : 14.4,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                ),
                          (currentUser.id == sEller)
                              ? const Text("")
                              : (isCart)
                                  ? GestureDetector(
                                      child: const Icon(
                                        Icons.favorite,
                                        color: Colors.black,
                                      ),
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              Future.delayed(
                                                  const Duration(seconds: 1),
                                                  () async {
                                                for (String element
                                                    in currentUser.cart) {
                                                  if (element.contains(
                                                      widget.post.postId)) {
                                                    currentUser.cart
                                                        .remove(element);
                                                    break;
                                                  }
                                                }

                                                usersRef
                                                    .doc(currentUser.id)
                                                    .update({
                                                  "cart": currentUser.cart
                                                });

                                                DocumentSnapshot doc =
                                                    await usersRef
                                                        .doc(currentUser.id)
                                                        .get();

                                                setState(() {
                                                  currentUser =
                                                      UserX.fromDocument(doc);
                                                });

                                                print(currentUser.cart.length);

                                                await analytics.logEvent(
                                                  name: "removed_to_cart",
                                                  parameters: {
                                                    "button_clicked": "true",
                                                    "email": currentUser.email,
                                                    "displayName":
                                                        currentUser.displayName,
                                                    "id": currentUser.id,
                                                    "item_name":
                                                        widget.post.item,
                                                    "item_id":
                                                        widget.post.postId,
                                                    "timestamp": DateTime.now()
                                                        .toString(),
                                                  },
                                                );

                                                setState(() {
                                                  isCart = false;
                                                });
                                                // ignore: use_build_context_synchronously
                                                Navigator.of(context).pop(true);

                                                notify(
                                                    "New Alert for ${currentUser.displayName}",
                                                    "${widget.post.item} removed from cart");
                                              });
                                              return AlertDialog(
                                                backgroundColor: Colors.white,
                                                title: const Text(
                                                    "Removing from Cart",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontFamily:
                                                            "Poppins-Regular",
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black)),
                                                content: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 10.0),
                                                  child:
                                                      const LinearProgressIndicator(
                                                    minHeight: 5,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                            Colors.black),
                                                  ),
                                                ),
                                              );
                                            });
                                      })
                                  : GestureDetector(
                                      child: const Icon(
                                        Icons.favorite_border,
                                        color: Colors.black,
                                      ),
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              Future.delayed(
                                                  const Duration(seconds: 1),
                                                  () async {
                                                currentUser.cart.add(
                                                    "${widget.post.postId}*.*1");

                                                usersRef
                                                    .doc(currentUser.id)
                                                    .update({
                                                  "cart": currentUser.cart
                                                });

                                                DocumentSnapshot doc =
                                                    await usersRef
                                                        .doc(currentUser.id)
                                                        .get();

                                                setState(() {
                                                  currentUser =
                                                      UserX.fromDocument(doc);
                                                });

                                                print(currentUser.cart.length);

                                                await analytics.logEvent(
                                                  name: "added_to_cart",
                                                  parameters: {
                                                    "button_clicked": "true",
                                                    "email": currentUser.email,
                                                    "displayName":
                                                        currentUser.displayName,
                                                    "id": currentUser.id,
                                                    "item_name":
                                                        widget.post.item,
                                                    "item_id":
                                                        widget.post.postId,
                                                    "timestamp": DateTime.now()
                                                        .toString(),
                                                  },
                                                );

                                                setState(() {
                                                  isCart = true;
                                                });
                                                // ignore: use_build_context_synchronously
                                                Navigator.of(context).pop(true);

                                                notify(
                                                    "New Alert for ${currentUser.displayName}",
                                                    "${widget.post.item} added to cart");
                                              });
                                              return AlertDialog(
                                                backgroundColor: Colors.white,
                                                title: const Text(
                                                    "Adding to Cart",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontFamily:
                                                            "Poppins-Regular",
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black)),
                                                content: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 10.0),
                                                  child:
                                                      const LinearProgressIndicator(
                                                    minHeight: 5,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                            Colors.black),
                                                  ),
                                                ),
                                              );
                                            });
                                      })
                        ])),
                Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          (widget.x != "NAN" && widget.y != "NAN")
                              ? text1()
                              : Text(
                                  "Sold by ${widget.post.seller}",
                                  style: TextStyle(
                                      fontFamily: "Poppins-Regular",
                                      fontSize:
                                          (widget.mode == "big") ? 13.0 : 11.7,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey[700]),
                                ),
                        ])),
                Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "₹ ${format.format(int.parse(widget.post.cash)).substring(3, format.format(int.parse(widget.post.cash)).length - 3)}",
                            style: TextStyle(
                                fontFamily: "Poppins-Bold",
                                fontSize: (widget.mode == "big") ? 16.0 : 14.4,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                        ])),
              ],
            )),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostScreenX(
                postId: widget.post.postId,
              ),
            ),
          );
        });
  }
}

_getColorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";

    return Color(int.parse("0x$hexColor"));
  }

  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }
}
