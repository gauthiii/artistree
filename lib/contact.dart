import 'package:artistree/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home.dart';
import 'models/user.dart';

class Contact extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  CS createState() => CS();
}

class CS extends State<Contact> {
  bool isLoading = false;
  List<UserX> u = [];

  @override
  void initState() {
    super.initState();
    getn();
  }

  getn() async {
    setState(() {
      isLoading = true;
      u = [];
    });

    DocumentSnapshot doc = await usersRef.doc(sEller).get();

    setState(() {
      u.add(UserX.fromDocument(doc));
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _getColorFromHex("#f0f4ff"),
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios,
                  size: 30, color: _getColorFromHex("#7338ac")),
              onPressed: () => Navigator.of(context).pop(),
            ),
            elevation: 0,
            backgroundColor: _getColorFromHex("#f0f4ff"),
            centerTitle: true,
            title: const Text("Contact Us",
                style: TextStyle(
                  fontFamily: "Poppins-Regular",
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center)),
        body: (isLoading)
            ? circularProgress()
            : ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  const Text(
                      "Copyright © 2023 ArtisTree™. All rights reserved.",
                      style: TextStyle(
                        fontFamily: "Poppins-Regular",
                        //fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 12.0,
                      ),
                      textAlign: TextAlign.center),
                  Container(height: 30),
                  ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                      ),
                      child: Container(
                          padding: EdgeInsets.all(20),
                          width: MediaQuery.of(context).size.width,
                          color: _getColorFromHex("#7338ac"),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: CircleAvatar(
                                      radius: 35,
                                      backgroundColor:
                                          _getColorFromHex("#f0f4ff"),
                                      child: Text(u[0].displayName[0],
                                          style: TextStyle(
                                              fontSize: 45,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  _getColorFromHex("#7338ac"),
                                              fontFamily: "Poppins-Bold")),
                                    ),
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(u[0].displayName,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    _getColorFromHex("#f0f4ff"),
                                                fontFamily: "Poppins-Bold")),
                                        Text("+91-${u[0].mobile}",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    _getColorFromHex("#f0f4ff"),
                                                fontFamily: "Poppins-Bold")),
                                        Text(u[0].email,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    _getColorFromHex("#f0f4ff"),
                                                fontFamily: "Poppins-Bold")),
                                      ])),
                            ],
                          ))),
                  Container(height: 25),
                  const Text("Reach out to us between 10 AM to 6 PM",
                      style: TextStyle(
                        fontFamily: "Poppins-Regular",
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 15.0,
                      ),
                      textAlign: TextAlign.center),
                  Container(height: 25),
                  GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1.6,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Material(
                            color: _getColorFromHex("#f0f4ff"),
                            child: InkWell(
                              onTap: () async {
                                final Uri _url = Uri.parse(
                                    'https://wa.me/91${u[0].mobile}?text=Hello');

                                if (await canLaunchUrl(_url)) {
                                  await launchUrl(_url,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  throw Exception('Could not launch $_url');
                                }
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Image(
                                    image: AssetImage('images/whatsapp.png'),
                                    width: 48,
                                    height: 48,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    child: const Text("Text on Whatsapp",
                                        style: TextStyle(
                                            fontSize: 10,
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
                              onTap: () async {
                                final Uri _url =
                                    Uri.parse('tel:+91${u[0].mobile}');

                                if (await canLaunchUrl(_url)) {
                                  await launchUrl(_url,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  throw Exception('Could not launch $_url');
                                }
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Image(
                                    image: AssetImage('images/phone.png'),
                                    width: 48,
                                    height: 48,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    child: const Text("Call Us",
                                        style: TextStyle(
                                            fontSize: 10,
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
                              onTap: () async {
                                final Uri url = Uri.parse(
                                    "https://www.instagram.com/artis__tree/");

                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  throw Exception('Could not launch $url');
                                }
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Image(
                                    image: AssetImage('images/insta.png'),
                                    width: 48,
                                    height: 48,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    child: const Text("Instagram Profile",
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular")),
                                  ),
                                ],
                              ),
                            )),
                      ]),
                  /*  const Text(
                "Disclaimer: This information is provided for general guidance and should not be considered legal advice. For accurate and personalized legal advice, consult with an intellectual property attorney or legal professional.",
                style: TextStyle(
                  fontFamily: "Poppins-Regular",
                  //fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 12.0,
                ),
                textAlign: TextAlign.start)*/
                ],
              ));
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
