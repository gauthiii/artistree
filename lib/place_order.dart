import 'package:artistree/models/item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:upi_india/upi_india.dart';
import 'package:uuid/uuid.dart';

import 'alert.dart';
import 'home.dart';
import 'models/order.dart';

class Place extends StatefulWidget {
  final List<Item> post;
  final List<int> t;

  Place({required this.post, required this.t});
  @override
  Cx createState() => Cx();
}

class Cx extends State<Place> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('ORDER CONFIRMATION',
            style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins-Regular")),
        centerTitle: true,
      ),
      backgroundColor: _getColorFromHex("#f0f4ff"),
      body: Screen(post: widget.post, t: widget.t),
    );
  }
}

class Screen extends StatefulWidget {
  final List<Item> post;
  final List<int> t;

  Screen({required this.post, required this.t});
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  final UpiIndia _upiIndia = UpiIndia();
  String orderId = const Uuid().v4();
  String today = DateFormat('dd LLLL yyyy').format(DateTime.now());
  num tax = 0, dis = 0;
  List<UpiApp> apps = [];
  // late String _upiAddrError;

  // final _upiAddressController = TextEditingController();
  // final _amountController = TextEditingController();

  var format = NumberFormat.currency(locale: 'HI');

  //late Future<List<ApplicationMeta>> _appsFuture;

  place(i) async {
    if (widget.post.length > 1) orderId = const Uuid().v4();

    DateTime tq = DateTime.now();
    oRders.doc(orderId).set({
      "orderId": orderId,
      "postId": widget.post[i].postId,
      "item": widget.post[i].item,
      "mediaUrl": widget.post[i].mediaUrl,
      "userId": currentUser.id,
      "cost": ((int.parse(widget.post[i].cash) * widget.t[i])).toString(),
      "tax": "0.00",
      "dis": "0.00",
      "status": "Order Placed",
      "quantity": widget.t[i],
      "timestamp": tq,
      "cus": currentUser.displayName,
      "cnotif": FieldValue.arrayUnion([]),
      "anotif": FieldValue.arrayUnion([]),
    });

    for (String element in currentUser.cart) {
      if (element.contains(widget.post[i].postId)) {
        currentUser.cart.remove(element);
        break;
      }
    }

    await usersRef.doc(currentUser.id).update({"cart": currentUser.cart});

    String feedId = const Uuid().v4();

    activityFeedRef.doc(sEller).collection('feedItems').doc(feedId).set({
      "notifId": currentUser.id,
      "feedId": feedId,
      "mediaUrl": widget.post[i].mediaUrl,
      "orderId": orderId,
      "cus": currentUser.displayName,
      "timestamp": tq,
      "status": "Order Placed",
    });

    /* 
    activityFeedRef
        .doc(currentUser.id)
        .collection('feedItems')
        .doc(feedId)
        .set({
      "notifId": currentUser.id,
      "feedId": feedId,
      "mediaUrl": widget.post[i].mediaUrl,
      "orderId": orderId,
      "cus": currentUser.displayName,
      "timestamp": tq,
      "status": "Order Placed",
    });

    {
      DocumentSnapshot doc = await oRders.doc(orderId).get();

      OrderData order = OrderData.fromDocument(doc);

      setState(() {
        order.anotif.add(orderId);
        order.cnotif.add(feedId);
      });

      oRders.doc(orderId).update({
        "anotif": FieldValue.arrayUnion(order.anotif),
        "cnotif": FieldValue.arrayUnion(order.cnotif)
      });
    } */
  }

