import 'package:artistree/progress.dart';
import 'package:artistree/receipt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:intl/intl.dart';

import 'home.dart';
import 'package:artistree/models/order.dart';

import 'item_screen.dart';
import 'main.dart';
import 'models/feed.dart';

class Corders extends StatefulWidget {
  const Corders({super.key});

  @override
  Cx createState() => Cx();
}

class Cx extends State<Corders> {
  var format = NumberFormat.currency(locale: 'HI');
  bool isloading = false;
  @override
  void initState() {
    super.initState();

    orders();
  }

  List<OrderData> order = [];

  orders() async {
    /* Firestore.instance.collection("payments")
        .where(Filter.or(
            Filter("receiver_name", isEqualTo: "kim"),
            Filter("sender_name", isEqualTo: "kim")
               )).snapshots();*/

    setState(() {
      order = [];

      isloading = true;
    });

    await analytics.logEvent(
      name: "orders_page",
      parameters: {
        "button_clicked": "true",
        "email": currentUser.email,
        "displayName": currentUser.displayName,
        "id": currentUser.id,
        "timestamp": DateTime.now().toString(),
      },
    );

    print(currentUser.id);
    if (currentUser.id == sEller) {
      QuerySnapshot snapshot =
          await oRders.orderBy('timestamp', descending: true).get();
      print(order.length);
      setState(() {
        order =
            snapshot.docs.map((doc) => OrderData.fromDocument(doc)).toList();
      });
    } else {
      QuerySnapshot snapshot = await oRders
          .where('userId', isEqualTo: currentUser.id)
          .orderBy('timestamp', descending: true)
          .get();
      print(order.length);
      setState(() {
        order =
            snapshot.docs.map((doc) => OrderData.fromDocument(doc)).toList();
      });
    }

    print(order.length);
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
                            child: const Text("Orders",
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
                            child: const Text("Orders",
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
                      "images/gift-box.png",
                      height: 200,
                      color: _getColorFromHex("#635ad9"),
                    ),
                    Container(height: 50),
                    Transform.translate(
                      offset: const Offset(0, 0),
                      child: Text(
                        "You have no orders !",
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
                            child: const Text("Orders",
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
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AReciept(
                            orderId: order[index].orderId,
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      if (currentUser.id == sEller) {
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: const Text("Are you sure??",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontFamily: "Poppins-Bold",
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    content: const Text(
                                        "Click yes to delete order",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: "Poppins-Regular",
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);

                                            oRders
                                                .doc(order[index].orderId)
                                                .get()
                                                .then((doc) async {
                                              if (doc.exists) {
                                                doc.reference.delete();

                                                List<Feed> notif = [];

                                                QuerySnapshot snapshot =
                                                    await activityFeedRef
                                                        .doc(sEller)
                                                        .collection('feedItems')
                                                        .orderBy('timestamp',
                                                            descending: true)
                                                        .get();

                                                setState(() {
                                                  notif = snapshot.docs
                                                      .map((dz) =>
                                                          Feed.fromDocument(dz))
                                                      .toList();
                                                });

                                                notif.forEach((n) {
                                                  if (n.orderId ==
                                                      order[index].orderId) {
                                                    activityFeedRef
                                                        .doc(sEller)
                                                        .collection('feedItems')
                                                        .doc(n.feedId)
                                                        .get()
                                                        .then((dx) {
                                                      if (dx.exists) {
                                                        dx.reference.delete();
                                                      }
                                                    });
                                                  }
                                                });
                                              }
                                            });

                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  Future.delayed(
                                                      const Duration(
                                                          seconds: 1), () {
                                                    Navigator.of(context)
                                                        .pop(true);

                                                    showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            const AlertDialog(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              title: Text(
                                                                  "Order Deleted!",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17.0,
                                                                      fontFamily:
                                                                          "Poppins-Bold",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black)),
                                                            ));
                                                    orders();
                                                  });
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    title: const Text(
                                                        "Deleting Order",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 17.0,
                                                            fontFamily:
                                                                "Poppins-Regular",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black)),
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
                                          child: const Text("Yes",
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontFamily: "Poppins-Regular",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue))),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("No",
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontFamily: "Poppins-Regular",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red))),
                                    ]));
                      }
                    },
                    child: Container(
                        padding: const EdgeInsets.all(4),
                        height: 130,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          color: _getColorFromHex("#635ad9").withOpacity(0.4),
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
                                            text: (sEller == currentUser.id)
                                                ? '${order[index].quantity} x ${order[index].item}\nFor ${order[index].cus}\nPrice : ${format.format((int.parse(order[index].cost)) + num.parse(order[index].tax) - num.parse(order[index].dis)).substring(3)} Rs\nCustomized\n'
                                                : '${order[index].item}\nQty : ${order[index].quantity}\nPrice : ${format.format((int.parse(order[index].cost)) + num.parse(order[index].tax) - num.parse(order[index].dis)).substring(3)} Rs\nCustomized\n',
                                            style: const TextStyle(
                                              fontFamily: "Poppins-Regular",
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.0,
                                            ),
                                          ),
                                          TextSpan(
                                            text: order[index]
                                                .status
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontFamily: "Poppins-Bold",
                                              color: (order[index].status ==
                                                      "Cancelled")
                                                  ? Colors.red[900]
                                                  : Colors.green[900],
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
                                      Text(
                                          "Ordered On : ${delivery(order[index].timestamp.toDate(), 0)}",
                                          style: const TextStyle(
                                            fontFamily: "Poppins-Regular",
                                            color: Colors.black,
                                            fontSize: 11,
                                          )),
                                    ])
                              ])
                        ])),
                  )
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

delivery(ts, t) {
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

  DateTime ns = DateTime(ts.year, ts.month, ts.day + t);
  String x = ns.toString();

  x = x.split(" ")[0];
  // ignore: prefer_interpolation_to_compose_strings
  String y =
      // ignore: prefer_interpolation_to_compose_strings
      "${ns.day} ${mon[ns.month - 1]} ${ns.year}";
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
