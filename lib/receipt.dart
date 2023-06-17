import 'package:artistree/contact.dart';
import 'package:artistree/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'home.dart';
import 'models/item.dart';
import 'models/order.dart';
import 'models/user.dart';

class AReciept extends StatefulWidget {
  final String orderId;

  AReciept({required this.orderId});

  @override
  Cx createState() => Cx();
}

class Cx extends State<AReciept> {
  List status = [
    "Order Placed",
    "Order Confirmed",
    "In Progress",
    "Dispatched",
    "Delivered",
    "Cancelled"
  ];
  bool isloading = false;
  var format = NumberFormat.currency(locale: 'HI');
  late UserX user;
  late Item post;
  late OrderData order;
  @override
  void initState() {
    super.initState();

    refresh();
  }

  refresh() async {
    setState(() {
      isloading = true;
    });

    DocumentSnapshot ddoc = await oRders.doc(widget.orderId).get();
    order = OrderData.fromDocument(ddoc);

    print(order.userId);

    if (currentUser.id == sEller) {
      DocumentSnapshot doc = await usersRef.doc(order.userId).get();
      user = UserX.fromDocument(doc);
    } else {
      DocumentSnapshot doc = await usersRef.doc(sEller).get();
      user = UserX.fromDocument(doc);
    }

    DocumentSnapshot doc1 = await postsRef
        .doc(sEller)
        .collection("userPosts")
        .doc(order.postId)
        .get();
    post = Item.fromDocument(doc1);
    setState(() {
      isloading = false;
    });
  }

