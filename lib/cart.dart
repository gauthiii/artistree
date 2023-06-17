import 'package:artistree/home.dart';
import 'package:artistree/models/item.dart';
import 'package:artistree/place_order.dart';
import 'package:artistree/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import 'item_screen.dart';
import 'main.dart';
import 'models/user.dart';

class Cart extends StatefulWidget {
  final List cart;
  Cart({required this.cart});
  @override
  Cx createState() => Cx();
}

class Cx extends State<Cart> {
  var format = NumberFormat.currency(locale: 'HI');
  bool isloading = false;
  @override
  void initState() {
    super.initState();

    orders();
  }

  List<Item> order = [];
  List<int> qty = [];

  orders() async {
    setState(() {
      isloading = true;
      order = [];
      qty = [];
    });
    print(currentUser.id);

    await analytics.logEvent(
      name: "carts_page",
      parameters: {
        "button_clicked": "true",
        "email": currentUser.email,
        "displayName": currentUser.displayName,
        "id": currentUser.id,
        "timestamp": DateTime.now().toString(),
      },
    );

    currentUser.cart.forEach((element) async {
      //  if (element.userId != widget.currentUser.id) order.remove(element);

      print(element.split("*.*")[0]);
      DocumentSnapshot o = await postsRef
          .doc(currentUser.sellerId)
          .collection('userPosts')
          .doc(element.split("*.*")[0])
          .get();

      Item i = Item.fromDocument(o);

      setState(() {
        order.add(i);
        print(i.category);
        qty.add(int.parse(element.split("*.*")[1]));
      });
    });
    print(order);

    setState(() {
      isloading = false;
    });
  }

