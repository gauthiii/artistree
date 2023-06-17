import 'package:artistree/main.dart';
import 'package:artistree/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'home.dart';
import 'models/ShoppingItem.dart';

import 'models/item.dart';

class Sellers extends StatefulWidget {
  const Sellers({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ShoppingState createState() => _ShoppingState();
}

class _ShoppingState extends State<Sellers> {
  List<Item> items = [];
  bool isLoading = false;
  List<GridTile> gridTiles = [];
  ScrollController scroll = ScrollController();
  List<List<Item>> sellers = [];

  @override
  void initState() {
    super.initState();

    loadItems();
  }

  loadItems() async {
    await analytics.logEvent(
      name: "sellers_page",
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

  getItems() async {
    QuerySnapshot snapshot = await postsRef
        .doc(sEller)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      items = snapshot.docs.map((doc) => Item.fromDocument(doc)).toList();
      items.sort((a, b) => a.seller.compareTo(b.seller));
      List<Item> tester = [];
      sellers = [];
      items.forEach((item) {
        if (tester.isEmpty) {
          tester.add(item);
        } else if (tester[0].seller.contains(item.seller)) {
          tester.add(item);
        } else {
          sellers.add(tester);
          tester = [];
          tester.add(item);
        }
      });

      List<Item> temp = sellers[0];
      sellers[0] = sellers[2];
      sellers[2] = temp;
    });
  }

  buildPosts(it) {
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
      return list(it);
    }
  }

  Future<String> apiCallLogic() async {
    getItems();

    return Future.value("Hello World");
  }

  list(it) {
    return ListView(
        padding: const EdgeInsets.only(top: 24),
        scrollDirection: Axis.horizontal,
        children: List.generate(it.length, (index) {
          return GestureDetector(
            onTap: () {},
            child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: AspectRatio(
                    aspectRatio: 0.73,
                    child: Card(
                        elevation: 2,
                        child: G(
                            post: it[index],
                            x: "NAN",
                            y: "NAN",
                            mode: "big")))),
          );
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _getColorFromHex("#f0f4ff"),
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios,
                  color: _getColorFromHex("#635ad9")),
              onPressed: () => Navigator.of(context).pop(),
            ),
            elevation: 0,
            backgroundColor: _getColorFromHex("#f0f4ff"),
            centerTitle: true,
            title: Text("Buy Items from Sellers",
                style: TextStyle(
                  fontFamily: "Poppins-Regular",
                  fontWeight: FontWeight.bold,
                  color: _getColorFromHex("#635ad9"),
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center)),
        body: ListView(controller: scroll, children: [
          for (int i = 0; i < sellers.length; i++)
            Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                    height: 50,
                    child: Row(children: [
                      Container(width: 10),
                      Card(
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
                            child: Text(
                              sellers[i][0].seller,
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
              SizedBox(height: 300, child: buildPosts(sellers[i])),
              Container(height: 20),
            ]),
          Container(height: 10),
          Container(height: 20),
        ]));
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