  fun() {
    showDialog(
        context: context,
        builder: (_) => const AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Order Cancelled!!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _getColorFromHex("#f0f4ff"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _getColorFromHex("#635ad9")),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Card(
          color: _getColorFromHex("#f0f4ff"),
          elevation: 0,
          child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: _getColorFromHex("#635ad9"),
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(15))),
              padding: const EdgeInsets.all(4),
              alignment: Alignment.center,
              child: const Text("Order Reciept",
                  style: TextStyle(
                    fontFamily: "Poppins-Bold",
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                  textAlign: TextAlign.center)),
        ),
      ),
      backgroundColor: _getColorFromHex("#f0f4ff"),
      body: (isloading == true)
          ? circularProgress()
          : Container(
              color: _getColorFromHex("#f0f4ff"),
              child: ListView(children: [
                Container(height: 10),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    child: DottedBorder(
                        borderType: BorderType.RRect,
                        color: Colors.black,
                        strokeWidth: 2,
                        dashPattern: const [8.0, 1.0],
                        child: Column(children: [
                          Container(
                            height: 10,
                          ),
                          const Center(
                              child: Text('ORDER INVOICE',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins-Regular"))),
                          Transform.translate(
                              offset: const Offset(0, -10),
                              child: DottedBorder(
                                customPath: (size) {
                                  return Path()
                                    ..moveTo(0, 20)
                                    ..lineTo(size.width, 20);
                                },
                                strokeWidth: 2,
                                dashPattern: const [8.0, 1.0],
                                child: Container(height: 0),
                              )),
                          Container(height: 10),
                          Padding(
                              padding: const EdgeInsets.only(left: 16, top: 7),
                              child: Column(children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Invoice Number: ${order.orderId.substring(0, 18)}",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular")),
                                      Container(width: 0)
                                    ]),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text("Selling to ${order.cus}",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular")),
                                      Container(width: 0)
                                    ]),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text("Sold by ${post.seller}",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular")),
                                      Container(width: 0)
                                    ]),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Date: ${delivery(order.timestamp.toDate(), 0)}",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular")),
                                      Container(width: 0)
                                    ]),
                              ])),
                          Transform.translate(
                              offset: const Offset(0, -10),
                              child: DottedBorder(
                                customPath: (size) {
                                  return Path()
                                    ..moveTo(0, 20)
                                    ..lineTo(size.width, 20);
                                },
                                strokeWidth: 2,
                                dashPattern: const [8.0, 1.0],
                                child: Container(height: 0),
                              )),
                          Container(
                              padding: const EdgeInsets.only(top: 12),
                              child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text('ITEM',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular")),
                                    Text('QTY',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular")),
                                    Text('COST',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular")),
                                    Text('TOTAL',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular"))
                                  ])),
                          Transform.translate(
                              offset: const Offset(0, -10),
                              child: DottedBorder(
                                customPath: (size) {
                                  return Path()
                                    ..moveTo(0, 20)
                                    ..lineTo(size.width, 20);
                                },
                                strokeWidth: 2,
                                dashPattern: const [8.0, 1.0],
                                child: Container(height: 0),
                              )),
                          Container(height: 10),
                          Container(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(post.item,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular")),
                                    Text('${order.quantity}',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular")),
                                    Text(
                                        "Rs. ${format.format((int.parse(post.cash))).substring(3, format.format((int.parse(post.cash))).length - 3)}",
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular")),
                                    Text(
                                        "Rs. ${format.format((int.parse(post.cash) * order.quantity)).substring(3, format.format((int.parse(post.cash) * order.quantity)).length - 3)}",
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular"))
                                  ])),
                          Container(height: 10),
                          Transform.translate(
                              offset: const Offset(0, -10),
                              child: DottedBorder(
                                customPath: (size) {
                                  return Path()
                                    ..moveTo(0, 20)
                                    ..lineTo(size.width, 20);
                                },
                                strokeWidth: 2,
                                dashPattern: const [8.0, 1.0],
                                child: Container(height: 0),
                              )),
                          Container(height: 10),
                          Padding(
                              padding: const EdgeInsets.only(left: 16, top: 7),
                              child: Column(children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Subtotal: Rs. ${format.format((int.parse(post.cash) * order.quantity)).substring(3)}",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular")),
                                      Container(width: 0)
                                    ]),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Tax: Rs. ${format.format((num.parse(order.tax))).substring(3)}",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular")),
                                      Container(width: 0)
                                    ]),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Discount: Rs. ${format.format((num.parse(order.dis))).substring(3)}",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular")),
                                      Container(width: 0)
                                    ]),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Grand Total: Rs. ${format.format((int.parse(post.cash) * order.quantity) + num.parse(order.tax) - num.parse(order.dis)).substring(3)}",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular")),
                                      Container(width: 0)
                                    ]),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                          "Payment Method: Cash on Delivery",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular")),
                                      Container(width: 0)
                                    ]),
                              ])),
                          Transform.translate(
                              offset: const Offset(0, -10),
                              child: DottedBorder(
                                customPath: (size) {
                                  return Path()
                                    ..moveTo(0, 20)
                                    ..lineTo(size.width, 20);
                                },
                                strokeWidth: 2,
                                dashPattern: const [8.0, 1.0],
                                child: Container(height: 0),
                              )),
                          Container(
                              padding: const EdgeInsets.only(top: 12),
                              child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('ORDER STATUS',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular")),
                                  ])),
                          Transform.translate(
                              offset: const Offset(0, -10),
                              child: DottedBorder(
                                customPath: (size) {
                                  return Path()
                                    ..moveTo(0, 20)
                                    ..lineTo(size.width, 20);
                                },
                                strokeWidth: 2,
                                dashPattern: const [8.0, 1.0],
                                child: Container(height: 0),
                              )),
                          Container(height: 10),
                          ListTile(
                              onTap: (sEller == currentUser.id)
                                  ? () async {
                                      setState(() {
                                        var x = status.indexOf(order.status);

                                        if (x < 5) {
                                          x = x + 1;
                                        } else {
                                          x = 0;
                                        }

                                        print(x);

                                        oRders
                                            .doc(order.orderId)
                                            .update({"status": status[x]});

                                        String feedId = const Uuid().v4();

                                        activityFeedRef
                                            .doc(sEller)
                                            .collection('feedItems')
                                            .doc(feedId)
                                            .set({
                                          "notifId": order.userId,
                                          "feedId": feedId,
                                          "mediaUrl": order.mediaUrl,
                                          "orderId": order.orderId,
                                          "cus": currentUser.displayName,
                                          "timestamp": DateTime.now(),
                                          "status": status[x]
                                        });
                                      });

                                      await refresh();

                                      // ignore: use_build_context_synchronously
                                      showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                                backgroundColor: Colors.white,
                                                title: const Text(
                                                    "STATUS UPDATED",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontFamily:
                                                            "Poppins-Bold",
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black)),
                                                content: Text(order.status,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 14.0,
                                                        fontFamily:
                                                            "Poppins-Regular",
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black)),
                                              ));
                                    }
                                  : null,
                              trailing: Container(
                                width: 150,
                                height: 50,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: (order.status == "Cancelled")
                                            ? const Color.fromRGBO(
                                                183, 28, 28, 1)
                                            : const Color.fromRGBO(
                                                27, 94, 32, 1),
                                        width: 2.0),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                alignment: Alignment.center,
                                child: Text(order.status,
                                    style: TextStyle(
                                      fontFamily: "Poppins-Bold",
                                      fontWeight: FontWeight.w900,
                                      color: (order.status == "Cancelled")
                                          ? Colors.red[900]
                                          : Colors.green[900],
                                      fontSize: 15.0,
                                    ),
                                    textAlign: TextAlign.center),
                              ),
                              title: const Text("Expected Delivery",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              subtitle:
                                  Text(delivery(order.timestamp.toDate(), 6),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ))),
                        ]))),
                Divider(),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.6,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Material(
                              color: _getColorFromHex("#f0f4ff"),
                              child: InkWell(
                                onTap: () async {
                                  if (currentUser.id != sEller) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Contact(),
                                      ),
                                    );
                                  } else {
                                    final Uri _url = Uri.parse(
                                        'https://wa.me/91${user.mobile}?text=Hello');

                                    if (await canLaunchUrl(_url)) {
                                      await launchUrl(_url,
                                          mode: LaunchMode.externalApplication);
                                    } else {
                                      throw Exception('Could not launch $_url');
                                    }
                                  }
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image(
                                      image: AssetImage(
                                          (currentUser.id == sEller)
                                              ? 'images/whatsapp.png'
                                              : 'images/phone.png'),
                                      width: 64,
                                      height: 64,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      child: Text(
                                          (currentUser.id == sEller)
                                              ? "Text on Whatsapp"
                                              : "Contact Us",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular")),
                                    ),
                                  ],
                                ),
                              )),
                          Material(
                              color: _getColorFromHex("#f0f4ff"),
                              child: InkWell(
                                onTap: () {
                                  if (order.status == "Delivered" ||
                                      order.status == "Cancelled") {
                                    showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: Text(
                                                  "Already ${order.status}",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 18.0,
                                                      fontFamily:
                                                          "Poppins-Bold",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                              content: const Text(
                                                  "Can't Cancel the order",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontFamily:
                                                          "Poppins-Regular",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                            ));
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                                backgroundColor: Colors.white,
                                                title: const Text(
                                                    "Are you sure??",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 20.0,
                                                        fontFamily:
                                                            "Poppins-Bold",
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black)),
                                                content: const Text(
                                                    "Click yes to cancel order",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        fontFamily:
                                                            "Poppins-Regular",
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black)),
                                                actionsPadding: EdgeInsets.zero,
                                                actions: [
                                                  TextButton(
                                                      onPressed: () async {
                                                        Navigator.pop(context);

                                                        oRders
                                                            .doc(order.orderId)
                                                            .update({
                                                          "status": status[5]
                                                        });

                                                        String feedId =
                                                            const Uuid().v4();

                                                        activityFeedRef
                                                            .doc(sEller)
                                                            .collection(
                                                                'feedItems')
                                                            .doc(feedId)
                                                            .set({
                                                          "notifId":
                                                              order.userId,
                                                          "feedId": feedId,
                                                          "mediaUrl":
                                                              order.mediaUrl,
                                                          "orderId":
                                                              order.orderId,
                                                          "cus": currentUser
                                                              .displayName,
                                                          "timestamp":
                                                              DateTime.now(),
                                                          "status": status[5]
                                                        });

                                                        await refresh();

                                                        // ignore: use_build_context_synchronously
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (_) =>
                                                                    AlertDialog(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      title: const Text(
                                                                          "STATUS UPDATED",
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                          style: TextStyle(
                                                                              fontSize: 18.0,
                                                                              fontFamily: "Poppins-Bold",
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black)),
                                                                      content: Text(
                                                                          order
                                                                              .status,
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                          style: const TextStyle(
                                                                              fontSize: 14.0,
                                                                              fontFamily: "Poppins-Regular",
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black)),
                                                                    ));
                                                      },
                                                      child: const Text("Yes",
                                                          style: TextStyle(
                                                              fontSize: 15.0,
                                                              fontFamily:
                                                                  "Poppins-Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .blue))),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text("No",
                                                          style: TextStyle(
                                                              fontSize: 15.0,
                                                              fontFamily:
                                                                  "Poppins-Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .red[900]))),
                                                ]));
                                  }
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Image(
                                      image: AssetImage('images/close.png'),
                                      width: 64,
                                      height: 64,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      child: const Text("Cancel Order",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular")),
                                    ),
                                  ],
                                ),
                              )),
                        ])),
              ])),
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

delivery(ts, n) {
  List mon = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  DateTime ns = new DateTime(ts.year, ts.month, ts.day + n);
  String x = ns.toString();

  x = x.split(" ")[0];
  String y =
      x.substring(x.length - 2) + " " + mon[ns.month - 1] + " ${ns.year}";
  return y;
}
