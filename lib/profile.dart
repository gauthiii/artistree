import 'package:artistree/progress.dart';
import 'package:artistree/terms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'alert.dart';
import 'home.dart';
import 'main.dart';
import 'models/exit.dart';
import 'models/user.dart';
import 'orders_screen.dart';

class Profile extends StatefulWidget {
  final String id;
  const Profile({super.key, required this.id});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool edit = false;

  bool isLoading = false;

  late UserX u;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  final _formKey4 = GlobalKey<FormState>();
  final _formKey5 = GlobalKey<FormState>();

  final _formKey6 = GlobalKey<FormState>();
  final _formKey7 = GlobalKey<FormState>();

  bool loc = false;

  TextEditingController mob = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController locationController2 = TextEditingController();
  TextEditingController locationController3 = TextEditingController();
  TextEditingController locationController4 = TextEditingController();
  TextEditingController locationController5 = TextEditingController();

  submit() {
    usersRef.doc(u.id).update({
      "mobile": mob.text,
      "email": email.text,
      "displayName": name.text,
      "door": locationController.text,
      "street": locationController2.text,
      "locality": locationController3.text,
      "city": locationController4.text,
      "zip": locationController5.text
    });
    setState(() {
      edit = false;
    });
    getn();

    notify("New Alert for ${currentUser.displayName}",
        "Your profile has been updated");
  }

  fun() {
    showDialog(
        context: context,
        builder: (_) => const AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Details Saved !!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ));

