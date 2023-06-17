import 'package:artistree/home.dart';
import 'package:artistree/models/exit.dart';
import 'package:artistree/progress.dart';
import 'package:artistree/receipt.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'alert.dart';
import 'main.dart';
import 'models/feed.dart';

class Notifs extends StatefulWidget {
  const Notifs({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Notifs> {
  List<Feed> notif = [];
  List<bool> isTap = [];

  String text = "";
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    n();
  }

  n() async {
    setState(() {
      isLoading = true;
      notif = [];
      isTap = [];
    });

    await analytics.logEvent(
      name: "notif_page",
      parameters: {
        "button_clicked": "true",
        "email": currentUser.email,
        "displayName": currentUser.displayName,
        "id": currentUser.id,
        "timestamp": DateTime.now().toString(),
      },
    );

    if (currentUser.id == sEller) {
      QuerySnapshot snapshot = await activityFeedRef
          .doc(sEller)
          .collection('feedItems')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        notif = snapshot.docs.map((doc) => Feed.fromDocument(doc)).toList();
      });
    } else {
      QuerySnapshot snapshot = await activityFeedRef
          .doc(sEller)
          .collection('feedItems')
          .where('notifId', isEqualTo: currentUser.id)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        notif = snapshot.docs.map((doc) => Feed.fromDocument(doc)).toList();
      });
    }

    setState(() {
      isTap = List.generate(notif.length, (index) => false);
      isLoading = false;
    });
  }

  delete(String x, String y) {
    if (x == "Order Placed") {
      text = ' placed an order';
    } else if (x == "Order Confirmed") {
      text = ' : order has been confirmed';
    } else if (x == "Dispatched") {
      text = ' : order has been confirmed';
    } else if (x == "Delivering Today") {
      text = ' : order will be delivered today';
    } else if (x == "Delivered") {
      text = ' received their order';
    } else if (x == "Cancelled") {
      text = ' cancelled their order';
    }

    return text;
  }

  delete1(String x, String y) {
    if (x == "Order Placed") {
      text = 'You placed an order';
    } else if (x == "Order Confirmed") {
      text = 'Your order has been confirmed';
    } else if (x == "Dispatched") {
      text = 'Your order has been dispatched';
    } else if (x == "Delivering Today") {
      text = 'Your order will be delivered today';
    } else if (x == "Delivered") {
      text = 'Your order has been delivered';
    } else if (x == "Cancelled") {
      text = 'Your order has been cancelled';
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          exitButton(context);
          return Future(() => false);
        },
        child: (isLoading == true)
            ? circularProgress()
            : (notif.isEmpty)
                ? Center(
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
                            "You have no notifications !",
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
                  )
                : RefreshIndicator(
                    child: ListView.separated(
                      itemCount: notif.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(
                        color: Colors.transparent,
                        thickness: 0,
                        height: 2.5,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                            onDoubleTap: () {
                              setState(() {
                                isTap[index] = !isTap[index];
                              });
                            },
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AReciept(
                                    orderId: notif[index].orderId,
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
                                                "Click yes to delete notification",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    fontFamily:
                                                        "Poppins-Regular",
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);

                                                    activityFeedRef
                                                        .doc(sEller)
                                                        .collection('feedItems')
                                                        .doc(
                                                            notif[index].feedId)
                                                        .get()
                                                        .then((doc) {
                                                      if (doc.exists) {
                                                        doc.reference.delete();
                                                      }
                                                    });

                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          Future.delayed(
                                                              const Duration(
                                                                  seconds: 1),
                                                              () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true);

                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder: (_) =>
                                                                    const AlertDialog(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      title: Text(
                                                                          "Notification Deleted!",
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                          style: TextStyle(
                                                                              fontSize: 17.0,
                                                                              fontFamily: "Poppins-Bold",
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black)),
                                                                    ));
                                                            n();
                                                          });
                                                          return AlertDialog(
                                                            backgroundColor:
                                                                Colors.white,
                                                            title: const Text(
                                                                "Deleting Notification",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17.0,
                                                                    fontFamily:
                                                                        "Poppins-Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black)),
                                                            content: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          10.0),
                                                              child:
                                                                  const LinearProgressIndicator(
                                                                minHeight: 5,
                                                                valueColor:
                                                                    AlwaysStoppedAnimation(
                                                                        Colors
                                                                            .black),
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  },
                                                  child: const Text("Yes",
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontFamily:
                                                              "Poppins-Regular",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.blue))),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("No",
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontFamily:
                                                              "Poppins-Regular",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.red))),
                                            ]));
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Container(
                                  color: _getColorFromHex("#7338ac")
                                      .withOpacity(0.5),
                                  child: Column(children: [
                                    ListTile(
                                      title: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: (currentUser.id == sEller)
                                                    ? "${notif[index].cus.split(" ")[0]}"
                                                    : "",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: "Poppins-Bold"),
                                              ),
                                              TextSpan(
                                                text: (currentUser.id == sEller)
                                                    ? delete(
                                                        notif[index].status,
                                                        notif[index].notifId)
                                                    : delete1(
                                                        notif[index].status,
                                                        notif[index].notifId),
                                                style: const TextStyle(
                                                    fontFamily:
                                                        "Poppins-Regular"),
                                              ),
                                            ]),
                                      ),
                                      leading: CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            _getColorFromHex("#f0f4ff"),
                                        child: Text(
                                            (currentUser.id == sEller)
                                                ? notif[index].cus[0]
                                                : "A",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    _getColorFromHex("#7338ac"),
                                                fontFamily: "Poppins-Bold")),
                                      ),
                                      subtitle: Text(
                                        timeago.format(
                                            notif[index].timestamp.toDate()),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: "Poppins-Regular",
                                            color: Colors.black54),
                                      ),
                                      trailing: SizedBox(
                                        height: 50.0,
                                        width: 50.0,
                                        child: AspectRatio(
                                            aspectRatio: 16 / 9,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image:
                                                      CachedNetworkImageProvider(
                                                          notif[index]
                                                              .mediaUrl),
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                    if (isTap[index] == true)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Stepper(
                                          currentStep: 0,
                                          onStepCancel: () {},
                                          onStepContinue: () {},
                                          onStepTapped: (int index) {},
                                          steps: <Step>[
                                            Step(
                                              title: const Text('Step 1 title'),
                                              content: Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: const Text(
                                                      'Content for Step 1')),
                                            ),
                                            const Step(
                                              title: Text('Step 2 title'),
                                              content:
                                                  Text('Content for Step 2'),
                                            ),
                                          ],
                                        ),
                                      )
                                  ])),
                            ));
                      },
                    ),
                    // ignore: missing_return
                    onRefresh: () {
                      n();
                      return Future(() => false);
                    }));
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