  fun() {
    showDialog(
        context: context,
        builder: (_) => const AlertDialog(
              backgroundColor: Colors.white,
              title: Text("ORDER PLACED",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Poppins-Bold",
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              content: Text("Check the Orders page to track your order",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: "Poppins-Regular",
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              // content:  Text("You gotta follow atleast one user to see the timeline.Find some users to follow.Don't be a loner dude!!!!",style:TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white)),
            ));
  }

  @override
  void initState() {
    super.initState();
    _upiIndia
        .getAllUpiApps(
            allowNonVerifiedApps: true, mandatoryTransactionId: false)
        .then((value) {
      setState(() {
        apps = value;
        print(
            "********************************UPI APPS ${apps.length}***********************************");
      });
    }).catchError((e) {
      apps = [];
    });

    //  _upiAddressController.text = "jammi.roshan99@okhdfcbank";
    //   _amountController.text =
    //     (int.parse(widget.post.cash) * widget.t).toString();
    //  _appsFuture = UpiPay.getInstalledUpiApplications();
  }

  @override
  void dispose() {
    //   _amountController.dispose();
    // _upiAddressController.dispose();
    super.dispose();
  }

  /*Future<void> _onTap(ApplicationMeta app) async {
    final err = _validateUpiAddress(_upiAddressController.text);
    if (err != null) {
      setState(() {
        _upiAddrError = err;
      });
      return;
    }
    setState(() {
      _upiAddrError = "";
    });

    final transactionRef = Random.secure().nextInt(1 << 32).toString();
    print("Starting transaction with id $transactionRef");

    final a = await UpiPay.initiateTransaction(
      amount: _amountController.text,
      app: app.upiApplication,
      receiverName: 'Gautham',
      receiverUpiAddress: "yamini.vijayaraj.1972@oksbi",
      transactionRef: transactionRef,
    );

    print(a);
  }*/

  bool show = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: DottedBorder(
          borderType: BorderType.RRect,
          color: Colors.black,
          strokeWidth: 2,
          dashPattern: const [8.0, 1.0],
          child: ListView(
            children: <Widget>[
              Container(
                height: 10,
              ),
              const Center(
                  child: Text('ORDER CONFIRMATION',
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
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text("Invoice Number: ${orderId.substring(0, 18)}",
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins-Regular")),
                      Container(width: 0)
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text("Selling to ${currentUser.displayName}",
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins-Regular")),
                      Container(width: 0)
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text(
                          (widget.post.length == 1)
                              ? "Sold by ${widget.post[0].seller}"
                              : "Selling ${widget.post.length} Items",
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins-Regular")),
                      Container(width: 0)
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text("Date: $today",
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
                  padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              for (int i = 0; i < widget.post.length; i++)
                Container(
                    padding:
                        const EdgeInsets.only(top: 12, left: 16, right: 16),
                    child: Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.post[i].item.split(" ")[0],
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins-Regular")),
                            Text('${widget.t[i]}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins-Regular")),
                            Text(
                                "Rs. ${format.format((int.parse(widget.post[i].cash))).substring(3, format.format((int.parse(widget.post[i].cash))).length - 3)}",
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins-Regular")),
                            Text(
                                "Rs. ${format.format((int.parse(widget.post[i].cash) * widget.t[i])).substring(3, format.format((int.parse(widget.post[i].cash) * widget.t[i])).length - 3)}",
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins-Regular"))
                          ]),
                      (widget.post[i].item.split(" ").length > 1)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  Text(
                                      widget.post[i].item.substring(widget
                                              .post[i].item
                                              .split(" ")[0]
                                              .length +
                                          1),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Poppins-Regular"))
                                ])
                          : Container(
                              height: 0,
                            )
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
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text(
                          "Subtotal: Rs. ${format.format((int.parse(widget.post[0].cash) * widget.t[0])).substring(3)}",
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins-Regular")),
                      Container(width: 0)
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text("Tax: Rs. ${format.format((tax)).substring(3)}",
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins-Regular")),
                      Container(width: 0)
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text("Discount: Rs. ${format.format((dis)).substring(3)}",
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins-Regular")),
                      Container(width: 0)
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text(
                          "Grand Total: Rs. ${format.format((int.parse(widget.post[0].cash) * widget.t[0]) + tax - dis).substring(3)}",
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('PAYMENT METHOD',
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
              const Center(
                  child: Text('CHOOSE THE PAYMENT METHOD',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins-Regular"))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          show = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: const Text("Pay using UPI",
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontFamily: "Poppins-Regular"))),
                ),
                /*   if (_upiAddrError != "")
            Container(
              margin: const EdgeInsets.only(top: 4, left: 12),
              child: Text(
                _upiAddrError,
                style: const TextStyle(color: Colors.red),
              ),
            ),*/
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);

                        // ignore: use_build_context_synchronously
                        showDialog(
                            context: context,
                            builder: (context) {
                              Future.delayed(const Duration(seconds: 1), () {
                                Navigator.of(context).pop(true);
                                for (int i = 0; i < widget.post.length; i++) {
                                  place(i);
                                }
                                fun();
                              });
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text("Placing Order",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 17.0,
                                        fontFamily: "Poppins-Regular",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                content: Container(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: const LinearProgressIndicator(
                                    minHeight: 5,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.black),
                                  ),
                                ),
                              );
                            });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: const Text("Cash on Delivery",
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontFamily: "Poppins-Regular"))),
                ),
              ]),
              (show == true)
                  ? Container(
                      margin: const EdgeInsets.only(top: 16, bottom: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: const Text(
                              'Pay Using',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontFamily: "Poppins-Regular"),
                            ),
                          ),
                          (apps.isEmpty)
                              ? const SizedBox(height: 0, width: 0)
                              : GridView.count(
                                  crossAxisCount:
                                      (apps.length <= 4) ? apps.length : 4,
                                  shrinkWrap: true,
                                  mainAxisSpacing: 2,
                                  crossAxisSpacing: 2,
                                  childAspectRatio: 1.6,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    for (int i = 0; i < apps.length; i++)
                                      Material(
                                        color: _getColorFromHex("#f0f4ff"),
                                        child: InkWell(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (_) => const AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    title: Text(
                                                        "UPI Payment Disabled",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontFamily:
                                                                "Poppins-Bold",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black)),
                                                    content: Text(
                                                        "Please Choose COD",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontFamily:
                                                                "Poppins-Regular",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .black))));
                                            //_onTap(it);
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Image.memory(
                                                apps[i].icon,
                                                width: 32,
                                                height: 32,
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 4),
                                                child: Text(apps[i].name,
                                                    style: const TextStyle(
                                                        fontSize: 8,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            "Poppins-Regular")),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                  ],
                                )
                        ],
                      ),
                    )
                  : const Text("")
            ],
          )),
    );
  }
}

String? _validateUpiAddress(String value) {
  if (value.isEmpty) {
    return 'UPI Address is required.';
  }

  // if (!UpiPay.checkIfUpiAddressIsValid(value)) {
  //   return 'UPI Address is invalid.';
  // }

  return null;
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
