import 'package:artistree/progress.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class CreateAccount extends StatefulWidget {
  final String name;
  const CreateAccount({super.key, required this.name});

  @override
  // ignore: library_private_types_in_public_api
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  final _formKey4 = GlobalKey<FormState>();
  final _formKey5 = GlobalKey<FormState>();

  bool loc = false;

  TextEditingController mob = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController locationController2 = TextEditingController();
  TextEditingController locationController3 = TextEditingController();
  TextEditingController locationController4 = TextEditingController();
  TextEditingController locationController5 = TextEditingController();
  String username = "";

  submit() {
    username =
        "${mob.text}|${locationController.text}|${locationController2.text}|${locationController3.text}|${locationController4.text}|${locationController5.text}";

    Navigator.pop(context, username);
    fun();
  }

  fun() {
    showDialog(
        context: context,
        builder: (_) => const AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              "DETAILS SAVED SUCCESSFULLY !!!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins-Regular",
                  color: Colors.black),
            ),
            content: Text("Proceed to the homepage",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.0,
                    // fontWeight: FontWeight.bold,
                    fontFamily: "Poppins-Regular",
                    color: Colors.black))));

    Navigator.pop(context);
  }

  fun1() {
    showDialog(
        context: context,
        builder: (_) => const AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              "ERROR",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins-Regular",
                  color: Colors.black),
            ),
            content: Text("Fields can't be blank !!!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.0,
                    // fontWeight: FontWeight.bold,
                    fontFamily: "Poppins-Regular",
                    color: Colors.black))));
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
    locationController.text = placemark.subThoroughfare!;
    locationController2.text = placemark.thoroughfare!;
    locationController3.text = placemark.subLocality!;
    locationController4.text = placemark.locality!;
    locationController5.text = placemark.postalCode!;

    setState(() {
      loc = false;
    });
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _getColorFromHex("#f0f4ff"),
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        /*   leading: GestureDetector(
          child: Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
          },
        ),*/
        automaticallyImplyLeading: false,
        title: const Text(
          "Enter the following the details",
          style: TextStyle(),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
        children: <Widget>[
          Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: Center(
                  child: Text(
                    "Enter your mobile number",
                    style: TextStyle(
                        fontSize: 17.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins-Regular"),
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
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
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
              const Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: Center(
                  child: Text(
                    "Enter your billing address",
                    style: TextStyle(
                        fontSize: 17.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins-Regular"),
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
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
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
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
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
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
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
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
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
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        label: const Text(
                          "Use Current Location",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Poppins-Regular"),
                        ),
                        onPressed: getUserLocation,
                        icon: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Column(
                      children: [circularProgress(), Container(height: 20)]),
              GestureDetector(
                onTap: () {
                  if (mob.text == "" ||
                      locationController.text == "" ||
                      locationController2.text == "" ||
                      locationController3.text == "" ||
                      locationController4.text == "" ||
                      locationController5.text == "") {
                    fun1();
                  } else {
                    submit();
                  }
                },
                child: Container(
                  height: 50.0,
                  width: 250.0,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: const Center(
                    child: Text(
                      "Submit",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Container(height: 20)
            ],
          )
        ],
      ),
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
