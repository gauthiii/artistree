import 'package:artistree/models/item.dart';
import 'package:artistree/place_order.dart';
import 'package:artistree/progress.dart';
import 'package:artistree/zoom.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import './home.dart';
import 'alert.dart';
import 'models/user.dart';
import 'dart:math' as math;

class PostScreenX extends StatefulWidget {
  final String postId;

  PostScreenX({required this.postId});

  @override
  PostScreen1 createState() => PostScreen1();
}

class PostScreen1 extends State<PostScreenX> {
  var format = NumberFormat.currency(locale: 'HI');
  List<String> f = [];
  int t = 1;
  bool isCart = false;

  late Item post;
  @override
  void initState() {
    super.initState();
    x();
  }

  x() {
    setState(() {
      for (String element in currentUser.cart) {
        if (element.contains(widget.postId)) {
          isCart = true;
        }
      }
    });
  }

  place() async {
    String orderId = const Uuid().v4();
    DateTime tq = DateTime.now();
    oRders.doc(orderId).set({
      "orderId": orderId,
      "postId": post.postId,
      "item": post.item,
      "mediaUrl": post.mediaUrl,
      "userId": currentUser.id,
      "cost": (int.parse(post.cash) * t).toString(),
      "status": "Placed",
      "quantity": t,
      "timestamp": tq,
    });

    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Placing Order!!!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            content: Container(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: const LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            ),
          );
        });

    showDialog(
        context: context,
        builder: (_) => const AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Order Placed!!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              // content:  Text("You gotta follow atleast one user to see the timeline.Find some users to follow.Don't be a loner dude!!!!",style:TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white)),
            ));
  }

  late int cost;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: postsRef
            .doc(currentUser.sellerId)
            .collection('userPosts')
            .doc(widget.postId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                backgroundColor: _getColorFromHex("#f0f4ff"),
                body: circularProgress());
          }
          post = Item.fromDocument(snapshot.data as DocumentSnapshot<Object?>);
          cost = int.parse(post.cash);
          return Scaffold(
            backgroundColor: _getColorFromHex("#7338ac"),
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: _getColorFromHex("#f0f4ff")),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: _getColorFromHex("#7338ac"),
              elevation: 0,
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
            ),
            body: Column(
              children: <Widget>[
                Stack(children: [
                  Container(
                      height: 250,
                      color: _getColorFromHex("#7338ac"),
                      child: GestureDetector(
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            child: AspectRatio(
                              aspectRatio: 1 / 1,
                              child: CachedNetworkImage(
                                fit: BoxFit.fill,
                                imageUrl: post.mediaUrl,
                                placeholder: (context, url) => const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            )),
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Zoom(post: post),
                            ),
                          );
                        },
                      )),
                  Card(
                      elevation: 8,
                      shadowColor: Colors.transparent,
                      color: Colors.transparent,
                      child: Transform.rotate(
                          angle: -math.pi / 4,
                          child: IconButton(
                              onPressed: () async {
                                final Uri url = Uri.parse(post.link);

                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  throw Exception('Could not launch $url');
                                }
                                // launch("https://www.instagram.com/artis__tree/");
                              },
                              icon: Icon(Icons.link,
                                  size: 30,
                                  fill: 0.5,
                                  shadows: const <Shadow>[
                                    Shadow(
                                        color: Colors.black, blurRadius: 15.0)
                                  ],
                                  color: _getColorFromHex("#f0f4ff"))))),
                ]),
                Container(height: 30),
                Expanded(
                    child: Container(
                        color: _getColorFromHex("#7338ac"),
                        child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(100.0)),
                            child: Container(
                                color: _getColorFromHex("#f0f4ff"),
                                child: ListView(children: [
                                  Container(height: 15),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Card(
                                          color: _getColorFromHex("#f0f4ff"),
                                          elevation: 0,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: _getColorFromHex(
                                                        "#635ad9"),
                                                  ),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(20))),
                                              padding: const EdgeInsets.all(4),
                                              alignment: Alignment.center,
                                              child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 2,
                                                      horizontal: 4),
                                                  child: Text(post.item,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            "Poppins-Bold",
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Colors.black,
                                                        fontSize: 20.0,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center))),
                                        ),
                                      ]),
                                  Container(height: 15),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Flexible(
                                                child: Text(post.description,
                                                    style: const TextStyle(
                                                      overflow:
                                                          TextOverflow.visible,
                                                      fontFamily:
                                                          "Poppins-Regular",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black,
                                                      fontSize: 14.0,
                                                    ),
                                                    textAlign:
                                                        TextAlign.center))
                                          ])),
                                  Container(height: 15),
                                  /* Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              const TextSpan(
                                                text: 'If you wanna see more ',
                                                style: TextStyle(
                                                    fontFamily:
                                                        "Poppins-Regular",
                                                    color: Colors.black),
                                              ),
                                              TextSpan(
                                                text: 'click here',
                                                style: const TextStyle(
                                                    fontFamily:
                                                        "Poppins-Regular",
                                                    color: Colors.blue),
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        launch(post.link);
                                                      },
                                              ),
                                              const TextSpan(
                                                text: ' !!!',
                                                style: TextStyle(
                                                    fontFamily:
                                                        "Poppins-Regular",
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        )
                                      ]),
                                  Container(height: 15),*/
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                            "₹ ${format.format(cost * t).substring(3)}",
                                            style: const TextStyle(
                                              fontFamily: "Poppins-Regular",
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                              fontSize: 18.0,
                                            ),
                                            textAlign: TextAlign.center)
                                      ]),
                                  Container(height: 15),
                                  (sEller != currentUser.id)
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                              const Text("     QUANTITY : ",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        "Poppins-Regular",
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                    fontSize: 15.0,
                                                  )),
                                              ClipOval(
                                                child: Material(
                                                  color: Colors
                                                      .transparent, // button color
                                                  child: InkWell(
                                                    // inkwell color
                                                    child: const SizedBox(
                                                      child: Icon(
                                                        Icons
                                                            .remove_circle_outline,
                                                        size: 20,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        if (t > 1) {
                                                          t = t - 1;
                                                        } else {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                Future.delayed(
                                                                    const Duration(
                                                                        seconds:
                                                                            1),
                                                                    () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          true);
                                                                });
                                                                return const AlertDialog(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  title: Text(
                                                                      "Qty must be atleast 1!!",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            "Poppins-Regular",
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            15.0,
                                                                      )),
                                                                );
                                                              });
                                                        }
                                                        cost = cost * t;
                                                        print(cost);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Text("$t          ",
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        "Poppins-Regular",
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                    fontSize: 15.0,
                                                  ),
                                                  textAlign: TextAlign.center),
                                              ClipOval(
                                                child: Material(
                                                  color: Colors
                                                      .transparent, // button color
                                                  child: InkWell(
                                                    // inkwell color
                                                    child: const SizedBox(
                                                      child: Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                        size: 20,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        t = t + 1;
                                                      });

                                                      setState(() {
                                                        cost = cost * t;

                                                        print(cost);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ])
                                      : Column(children: [
                                          Container(height: 50),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                SizedBox(
                                                    width: 200,
                                                    child: ElevatedButton.icon(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        side: const BorderSide(
                                                          width: 2.5,
                                                          color: Colors.black,
                                                        ),
                                                        backgroundColor:
                                                            Colors.red[900],
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0)),
                                                        elevation: 5,
                                                      ),
                                                      onPressed: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (_) => AlertDialog(
                                                                    backgroundColor: Colors
                                                                        .white,
                                                                    title: const Text(
                                                                        "Are you sure??",
                                                                        textAlign: TextAlign
                                                                            .center,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16.0,
                                                                            fontFamily:
                                                                                "Poppins-Bold",
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .black)),
                                                                    content: const Text(
                                                                        "Click yes to delete item",
                                                                        textAlign: TextAlign.center,
                                                                        style: TextStyle(fontSize: 14.0, fontFamily: "Poppins-Regular", fontWeight: FontWeight.bold, color: Colors.black)),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);

                                                                            postsRef.doc(sEller).collection("userPosts").doc(post.postId).get().then((doc) {
                                                                              if (doc.exists) {
                                                                                doc.reference.delete();

                                                                                FirebaseStorage.instance.refFromURL(post.mediaUrl).delete();
                                                                              }
                                                                            });

                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (context) {
                                                                                  Future.delayed(const Duration(seconds: 1), () {
                                                                                    Navigator.of(context).pop(true);
                                                                                    Navigator.pop(context);
                                                                                    showDialog(
                                                                                        context: context,
                                                                                        builder: (_) => const AlertDialog(
                                                                                              backgroundColor: Colors.white,
                                                                                              title: Text("Item Deleted!", textAlign: TextAlign.center, style: TextStyle(fontSize: 17.0, fontFamily: "Poppins-Bold", fontWeight: FontWeight.bold, color: Colors.black)),
                                                                                            ));
                                                                                  });
                                                                                  return AlertDialog(
                                                                                    backgroundColor: Colors.white,
                                                                                    title: const Text("Deleting Item", textAlign: TextAlign.center, style: TextStyle(fontSize: 17.0, fontFamily: "Poppins-Regular", fontWeight: FontWeight.bold, color: Colors.black)),
                                                                                    content: Container(
                                                                                      padding: const EdgeInsets.only(bottom: 10.0),
                                                                                      child: const LinearProgressIndicator(
                                                                                        minHeight: 5,
                                                                                        valueColor: AlwaysStoppedAnimation(Colors.black),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                });
                                                                          },
                                                                          child: const Text(
                                                                              "Yes",
                                                                              style: TextStyle(fontSize: 15.0, fontFamily: "Poppins-Regular", fontWeight: FontWeight.bold, color: Colors.blue))),
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child: const Text(
                                                                              "No",
                                                                              style: TextStyle(fontSize: 15.0, fontFamily: "Poppins-Regular", fontWeight: FontWeight.bold, color: Colors.red))),
                                                                    ]));
                                                      },
                                                      icon: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 10),
                                                        child: Image.asset(
                                                          'images/trash-can.png',
                                                          height: 20,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      label: const Text(
                                                        "Delete Item",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                            fontFamily:
                                                                "Poppins-Regular",
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    )),
                                              ])
                                        ]),
                                  Container(height: 15),
                                  (sEller != currentUser.id)
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                              SizedBox(
                                                  child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            _getColorFromHex(
                                                                "#88f4ff"),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0)),
                                                        elevation: 0,
                                                      ),
                                                      onPressed: () async {
                                                        if (isCart) {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                Future.delayed(
                                                                    const Duration(
                                                                        seconds:
                                                                            1),
                                                                    () async {
                                                                  setState(() {
                                                                    for (String element
                                                                        in currentUser
                                                                            .cart) {
                                                                      if (element
                                                                          .contains(
                                                                              post.postId)) {
                                                                        currentUser
                                                                            .cart
                                                                            .remove(element);
                                                                        break;
                                                                      }
                                                                    }
                                                                  });

                                                                  usersRef
                                                                      .doc(currentUser
                                                                          .id)
                                                                      .update({
                                                                    "cart":
                                                                        currentUser
                                                                            .cart
                                                                  });

                                                                  DocumentSnapshot
                                                                      doc =
                                                                      await usersRef
                                                                          .doc(currentUser
                                                                              .id)
                                                                          .get();

                                                                  setState(() {
                                                                    currentUser
                                                                        .cart
                                                                        .length = currentUser
                                                                            .cart
                                                                            .length +
                                                                        1;

                                                                    currentUser =
                                                                        UserX.fromDocument(
                                                                            doc);
                                                                  });

                                                                  setState(() {
                                                                    isCart =
                                                                        !isCart;
                                                                  });

                                                                  // ignore: use_build_context_synchronously
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          true);

                                                                  notify(
                                                                      "New Alert for ${currentUser.displayName}",
                                                                      "${post.item} removed from cart");
                                                                });
                                                                return AlertDialog(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  title: const Text(
                                                                      "Removing from Cart",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              17.0,
                                                                          fontFamily:
                                                                              "Poppins-Regular",
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black)),
                                                                  content:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            10.0),
                                                                    child:
                                                                        const LinearProgressIndicator(
                                                                      minHeight:
                                                                          5,
                                                                      valueColor:
                                                                          AlwaysStoppedAnimation(
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                );
                                                              });
                                                        } else {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                Future.delayed(
                                                                    const Duration(
                                                                        seconds:
                                                                            1),
                                                                    () async {
                                                                  setState(() {
                                                                    currentUser
                                                                        .cart
                                                                        .add(
                                                                            "${post.postId}*.*$t");
                                                                  });

                                                                  usersRef
                                                                      .doc(currentUser
                                                                          .id)
                                                                      .update({
                                                                    "cart":
                                                                        currentUser
                                                                            .cart
                                                                  });

                                                                  DocumentSnapshot
                                                                      doc =
                                                                      await usersRef
                                                                          .doc(currentUser
                                                                              .id)
                                                                          .get();

                                                                  setState(() {
                                                                    currentUser
                                                                        .cart
                                                                        .length = currentUser
                                                                            .cart
                                                                            .length +
                                                                        1;

                                                                    currentUser =
                                                                        UserX.fromDocument(
                                                                            doc);
                                                                  });

                                                                  setState(() {
                                                                    isCart =
                                                                        !isCart;
                                                                  });

                                                                  // ignore: use_build_context_synchronously
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          true);
                                                                  notify(
                                                                      "New Alert for ${currentUser.displayName}",
                                                                      "${post.item} added to cart");
                                                                });
                                                                return AlertDialog(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  title: const Text(
                                                                      "Adding to Cart",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              17.0,
                                                                          fontFamily:
                                                                              "Poppins-Regular",
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black)),
                                                                  content:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            10.0),
                                                                    child:
                                                                        const LinearProgressIndicator(
                                                                      minHeight:
                                                                          5,
                                                                      valueColor:
                                                                          AlwaysStoppedAnimation(
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                );
                                                              });
                                                        }
                                                      },
                                                      child: Text(
                                                        isCart
                                                            ? "Remove from Cart"
                                                            : "Add to cart",
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              "Poppins-Regular",
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black,
                                                          fontSize: 15.0,
                                                        ),
                                                      ))),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            _getColorFromHex(
                                                                "#88f4ff"),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0)),
                                                        elevation: 0,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    Place(
                                                                        post: [
                                                                  post
                                                                ],
                                                                        t: [
                                                                  t
                                                                ]),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                        "Buy Now",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Poppins-Regular",
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black,
                                                          fontSize: 15.0,
                                                        ),
                                                      )))
                                            ])
                                      : Container(height: 0),
                                  Container(height: 15),
                                  (sEller != currentUser.id)
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                              SizedBox(
                                                  child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            _getColorFromHex(
                                                                "#88f4ff"),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0)),
                                                        elevation: 0,
                                                      ),
                                                      onPressed: () {},
                                                      child: const Text(
                                                        "Customization",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Poppins-Regular",
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black,
                                                          fontSize: 15.0,
                                                        ),
                                                      )))
                                            ])
                                      : Container(height: 0),
                                  Container(height: 15),
                                ]))))),
              ],
            ),
          );
        },
      ),
    );
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