  fun() {
    Navigator.pop(context);
    Navigator.pop(context);

    orders();

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
    if (isloading == true) {
      return Scaffold(
          appBar: PreferredSize(
              preferredSize:
                  const Size.fromHeight(100.0), // here the desired height
              child: AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: _getColorFromHex("#635ad9")),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  elevation: 0,
                  backgroundColor: _getColorFromHex("#f0f4ff"),
                  centerTitle: true,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Card(
                        color: _getColorFromHex("#f0f4ff"),
                        elevation: 0,
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: _getColorFromHex("#635ad9"),
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15))),
                            padding: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            child: const Text("My Cart",
                                style: TextStyle(
                                  fontFamily: "Poppins-Bold",
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  fontSize: 20.0,
                                ),
                                textAlign: TextAlign.center)),
                      ),
                    ],
                  ))),
          backgroundColor: _getColorFromHex("#f0f4ff"),
          body: Center(child: circularProgress()));
    } else if (order.isEmpty) {
      return Scaffold(
          appBar: PreferredSize(
              preferredSize:
                  const Size.fromHeight(100.0), // here the desired height
              child: AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: _getColorFromHex("#635ad9")),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  elevation: 0,
                  backgroundColor: _getColorFromHex("#f0f4ff"),
                  centerTitle: true,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Card(
                        color: _getColorFromHex("#f0f4ff"),
                        elevation: 0,
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: _getColorFromHex("#635ad9"),
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15))),
                            padding: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            child: const Text("My Cart",
                                style: TextStyle(
                                  fontFamily: "Poppins-Bold",
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  fontSize: 20.0,
                                ),
                                textAlign: TextAlign.center)),
                      ),
                    ],
                  ))),
          backgroundColor: _getColorFromHex("#f0f4ff"),
          body: RefreshIndicator(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(height: 120),
                    Image.asset(
                      "images/cart.png",
                      height: 200,
                      color: _getColorFromHex("#635ad9"),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -25),
                      child: Text(
                        "Your Cart is Empty !",
                        style: TextStyle(
                          fontFamily: "Poppins-Bold",
                          color: _getColorFromHex("#635ad9"),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ignore: missing_return
              onRefresh: () {
                orders();
                return Future(() => null);
              }));
    } else {
      return Scaffold(
          appBar: PreferredSize(
              preferredSize:
                  const Size.fromHeight(80.0), // here the desired height
              child: AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        size: 30, color: _getColorFromHex("#635ad9")),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  elevation: 0,
                  backgroundColor: _getColorFromHex("#f0f4ff"),
                  centerTitle: true,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Card(
                        color: _getColorFromHex("#f0f4ff"),
                        elevation: 0,
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: _getColorFromHex("#635ad9"),
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15))),
                            padding: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            child: const Text("My Cart",
                                style: TextStyle(
                                  fontFamily: "Poppins-Bold",
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  fontSize: 20.0,
                                ),
                                textAlign: TextAlign.center)),
                      ),
                    ],
                  ))),
          backgroundColor: _getColorFromHex("#f0f4ff"),
          body: orders_list());
    }
  }

  // ignore: non_constant_identifier_names
  orders_list() {
    return RefreshIndicator(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: ListView.separated(
              itemCount: order.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
              itemBuilder: (BuildContext context, int index) {
                return Column(children: [
                  Container(
                      padding: const EdgeInsets.all(4),
                      height: 130,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        color: _getColorFromHex("#911482").withOpacity(0.3),
                      ),
                      child: Stack(children: [
                        Row(children: [
                          Container(
                              padding: const EdgeInsets.all(8),
                              child: AspectRatio(
                                  aspectRatio: 5 / 5,
                                  child: GestureDetector(
                                      onTap: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PostScreenX(
                                              postId: order[index].postId,
                                            ),
                                          ),
                                        );
                                      },
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        imageUrl: order[index].mediaUrl,
                                        placeholder: (context, url) =>
                                            const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      )))),
                          Container(
                              padding: const EdgeInsets.all(8),
                              child: AspectRatio(
                                  aspectRatio: 8 / 5,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              '${order[index].item}\nQty : ${qty[index]}\nPrice : ${format.format((int.parse(order[index].cash)) * qty[index]).substring(3)} Rs',
                                          style: const TextStyle(
                                            fontFamily: "Poppins-Regular",
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))),
                        ]),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Transform.scale(
                                      scale: 0.8,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0)),
                                          elevation: 0,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Place(
                                                  post: [order[index]],
                                                  t: [qty[index]]),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Place Order",
                                          style: TextStyle(
                                            fontFamily: "Poppins-Bold",
                                            color: _getColorFromHex("#f0f4ff"),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10.0,
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 10,
                                    height: 0,
                                  ),
                                  Transform.scale(
                                      scale: 0.8,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0)),
                                          elevation: 0,
                                        ),
                                        onPressed: () async {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                Future.delayed(
                                                    const Duration(seconds: 1),
                                                    () {
                                                  setState(() {
                                                    currentUser.cart.remove(
                                                        '${order[index].postId}*.*${qty[index]}');
                                                  });

                                                  usersRef
                                                      .doc(currentUser.id)
                                                      .update({
                                                    "cart": currentUser.cart
                                                  });

                                                  orders();

                                                  Navigator.of(context)
                                                      .pop(true);
                                                });
                                                return AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  title: const Text(
                                                      "Removing from Cart",
                                                      textAlign:
                                                          TextAlign.center,
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
                                        },
                                        child: Text(
                                          "Remove Item",
                                          style: TextStyle(
                                            fontFamily: "Poppins-Bold",
                                            color: _getColorFromHex("#f0f4ff"),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10.0,
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 3,
                                    height: 0,
                                  ),
                                ],
                              ),
                              Container(height: 5)
                            ])
                      ])),
                  if (index == order.length - 1)
                    Column(children: [
                      Container(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: 200,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _getColorFromHex("#911482")
                                        .withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Place(post: order, t: qty),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    (order.length > 1)
                                        ? "Checkout cart - all ${order.length} items"
                                        : "Checkout cart",
                                    style: const TextStyle(
                                      fontFamily: "Poppins-Bold",
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                )),
                            SizedBox(
                                child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[900],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        List<String> e = [];
                                        usersRef.doc(currentUser.id).update({
                                          "cart": e,
                                        });

                                        setState(() {
                                          order = [];
                                          qty = [];
                                        });

                                        Navigator.of(context).pop(true);
                                      });
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: const Text("Emptying Cart",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                fontFamily: "Poppins-Regular",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                        content: Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: const LinearProgressIndicator(
                                            minHeight: 5,
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.black),
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: const Text(
                                "Empty cart",
                                style: TextStyle(
                                  fontFamily: "Poppins-Bold",
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                ),
                              ),
                            )),
                          ]),
                      Container(height: 10),
                    ])
                ]);
              },
            )),
        // ignore: missing_return
        onRefresh: () {
          orders();
          return Future(() => null);
        });
  }
}

delivery(ts) {
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

  DateTime ns = DateTime(ts.year, ts.month, ts.day + 6);
  String x = ns.toString();

  x = x.split(" ")[0];
  // ignore: prefer_interpolation_to_compose_strings
  String y =
      // ignore: prefer_interpolation_to_compose_strings
      "${"${x.substring(x.length - 2)} " + mon[ns.month - 1]} ${ns.year}";
  return y;
}

time(DateTime ns) {
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

  String x = ns.toString();

  x = x.split(" ")[0];
  String y =
      // ignore: prefer_interpolation_to_compose_strings
      "${"${x.substring(x.length - 2)} " + mon[ns.month - 1]} ${x.substring(0, 4)}";
  return y;
}

am(String x) {
  String y = x.substring(0, 2);
  int y1 = int.parse(y);

  if (y1 == 0) {
    return "12${x.substring(2)} AM";
  } else if (y1 < 12) {
    return "$y1${x.substring(2)} AM";
  } else if (y1 == 12) {
    return "12${x.substring(2)} PM";
  } else {
    return "${y1 - 12}${x.substring(2)} PM";
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
