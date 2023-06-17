// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:artistree/create_account.dart';
import 'package:artistree/main.dart';
import 'package:artistree/models/exit.dart';
import 'package:artistree/orders_screen.dart';
import 'package:artistree/profile.dart';
import 'package:artistree/progress.dart';
import 'package:artistree/sell_item.dart';
import 'package:artistree/sellers.dart';
import 'package:artistree/shopping.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'alert.dart';
import 'cart.dart';
import 'contact.dart';
import 'models/ShoppingItem.dart';
import 'models/item.dart';
import 'models/user.dart';
import 'notifs.dart';

bool isAuth = false;
late UserX currentUser;
final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
String sEller = "117815227641549443600";

final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');
final oRders = FirebaseFirestore.instance.collection('Orders');
final rRef = FirebaseFirestore.instance.collection('reviews');
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final storageRef = FirebaseStorage.instance.ref();
final fmRef = FirebaseMessaging.instance;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FocusNode _focus = FocusNode();
  bool isLoading = false;
  bool isSearch = false;
  bool isEmail = false;
  bool isFilter = false;
  late PageController pageController;
  int pageIndex = 0;
  int cart = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchController = TextEditingController();
  late Timer timer;

  List<GridTile> gridTiles = [];
  List<Item> searchItems = [];
  String type = "NAN";

  late String _email;
  late String _password;
  late String _disp;
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = "";
  bool _isLoading = false;
  bool _isLoginForm = true;

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
  @override
  void initState() {
    super.initState();

    pageController = PageController();
    google();
    check();

    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    debugPrint("Focus: ${_focus.hasFocus}");
  }

  check() async {
    User? user = _firebaseAuth.currentUser;

    if (user != null) {
      setState(() {
        isLoading = true;
      });
      print(
          "**************************EMAIL LOGGED IN******************************");
      DocumentSnapshot doc = await usersRef.doc(user.uid).get();
      currentUser = UserX.fromDocument(doc);
      setupToken();

      setState(() {
        isLoading = false;
        isAuth = true;
        _errorMessage = "";
        _isLoading = false;
        _isLoginForm = true;
        timer =
            Timer.periodic(const Duration(seconds: 1), (Timer t) => getCart());
      });
    }
  }

  google() {
    setState(() {
      isLoading = true;
    });

    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');

      /* showDialog(
          context: context,
          builder: (context) {
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pop(true);
            });
            return const AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  "PLEASE SIGN IN",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins-Regular",
                      color: Colors.black),
                ),
                content: Text("Choose any of the 3 methods !!!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14.0,
                        // fontWeight: FontWeight.bold,
                        fontFamily: "Poppins-Regular",
                        color: Colors.black)));
          });*/

      setState(() {
        isLoading = false;
      });
    });
  }

  handleSignIn(account) async {
    if (account != null) {
      print('User signed in!: $account');
      await analytics.logEvent(
        name: "signin_successful",
        parameters: {
          "type": "google",
          "email": account.email,
          "displayName": account.displayName,
          "id": account.id,
          "timestamp": DateTime.now().toString(),
        },
      );
      await createUserInFirestore(account);

      setState(() {
        isAuth = true;
        isLoading = false;
        print(
            "*********************************CURRENT USER IS ${currentUser.displayName}*********************************************");
      });
      setupToken();
      timer =
          Timer.periodic(const Duration(seconds: 1), (Timer t) => getCart());
    }
  }

  createUserInFirestore(account) async {
    DocumentSnapshot doc = await usersRef.doc(account.id).get();

    if (!doc.exists) {
      String mobile = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CreateAccount(
                  name: account.displayName.split(" ")[0].toString())));

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.doc(account.id).set({
        "id": account.id,
        "cart": [],
        "sellerId": sEller,
        "mobile": mobile.split("|")[0],
        "photoUrl": account.photoUrl,
        "email": account.email,
        "displayName": account.displayName,
        "door": mobile.split("|")[1],
        "street": mobile.split("|")[2],
        "locality": mobile.split("|")[3],
        "city": mobile.split("|")[4],
        "zip": mobile.split("|")[5],
        "timestamp": DateTime.now()
      });

      doc = await usersRef.doc(account.id).get();
    }

    currentUser = UserX.fromDocument(doc);
    cart = currentUser.cart.length;
  }

  @override
  Widget build(BuildContext context) {
    return (isAuth)
        ? authScreen()
        : (isEmail)
            ? signup()
            : unAuthScreen();
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel the timer when the widget is disposed
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: const Duration(milliseconds: 200), curve: Curves.bounceOut);
  }

  clearSearch() {
    setState(() {
      searchController.clear();
      _focus.unfocus();
      isSearch = false;
      searchItems = [];
      gridTiles = [];
    });
  }

  getCart() async {
    DocumentSnapshot doc = await usersRef.doc(currentUser.id).get();

    setState(() {
      currentUser = UserX.fromDocument(doc);
      cart = currentUser.cart.length;
    });
  }

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
                searchItems.sort(
                    (a, b) => num.parse(b.cash).compareTo(num.parse(a.cash)));
              } else if (i == 1) {
                searchItems.sort(
                    (a, b) => num.parse(a.cash).compareTo(num.parse(b.cash)));
              } else if (i == 2) {
                searchItems.sort((a, b) => a.timestamp.compareTo(b.timestamp));
              } else if (i == 3) {
                searchItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              } else if (i == filterData.length - 1) {
                handlesearch();
              }

              gridTiles = [];
              // ignore: avoid_function_literals_in_foreach_calls
              searchItems.forEach((post) {
                gridTiles.add(GridTile(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2.5, vertical: 2.5),
                        child: Card(
                            elevation: 2,
                            shape: const RoundedRectangleBorder(
                              side: BorderSide.none,
                            ),
                            child: G(
                                post: post,
                                x: type,
                                y: searchController.text.trim(),
                                mode: "small")))));
              });

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

  handlesearch() async {
    setState(() {
      searchItems = [];
      isSearch = true;
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(sEller)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      List<Item> items =
          snapshot.docs.map((doc) => Item.fromDocument(doc)).toList();

      // items.sort((a, b) => a.seller.compareTo(b.seller));

      if (searchController.text.trim() == "") {
        searchItems = items;
      } else {
        setState(() {
          type = "item";
        });
        for (int i = 0; i < items.length; i++) {
          if (items[i]
              .item
              .toUpperCase()
              .contains(searchController.text.trim().toUpperCase())) {
            searchItems.add(items[i]);
          }
        }

        if (searchItems.isEmpty) {
          setState(() {
            type = "seller";
          });
          for (int i = 0; i < items.length; i++) {
            if (items[i]
                .seller
                .toUpperCase()
                .contains(searchController.text.trim().toUpperCase())) {
              searchItems.add(items[i]);
            }
          }
        }

        if (searchItems.isEmpty) {
          setState(() {
            type = "category";
          });
          for (int i = 0; i < items.length; i++) {
            if (items[i]
                .category
                .toUpperCase()
                .contains(searchController.text.trim().toUpperCase())) {
              searchItems.add(items[i]);
            }
          }
        }

        if (searchItems.isEmpty) {
          setState(() {
            type = "description";
          });
          for (int i = 0; i < items.length; i++) {
            if (items[i]
                .description
                .toUpperCase()
                .contains(searchController.text.trim().toUpperCase())) {
              searchItems.add(items[i]);
            }
          }
        }
      }
      gridTiles = [];
      // ignore: avoid_function_literals_in_foreach_calls
      searchItems.forEach((post) {
        gridTiles.add(GridTile(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
                child: Card(
                    elevation: 2,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide.none,
                    ),
                    child: G(
                        post: post,
                        x: type,
                        y: searchController.text.trim(),
                        mode: "small")))));
      });
    });

    print(
        "*************************************${searchItems.length}****************************");

    setState(() {
      isLoading = false;
    });
  }

  searchResult() {
    return WillPopScope(
      onWillPop: () {
        setState(() {
          if (isSearch) {
            isSearch = false;
            isFilter = false;
            searchItems = [];
          }
        });
        return Future(() => false);
      },
      child: (isLoading)
          ? circularProgress()
          : SizedBox(
              child: ListView(children: [
              (searchController.text.trim() == '')
                  ? const SizedBox(
                      height: 0,
                      width: 0,
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 8),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Search results for ${type.toUpperCase()} : ${searchController.text.trim()}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  //   color: _getColorFromHex("#7338ac"),
                                  color: Colors.black,
                                  fontFamily: "Poppins-Regular",
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(width: 0)
                          ])),
              Container(
                padding: const EdgeInsets.all(2),
                child: (gridTiles.isEmpty)
                    ? Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                            backgroundColor: Colors.white,
                                            title: const Text(
                                              "SENT SUCCESSFULLY !",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 17.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Poppins-Regular",
                                                  color: Colors.black),
                                            ),
                                            content: Text(
                                                "Your search request for '${searchController.text.trim()}' has been sent to Artis_Tree !!!",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 14.0,
                                                    // fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        "Poppins-Regular",
                                                    color: Colors.black))));
                                  },
                                  child: const Text(
                                    "Request for items",
                                    style: TextStyle(
                                      fontFamily: "Poppins-Regular",
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 15.0,
                                    ),
                                  ))),
                          Container(height: 20),
                        ],
                      ))
                    : GridView(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: 2,
                          childAspectRatio: 0.7 *
                              ((MediaQuery.of(context).size.height) / 800),
                          mainAxisSpacing: 2,
                          crossAxisCount: 2,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        children: gridTiles,
                      ),
              ),
            ])),
    );
  }

  authScreen() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75.0), // here the desired height
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu,
                  size: 40), // change this size and style
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            centerTitle: true,
            backgroundColor: _getColorFromHex("#f0f4ff"),
            elevation: 0,
            iconTheme: IconThemeData(
              color: _getColorFromHex("#7338ac"),
            ),
            title: TextFormField(
              focusNode: _focus,
              autofocus: false,
              style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins-Regular"),
              controller: searchController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  borderSide:
                      BorderSide(color: _getColorFromHex("#7338ac"), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(color: _getColorFromHex("#7338ac")),
                ),
                contentPadding: const EdgeInsets.all(8),
                hintText: "Search an item...",
                hintStyle: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.black54,
                    fontFamily: "Poppins-Regular"),
                filled: true,
                suffixIcon:
                    (_focus.hasFocus || searchController.text.isNotEmpty)
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: _getColorFromHex("#7338ac"),
                            ),
                            onPressed: clearSearch,
                          )
                        : IconButton(
                            icon: Icon(
                              Icons.search,
                              color: _getColorFromHex("#7338ac"),
                            ),
                            onPressed: () {
                              setState(() {
                                searchController.text =
                                    searchController.text.trim();
                              });
                              handlesearch();
                            },
                          ),
              ),
              onChanged: (val) {
                setState(() {
                  isSearch = false;
                });
                Future.delayed(const Duration(seconds: 2), () async {
                  // handlesearch();
                });
              },
              onFieldSubmitted: (val) async {
                setState(() {
                  val = val.trim();
                  searchController.text = searchController.text.trim();
                });

                await analytics.logEvent(
                  name: "search_bar_entry",
                  parameters: {
                    "button_clicked": "true",
                    "entry_value": val,
                    "user_email": currentUser.email,
                    "timestamp": DateTime.now().toString(),
                  },
                );

                handlesearch();
              },
            ),
            actions: [
              (!_focus.hasFocus && currentUser.id != sEller)
                  ? GestureDetector(
                      child: Stack(children: [
                        Image.asset(
                          'images/cart.png',
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 24, top: 4),
                            child: Text(cart.toString(),
                                style: TextStyle(
                                    fontFamily: "Poppins-Bold",
                                    fontSize: 16,
                                    color: _getColorFromHex("#7338ac"))))
                      ]),
                      onTap: () {
                        var c = currentUser.cart;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Cart(cart: c),
                          ),
                        );
                      })
                  : Container(width: 0)
            ],
          )),
      backgroundColor: _getColorFromHex("#f0f4ff"),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          (isSearch && pageIndex == 0) ? searchResult() : const Shopping(),
          (isSearch && pageIndex == 1) ? searchResult() : const Notifs(),
          (isSearch && pageIndex == 2)
              ? searchResult()
              : Profile(id: currentUser.id),
        ],
      ),
      bottomNavigationBar: (isSearch)
          ? null
          : ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
              child: BottomNavigationBar(
                  elevation: 20,
                  iconSize: 30,
                  backgroundColor: Colors.white,
                  currentIndex: pageIndex,
                  onTap: onTap,
                  unselectedItemColor: _getColorFromHex("#635ad9"),
                  selectedItemColor: _getColorFromHex("#7338ac"),
                  selectedLabelStyle:
                      const TextStyle(fontSize: 13, fontFamily: "Poppins-Bold"),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 13, fontFamily: "Poppins-Regular"),
                  items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        label: "Home",
                        activeIcon: Icon(Icons.home)),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.notifications_active_outlined),
                        label: "Notifs",
                        activeIcon: Icon(Icons.notifications_active)),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.account_circle_outlined),
                        label: "Account",
                        activeIcon: Icon(Icons.account_circle)),
                  ]),
            ),
      floatingActionButton: (searchItems.isEmpty)
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
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                filterData[i],
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: (filterText ==
                                                            filterData[i])
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
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
                (isFilter == true) ? "images/setting.png" : "images/filter.png",
                color: _getColorFromHex("#7338ac"),
                height: 24,
              ),
            ),
      drawer: WillPopScope(
          onWillPop: () {
            Navigator.pop(context);
            return Future(() => false);
          },
          child: Drawer(
              backgroundColor: _getColorFromHex("#f0f4ff"),
              child: ListView(padding: EdgeInsets.zero, children: <Widget>[
                Container(
                  color: _getColorFromHex("#7338ac"),
                  child: DrawerHeader(
                      margin: const EdgeInsets.only(bottom: 0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: _getColorFromHex("#f0f4ff"),
                                child: Text(currentUser.displayName[0],
                                    style: TextStyle(
                                        fontSize: 45,
                                        fontWeight: FontWeight.w700,
                                        color: _getColorFromHex("#7338ac"),
                                        fontFamily: "Poppins-Bold")),
                              ),
                            ),
                            Center(
                              child: Text(
                                  "Hello ${currentUser.displayName.split(" ")[0]}",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: _getColorFromHex("#f0f4ff"),
                                      fontFamily: "Poppins-Bold")),
                            ),
                          ])),
                ),
                ListTile(
                    title: const Text('Orders',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontFamily: "Poppins-Bold")),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Corders(),
                        ),
                      );
                    }),
                Divider(
                  thickness: 0.7,
                  color: _getColorFromHex("#7338ac"),
                ),
                ListTile(
                    title: const Text('Sellers',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontFamily: "Poppins-Bold")),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Sellers(),
                        ),
                      );
                    }),
                Divider(
                  thickness: 0.7,
                  color: _getColorFromHex("#7338ac"),
                ),
                ListTile(
                    title: Text(
                        (currentUser.id == sEller)
                            ? 'Sell an Item'
                            : 'Contact Us',
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontFamily: "Poppins-Bold")),
                    onTap: () async {
                      if (currentUser.id == sEller) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Upload(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Contact(),
                          ),
                        );
                      }
                    }),
                Divider(
                  thickness: 0.7,
                  color: _getColorFromHex("#7338ac"),
                ),
                ListTile(
                    title: const Text('Logout',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontFamily: "Poppins-Bold")),
                    onTap: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            Future.delayed(const Duration(seconds: 3), () {
                              Navigator.of(context).pop(true);
                            });
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: const Text("Logging out!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              content: Container(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: const LinearProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.black),
                                ),
                              ),
                            );
                          });

                      Future.delayed(const Duration(seconds: 3), () async {
                        googleSignIn.signOut();
                        _firebaseAuth.signOut();

                        setState(() {
                          isAuth = false;
                          isEmail = false;
                          isLoading = false;
                          isSearch = false;
                          pageIndex = 0;
                          pageController = PageController();
                          cart = 0;
                          searchController.clear();
                        });
                        timer.cancel();
                        await analytics.logEvent(
                          name: "signout_google",
                          parameters: {
                            "button_clicked": "true",
                            "user_email": currentUser.email,
                            "timestamp": DateTime.now().toString(),
                          },
                        );
                      });
                    }),
                Divider(
                  thickness: 0.7,
                  color: _getColorFromHex("#7338ac"),
                ),
              ]))),
    );
  }

  // ignore: non_constant_identifier_names
  google_sign_in() {
    setState(() {
      isLoading = true;
    });
    googleSignIn.signIn();

    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      print(account?.email);
      print(account?.displayName);
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
  }

  unAuthScreen() {
    return WillPopScope(
        child: Scaffold(
            backgroundColor: _getColorFromHex("#f0f4ff"),
            body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/1.jpeg"), fit: BoxFit.cover),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(height: 150),
                      Center(
                          child:
                              Image.asset("images/gift-box.png", height: 128)),
                      Container(height: 70),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getColorFromHex("#f0f4ff"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  side: const BorderSide(color: Colors.black)),
                            ),
                            onPressed: () async {
                              await analytics.logEvent(
                                name: "signin_with_facebook",
                                parameters: {
                                  "button_clicked": "true",
                                  "timestamp": DateTime.now().toString(),
                                },
                              );
                              showDialog(
                                  context: context,
                                  builder: (_) => const AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: Text("NOT POSSIBLE",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Poppins-Bold",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                        content: Text(
                                            "Facebook Authentication has been disabled cause Mark Zuckerberg suxxxxx",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                fontFamily: "Poppins-Regular",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                      ));
                            },
                            child: const Text(
                              "Sign in with Facebook",
                              style: TextStyle(
                                fontFamily: "Poppins-Regular",
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                          )),
                      Container(height: 10),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getColorFromHex("#f0f4ff"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  side: const BorderSide(color: Colors.black)),
                            ),
                            onPressed: () async {
                              await analytics.logEvent(
                                name: "signin_with_google",
                                parameters: {
                                  "button_clicked": "true",
                                  "timestamp": DateTime.now().toString(),
                                },
                              );
                              google_sign_in();
                            },
                            child: const Text(
                              "Sign in with Google",
                              style: TextStyle(
                                fontFamily: "Poppins-Regular",
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                          )),
                      Container(height: 10),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getColorFromHex("#f0f4ff"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  side: const BorderSide(color: Colors.black)),
                            ),
                            onPressed: () async {
                              setState(() {
                                isEmail = true;
                              });
                              await analytics.logEvent(
                                name: "signin_with_email",
                                parameters: {
                                  "button_clicked": "true",
                                  "timestamp": DateTime.now().toString(),
                                },
                              );
                            },
                            child: const Text(
                              "Log In / Sign Up",
                              style: TextStyle(
                                fontFamily: "Poppins-Regular",
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                          )),
                      (isLoading)
                          ? Column(
                              children: [
                                Container(height: 10),
                                circularProgress()
                              ],
                            )
                          : const SizedBox(height: 0, width: 0)
                    ]))),
        onWillPop: () {
          setState(() {
            if (isLoading) {
              isLoading = false;
            } else {
              exitButton(context);
            }
          });
          return Future(() => false);
        });
  }

  Widget signup() {
    fun1() {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text("ACCOUNT CREATED",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                content: Text("EMAIL\n$_email\nPASSWORD\n$_password",
                    style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ));
    }

    funx1() {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                backgroundColor: Colors.white,
                title: const Text("ERROR",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: "Poppins-Bold",
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                content: Text(_errorMessage,
                    style: const TextStyle(
                        fontSize: 14.0,
                        fontFamily: "Poppins-Regular",
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ));
    }

    // Check if form is valid before perform login or signup
    bool validateAndSave() {
      final form = _formKey.currentState;
      if (form!.validate()) {
        form.save();
        return true;
      }
      return false;
    }

    // Perform login or signup
    void validateAndSubmit() async {
      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });
      if (validateAndSave()) {
        String userId = "";
        try {
          if (_isLoginForm) {
            UserCredential result = await _firebaseAuth
                .signInWithEmailAndPassword(email: _email, password: _password);
            User? id = result.user;
            userId = id!.uid;
            print('Signed in: $userId ');

            print(id.email);
            print(id.displayName);
            print(id.uid);
            print(id.photoURL);

            {
              DocumentSnapshot doc = await usersRef.doc(id.uid).get();

              if (!doc.exists) {
                // 2) if the user doesn't exist, then we want to take them to the create account page
                String mobile = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateAccount(
                            name: _disp.split(" ")[0].toString())));

                // 3) get username from create account, use it to make new user document in users collection
                usersRef.doc(id.uid).set({
                  "id": id.uid,
                  "cart": [],
                  "sellerId": sEller,
                  "mobile": mobile.split("|")[0],
                  "photoUrl": "User",
                  "email": id.email,
                  "displayName": _disp,
                  "door": mobile.split("|")[1],
                  "street": mobile.split("|")[2],
                  "locality": mobile.split("|")[3],
                  "city": mobile.split("|")[4],
                  "zip": mobile.split("|")[5],
                  "timestamp": DateTime.now()
                });

                doc = await usersRef.doc(id.uid).get();
              }

              currentUser = UserX.fromDocument(doc);
              print(currentUser);
              print(currentUser.displayName);
            }

            setupToken();

            setState(() {
              isAuth = true;
              timer = Timer.periodic(
                  const Duration(seconds: 1), (Timer t) => getCart());
            });
          } else {
            UserCredential result =
                await _firebaseAuth.createUserWithEmailAndPassword(
                    email: _email, password: _password);
            //widget.auth.sendEmailVerification();
            //_showVerifyEmailSentDialog();
            User? id = result.user;
            userId = id!.uid;
            print('Signed up user: $userId ');

            fun1();
          }
          setState(() {
            _isLoading = false;
          });

          if (userId.length > 0 && _isLoginForm) {}
        } catch (e) {
          print('Error: $e');

          setState(() {
            _isLoading = false;
            _errorMessage = e.toString().split("] ")[1];
            _formKey.currentState?.reset();
          });
          funx1();
        }
      } else {
        setState(() {
          _errorMessage = "Invalid Data Entry. Entry can\'t be NULL";
        });

        funx1();

        _isLoading = false;
      }
    }

    void resetForm() {
      _formKey.currentState?.reset();
      _errorMessage = "";
    }

    void toggleFormMode() {
      resetForm();
      setState(() {
        _isLoginForm = !_isLoginForm;
      });
    }

    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        setState(() {
          isEmail = false;
        });
        return Future(() => false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/1.jpeg"), fit: BoxFit.cover),
          ),
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Container(height: 120),
                  Image.asset(
                    "images/gift-box.png",
                    height: 120,
                    //   color: _getColorFromHex("#4c004c"),
                  ),
                  Container(
                    height: 20,
                  ),
                  !_isLoginForm
                      ? TextFormField(
                          maxLines: 1,
                          keyboardType: TextInputType.name,
                          autofocus: false,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(color: Colors.black54),
                            hintText: 'Display Name',
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Display Name can\'t be empty'
                              : null,
                          onSaved: (value) => _disp = value!.trim(),
                        )
                      : const Text(""),
                  const Text(""),
                  TextFormField(
                    maxLines: 1,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: false,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Colors.black54),
                      hintText: 'Email',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Email can\'t be empty' : null,
                    onSaved: (value) => _email = value!.trim(),
                  ),
                  const Text(""),
                  TextFormField(
                    maxLines: 1,
                    obscureText: true,
                    autofocus: false,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Password can\'t be empty' : null,
                    onSaved: (value) => _password = value!.trim(),
                  ),
                  const Text(""),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getColorFromHex("#f0f4ff"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: const BorderSide(color: Colors.black)),
                      ),
                      onPressed: validateAndSubmit,
                      child: Text(_isLoginForm ? 'Login' : 'Create account',
                          style: const TextStyle(
                            fontFamily: "Poppins-Regular",
                            color: Colors.black,
                            fontSize: 15.0,
                          )),
                    ),
                  ),
                  const Text(""),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: GestureDetector(
                      onTap: toggleFormMode,
                      child: Text(
                          _isLoginForm
                              ? 'New User? Create an account'
                              : 'Have an account? Sign in',
                          style: const TextStyle(
                            fontFamily: "Poppins-Regular",
                            color: Colors.black,
                            fontSize: 15.0,
                          ),
                          textAlign: TextAlign.center),
                    ),
                  ),
                  const Text(""),
                  (_isLoading == true) ? circularProgress() : const Text("")
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> setupToken() async {
    NotificationSettings settings = await fmRef.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Get the token each time the application loads
    String? token = await fmRef.getToken();

    // Save the initial token to the database
    await saveTokenToDatabase(token!);

    // Any time the token refreshes, store this in the database too.
    fmRef.onTokenRefresh.listen(saveTokenToDatabase);
  }
}

Future<void> saveTokenToDatabase(String token) async {
  // Assume user is logged in for this example

  await usersRef.doc(currentUser.id).update({
    // 'tokens': FieldValue.arrayUnion([token]),
    'androidNotificationToken': token
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("on message: $message\n");
    final String recipientId = message.data['recipient'];
    final String? body = message.notification?.body;
    print("body: $body");
    if (recipientId == currentUser.id) {
      print("notification shown");
      notify("New Alert for ${currentUser.displayName}", body);
    }
  });
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
