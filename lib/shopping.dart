import 'dart:async';

import 'package:artistree/main.dart';
import 'package:artistree/progress.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home.dart';
import 'models/ShoppingItem.dart';
import 'models/exit.dart';
import 'models/item.dart';

class Shopping extends StatefulWidget {
  const Shopping({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ShoppingState createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
  List<String> categories = [
    "For Her",
    "For Him",
    "Brother",
    "Sister",
    "Mom",
    "Dad",
    "Friend",
    "Customized",
  ];
  String cat = "nothing";
  List<Item> items = [];
  bool isLoading = false;
  List<GridTile> gridTiles = [];
  ScrollController scroll = ScrollController();

  List<String> filterData = [
    'Price - High to Low',
    'Price - Low to High',
    'Items - Oldest first',
    'Items - Newest first',
    'What\'s new',
    'Discount',
    'Remove Filters',
  ];
  String filterText = "";
  bool isFilter = false;
  searchFilter(i) {
    setState(() {
      isLoading = true;
    });

    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pop(true);
            setState(() {
              if (i == 0) {
                items.sort(
                    (a, b) => num.parse(b.cash).compareTo(num.parse(a.cash)));
              } else if (i == 1) {
                items.sort(
                    (a, b) => num.parse(a.cash).compareTo(num.parse(b.cash)));
              } else if (i == 2) {
                items.sort((a, b) => a.timestamp.compareTo(b.timestamp));
              } else if (i == 3) {
                items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              } else if (i == filterData.length - 1) {
                getItems();
              }

              altergrid();

              if (i != filterData.length - 1) {
                isFilter = true;
                filterText = filterData[i];
              } else {
                isFilter = false;
                filterText = "";
              }
            });

            setState(() {
              isLoading = false;
            });

            showDialog(
                context: context,
                builder: (context) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    Navigator.of(context).pop(true);
                  });
                  return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text(
                        (i == filterData.length - 1)
                            ? 'FILTERS REMOVED'
                            : "FILTER APPLIED",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins-Regular",
                            color: Colors.black),
                      ),
                      content: Text(
                          (i == filterData.length - 1)
                              ? 'Your filters have been removed'
                              : filterData[i],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14.0,
                              // fontWeight: FontWeight.bold,
                              fontFamily: "Poppins-Regular",
                              color: Colors.black)));
                });
          });
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
                (i == filterData.length - 1)
                    ? "Removing Filter"
                    : "Applying Filter",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 17.0,
                    fontFamily: "Poppins-Regular",
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            content: Container(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: const LinearProgressIndicator(
                minHeight: 5,
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();

    loadItems();
  }

  loadItems() async {
    if (mounted) {
      await analytics.logEvent(
        name: "home_page",
        parameters: {
          "button_clicked": "true",
          "email": currentUser.email,
          "displayName": currentUser.displayName,
          "id": currentUser.id,
          "timestamp": DateTime.now().toString(),
        },
      );
      setState(() {
        isLoading = true;
      });
      getItems();
      setState(() {
        isLoading = false;
      });
    }
  }

  getItems() async {
    QuerySnapshot snapshot = await postsRef
        .doc(sEller)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    if (mounted) {
      setState(() {
        items = snapshot.docs.map((doc) => Item.fromDocument(doc)).toList();
      });
    }
  }

  buildPosts() {
    if (isLoading) {
      return circularProgress();
    } else if (items.isEmpty) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 100,
            color: Colors.black,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              " No Posts!!!!!",
              style: TextStyle(
                fontFamily: "Bangers",
                color: Colors.black,
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else {
      return list();
    }
  }

  Future<String> apiCallLogic() async {
    getItems();

    return Future.value("Hello World");
  }

  list() {
    return FutureBuilder(
      future: apiCallLogic(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          return ListView(
              padding: const EdgeInsets.only(top: 24),
              scrollDirection: Axis.horizontal,
              children: List.generate(items.length, (index) {
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: AspectRatio(
                          aspectRatio: 0.73,
                          child: Card(
                              elevation: 2,
                              child: G(
                                  post: items[index],
                                  x: "NAN",
                                  y: "NAN",
                                  mode: "big")))),
                );
              }));
        } else {
          return circularProgress();
        }
      },
    );
  }

  altergrid() {
    setState(() {
      scroll.jumpTo(0);
      gridTiles = [];
      // ignore: avoid_function_literals_in_foreach_calls
      items.forEach((post) {
        if (post.category == cat || cat == "Customized") {
          gridTiles.add(GridTile(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.5, vertical: 2.5),
                  child: Card(
                      elevation: 2,
                      shape: const RoundedRectangleBorder(
                        side: BorderSide.none,
                      ),
                      child:
                          G(post: post, x: "NAN", y: "NAN", mode: "small")))));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: _getColorFromHex("#f0f4ff"),
          body: RefreshIndicator(
              child: ListView(controller: scroll, children: [
                Row(
                    mainAxisAlignment: (cat == "nothing")
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 50,
                          child: Row(children: [
                            Container(width: 10),
                            Card(
                              color: _getColorFromHex("#f0f4ff"),
                              elevation: 0,
                              child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _getColorFromHex("#635ad9"),
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15))),
                                  padding: const EdgeInsets.all(2),
                                  alignment: Alignment.center,
                                  child: Text(
                                    (cat == "nothing") ? "What's New?" : cat,
                                    style: const TextStyle(
                                      fontFamily: "Poppins-Bold",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16.0,
                                    ),
                                  )),
                            ),
                          ])),
                      const SizedBox(
                        height: 0,
                        width: 0,
                      )
                    ]),
                (cat == "nothing")
                    ? Column(children: [
                        SizedBox(height: 300, child: buildPosts()),
                        Container(height: 20),
                        Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.3),
                          child: Card(
                            color: _getColorFromHex("#f0f4ff"),
                            elevation: 0,
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _getColorFromHex("#635ad9"),
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                padding: const EdgeInsets.all(2),
                                alignment: Alignment.center,
                                child: const Text(
                                  "Categories",
                                  style: TextStyle(
                                    fontFamily: "Poppins-Bold",
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                          ),
                        ),
                        Container(height: 10),
                        for (int i = 0; i < 4; i++)
                          Column(children: [
                            Container(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              _getColorFromHex("#88f4ff"),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          elevation: 0,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            cat = categories[(2 * i)];
                                          });
                                          altergrid();
                                        },
                                        child: Text(
                                          categories[(2 * i)],
                                          style: const TextStyle(
                                            fontFamily: "Poppins-Regular",
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontSize: 15.0,
                                          ),
                                        ))),
                                Container(width: 30),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              _getColorFromHex("#88f4ff"),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          elevation: 0,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            cat = categories[(2 * i) + 1];
                                          });
                                          altergrid();
                                        },
                                        child: Text(
                                          categories[(2 * i) + 1],
                                          style: const TextStyle(
                                            fontFamily: "Poppins-Regular",
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontSize: 15.0,
                                          ),
                                        )))
                              ],
                            ),
                            Container(
                              height: 10,
                            )
                          ]),
                      ])
                    : SizedBox(
                        child: SingleChildScrollView(
                        child: (isLoading)
                            ? circularProgress()
                            : Container(
                                padding: const EdgeInsets.all(2),
                                child: (gridTiles.isEmpty)
                                    ? Center(
                                        child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(height: 20),
                                          Image.asset(
                                            "images/gift-box.png",
                                            height: 100,
                                            //   color: _getColorFromHex("#4c004c"),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 20.0),
                                            child: Text(
                                              "No Items in this category!\nClick here to send a request",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  //   color: _getColorFromHex("#7338ac"),
                                                  color: Colors.black,
                                                  fontFamily: "Poppins-Regular",
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Container(height: 20),
                                          SizedBox(
                                              child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.black,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                    elevation: 0,
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            AlertDialog(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                title:
                                                                    const Text(
                                                                  "SENT SUCCESSFULLY !",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          "Poppins-Regular",
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                content: Text(
                                                                    "Your request for items in the category: '$cat' has been sent to Artis_Tree !!!",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: const TextStyle(
                                                                        fontSize: 14.0,
                                                                        // fontWeight: FontWeight.bold,
                                                                        fontFamily: "Poppins-Regular",
                                                                        color: Colors.black))));
                                                  },
                                                  child: const Text(
                                                    "Request for items",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          "Poppins-Regular",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                      fontSize: 15.0,
                                                    ),
                                                  ))),
                                          Container(height: 20),
                                        ],
                                      ))
                                    : GridView(
                                        shrinkWrap: true,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisSpacing: 2,
                                          childAspectRatio: 0.7 *
                                              ((MediaQuery.of(context)
                                                      .size
                                                      .height) /
                                                  800),
                                          mainAxisSpacing: 2,
                                          crossAxisCount: 2,
                                        ),
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        children: gridTiles,
                                      ),
                              ),
                      )),
                Container(height: 30),
                ListTile(
                  onTap: () async {
                    final Uri url =
                        Uri.parse("https://www.instagram.com/artis__tree/");

                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } else {
                      throw Exception('Could not launch $url');
                    }
                    // launch("https://www.instagram.com/artis__tree/");
                  },
                  leading: Image.asset(
                    'images/insta.png',
                    height: 64,
                  ),
                  title: const Text("VISIT THE OFFICIAL INSTAGARAM PAGE",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: "Poppins-Regular",
                      )),
                ),
                Container(height: 20),
              ]),
              onRefresh: () {
                loadItems();
                return Future(() => false);
              }),
          floatingActionButton: (cat == "nothing")
              ? null
              : FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      backgroundColor: _getColorFromHex("#f0f4ff"),
                      context: context,
                      builder: (BuildContext context) {
                        return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: SizedBox(
                              height: (isFilter == true) ? 325 : 285,
                              child: Column(
                                children: <Widget>[
                                  Container(height: 10),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'SORT BY',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13,
                                              // fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular"),
                                        ),
                                        Container(
                                          width: 0,
                                        )
                                      ]),
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 0.5,
                                  ),
                                  for (int i = 0;
                                      i <
                                          ((isFilter == true)
                                              ? filterData.length
                                              : filterData.length - 1);
                                      i++)
                                    InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                          searchFilter(i);
                                        },
                                        child: SizedBox(
                                            height: 40,
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    filterData[i],
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            (filterText ==
                                                                    filterData[
                                                                        i])
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                        fontFamily:
                                                            "Poppins-Regular"),
                                                  ),
                                                  Container(
                                                    width: 0,
                                                  )
                                                ]))),
                                ],
                              ),
                            ));
                      },
                    );
                  },
                  backgroundColor: _getColorFromHex("#f0f4ff"),
                  child: Image.asset(
                    (isFilter == true)
                        ? "images/setting.png"
                        : "images/filter.png",
                    color: _getColorFromHex("#7338ac"),
                    height: 24,
                  ),
                ),
        ),
        onWillPop: () {
          setState(() {
            print("******************BYE****************");
            if (cat == "nothing") {
              exitButton(context);
            } else {
              cat = "nothing";
            }
          });

          return Future(() => false);
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