    Navigator.pop(context);
  }

  fun1() {
    showDialog(
        context: context,
        builder: (_) => const AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Fields can't be blank !!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ));
  }

  perm() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled =
        await GeolocatorPlatform.instance.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.

      print('Location services are disabled.');
      return false;
    }

    permission = await GeolocatorPlatform.instance.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await GeolocatorPlatform.instance.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.

        print('Location permissions are denied');

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      print(
          'Location permissions are permanently denied, we cannot request permissions.');

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    print('All good');
    return true;
  }

  getUserLocation() async {
    setState(() {
      loc = true;
    });

    final hasPermission = await perm();

    if (!hasPermission) {
      print("****************No PERMSSSS*******************");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];

    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print(completeAddress);
    print(placemark.subThoroughfare);
    print(placemark.thoroughfare);
    print(placemark.subLocality);
    print(placemark.locality);
    print(placemark.subAdministrativeArea);
    print(placemark.administrativeArea);
    print(placemark.postalCode);
    print(placemark.country);
    String formattedAddress =
        "${placemark.subThoroughfare},${placemark.thoroughfare},${placemark.subLocality},${placemark.locality},${placemark.subAdministrativeArea},${placemark.administrativeArea},${placemark.postalCode},${placemark.country}";
    print(formattedAddress);
    setState(() {
      locationController.text = placemark.subThoroughfare!;
      locationController2.text = placemark.thoroughfare!;
      locationController3.text = placemark.subLocality!;
      locationController4.text = placemark.locality!;
      locationController5.text = placemark.postalCode!;
      loc = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getn();
  }

  getn() async {
    setState(() {
      isLoading = true;
    });

    await analytics.logEvent(
      name: "profile_page",
      parameters: {
        "button_clicked": "true",
        "email": currentUser.email,
        "displayName": currentUser.displayName,
        "id": currentUser.id,
        "timestamp": DateTime.now().toString(),
      },
    );

    DocumentSnapshot doc = await usersRef.doc(currentUser.id).get();
    u = UserX.fromDocument(doc);

    setState(() {
      mob.text = u.mobile;
      name.text = u.displayName;
      email.text = u.email;
      locationController.text = u.door;
      locationController2.text = u.street;
      locationController3.text = u.locality;
      locationController4.text = u.city;
      locationController5.text = u.zip;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == true) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: _getColorFromHex("#f0f4ff"),
          body: circularProgress());
    } else if (edit == false) {
      return WillPopScope(
        child: Scaffold(
          backgroundColor: _getColorFromHex("#f0f4ff"),
          body: RefreshIndicator(
              child: ListView(children: [
                const Text("\n"),
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
                                    child: Text(u.displayName[0],
                                        style: TextStyle(
                                            fontSize: 45,
                                            fontWeight: FontWeight.w700,
                                            color: _getColorFromHex("#7338ac"),
                                            fontFamily: "Poppins-Bold")),
                                  ),
                                )),
                            Expanded(
                                flex: 5,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(u.displayName,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  _getColorFromHex("#f0f4ff"),
                                              fontFamily: "Poppins-Bold")),
                                      Text("+91-${u.mobile}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  _getColorFromHex("#f0f4ff"),
                                              fontFamily: "Poppins-Bold")),
                                      Text(u.email,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  _getColorFromHex("#f0f4ff"),
                                              fontFamily: "Poppins-Bold")),
                                    ])),
                            Expanded(
                                flex: 1,
                                child: GestureDetector(
                                    child: const Center(
                                        child: Icon(
                                      Icons.edit,
                                      size: 25,
                                      color: Colors.white,
                                    )),
                                    onTap: () {
                                      setState(() {
                                        edit = true;
                                      });
                                    })),
                          ],
                        ))),
                Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.topLeft,
                      height: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                          "\nBilling Address :\n${u.door},\n${u.street},\n${u.locality},\n${u.city}-${u.zip}",
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontFamily: "Poppins-Regular")),
                    ),
                    Divider(
                      thickness: 0.7,
                      color: _getColorFromHex("#7338ac"),
                    )
                  ],
                ),
                GestureDetector(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: const Text("My Orders",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontFamily: "Poppins-Regular")),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: _getColorFromHex("#7338ac"),
                          ),
                        ),
                        Divider(
                          thickness: 0.7,
                          color: _getColorFromHex("#7338ac"),
                        )
                      ],
                    ),
                    onTap: () {
                      print(currentUser.displayName);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Corders(),
                        ),
                      );
                    }),
                GestureDetector(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: const Text("Terms and Conditions",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontFamily: "Poppins-Regular")),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: _getColorFromHex("#7338ac"),
                          ),
                        ),
                        Divider(
                          thickness: 0.7,
                          color: _getColorFromHex("#7338ac"),
                        )
                      ],
                    ),
                    onTap: () {
                      print(currentUser.displayName);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Terms(text: "terms"),
                        ),
                      );
                    }),
                GestureDetector(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: const Text("FAQ",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontFamily: "Poppins-Regular")),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: _getColorFromHex("#7338ac"),
                          ),
                        ),
                        Divider(
                          thickness: 0.7,
                          color: _getColorFromHex("#7338ac"),
                        )
                      ],
                    ),
                    onTap: () {
                      print(currentUser.displayName);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Terms(text: "faq"),
                        ),
                      );
                    }),
              ]),
              onRefresh: () {
                getn();
                return Future(() => false);
              }),
        ),
        onWillPop: () {
          exitButton(context);
          return Future(() => false);
        },
      );
    } else {
      return WillPopScope(
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: _getColorFromHex("#f0f4ff"),
          body: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              Column(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 25.0),
                    child: Center(
                      child: Text(
                        "Edit your personal details",
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins-Regular"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey6,
                      autovalidateMode: AutovalidateMode.always,
                      child: TextFormField(
                        style: const TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Poppins-Regular"),
                        controller: name,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          labelText: "Name",
                          labelStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                          hintText: "Enter Name",
                          hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey7,
                      autovalidateMode: AutovalidateMode.always,
                      child: TextFormField(
                        style: const TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Poppins-Regular"),
                        controller: email,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          labelText: "Email",
                          labelStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                          hintText: "Enter Email ID",
                          hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: TextFormField(
                        style: const TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Poppins-Regular"),
                        validator: (val) {
                          if (val?.trim().length != 10) {
                            return "Invalid Number";
                          } else {
                            return null;
                          }
                        },
                        controller: mob,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          labelText: "Mobile Number",
                          labelStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                          hintText: "Enter a valid number",
                          hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey1,
                      autovalidateMode: AutovalidateMode.always,
                      child: TextFormField(
                        style: const TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Poppins-Regular"),
                        controller: locationController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          labelText: "Door Number",
                          labelStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                          hintText: "Enter Door Number",
                          hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey2,
                      autovalidateMode: AutovalidateMode.always,
                      child: TextFormField(
                        style: const TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Poppins-Regular"),
                        controller: locationController2,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          labelText: "Street",
                          labelStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                          hintText: "Enter Street Name",
                          hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey3,
                      autovalidateMode: AutovalidateMode.always,
                      child: TextFormField(
                        style: const TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Poppins-Regular"),
                        controller: locationController3,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          labelText: "Locality",
                          labelStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                          hintText: "Enter Locality Name",
                          hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey4,
                      autovalidateMode: AutovalidateMode.always,
                      child: TextFormField(
                        style: const TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Poppins-Regular"),
                        controller: locationController4,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          labelText: "City",
                          labelStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                          hintText: "Enter City",
                          hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey5,
                      autovalidateMode: AutovalidateMode.always,
                      child: TextFormField(
                        style: const TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Poppins-Regular"),
                        controller: locationController5,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          labelText: "Zip Code",
                          labelStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                          hintText: "Enter Zip Code",
                          hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                  ),
                  (loc == false)
                      ? Container(
                          width: 300.0,
                          height: 100.0,
                          alignment: Alignment.center,
                          child: ElevatedButton.icon(
                            label: const Text(
                              "Use Current Location",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Poppins-Regular"),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              backgroundColor: Colors.black,
                            ),
                            onPressed: getUserLocation,
                            icon: const Icon(
                              Icons.my_location,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Column(children: [circularProgress(), Text("")]),
                  GestureDetector(
                    onTap: () {
                      if (mob.text == "" ||
                          name.text == "" ||
                          email.text == "" ||
                          locationController.text == "" ||
                          locationController2.text == "" ||
                          locationController3.text == "" ||
                          locationController4.text == "" ||
                          locationController5.text == "")
                        fun1();
                      else
                        submit();
                    },
                    child: Container(
                      height: 50.0,
                      width: 350.0,
                      decoration: BoxDecoration(
                        color: _getColorFromHex("#7338ac"),
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: const Center(
                        child: Text(
                          "Save Details",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 300.0,
                    height: 100.0,
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      label: const Text(
                        "No Changes",
                        style: TextStyle(
                            color: Colors.white, fontFamily: "Poppins-Regular"),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        backgroundColor: Colors.red[900],
                      ),
                      onPressed: () {
                        setState(() {
                          edit = false;
                          loc = false;
                        });
                      },
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        onWillPop: () {
          exitButton(context);
          return Future(() => false);
        },
      );
    }
  }
}

edit() {}

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
