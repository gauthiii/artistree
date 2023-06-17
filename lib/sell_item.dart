// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'dart:io';

import 'package:artistree/progress.dart';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:string_validator/string_validator.dart';

import './home.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  final ImagePicker picker = ImagePicker();
  final ImageCropper cropper = ImageCropper();
  TextEditingController seller = TextEditingController();
  TextEditingController item = TextEditingController();
  TextEditingController desc = TextEditingController();
  String category = "For Her";
  TextEditingController cash = TextEditingController();
  TextEditingController link = TextEditingController();

  @override
  void initState() {
    super.initState();

    link.text = "https://www.instagram.com/artis__tree/";
  }

  String i = "";
  String s = "";
  String d = "";
  String c = "";

  String dropdownValue = "For Her";
  List cat = [
    "For Her",
    "For Him",
    "Dad",
    "Mom",
    "Brother",
    "Sister",
    "Friend",
  ];

  File? file;
  File? backup;
  bool isUploading = false;
  String postId = Uuid().v4();

  handleTakePhoto() async {
    Navigator.pop(context);
    XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = File(file!.path);
    });
    _cropImage(0);
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = File(file!.path);
    });

    var ln = List.from(file!.path.split('.').reversed);
    var ls = ln[0];

    if (ls != "gif") _cropImage(0);
  }

  _cropImage(n) async {
    CroppedFile? croppedFile = await cropper.cropImage(
      sourcePath: (n == 0) ? file!.path : backup!.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.grey[900],
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        )
      ],
    );
    if (croppedFile != null) {
      setState(() {
        if (n == 0) {
          backup = file;
        }
        file = File(croppedFile.path);
      });
    }
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          title: const Text("Sell an Item",
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Poppins-Bold",
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          children: <Widget>[
            SimpleDialogOption(
                onPressed: handleTakePhoto,
                child: const Text("Photo with Camera",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Poppins-Regular",
                        fontWeight: FontWeight.bold,
                        fontSize: 14))),
            SimpleDialogOption(
                onPressed: handleChooseFromGallery,
                child: const Text("Image from Gallery",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Poppins-Regular",
                        fontWeight: FontWeight.bold,
                        fontSize: 14))),
            SimpleDialogOption(
              child: const Text("Cancel",
                  style: TextStyle(
                      color: Color.fromRGBO(183, 28, 28, 1),
                      fontFamily: "Poppins-Regular",
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Scaffold buildSplashScreen() {
    return Scaffold(
        backgroundColor: _getColorFromHex("#f0f4ff"),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: _getColorFromHex("#7338ac"),
          title: const Text(
            "Sell an Item",
            style: TextStyle(),
          ),
        ),
        body: Center(
          child: SizedBox(
            height: 200,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: DottedBorder(
                    color: _getColorFromHex("#7338ac"),
                    strokeWidth: 1.5,
                    dashPattern: const [8, 1],
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: _getColorFromHex("#f0f4ff"),
                      ),
                      onPressed: () {
                        selectImage(context);
                      },
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              child: const Text("",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins-Regular")),
                            ),
                            SizedBox(
                              height: 70,
                              width: 100,
                              child: Icon(
                                Icons.file_upload,
                                size: 64,
                                color: _getColorFromHex("#7338ac"),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              child: Text("\nUpload image",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: _getColorFromHex("#7338ac"),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins-Regular")),
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
            ),
          ),
        ));
  }

  clearImage() {
    setState(() {
      file = null;
      isUploading = false;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());

    var ln = List.from(file!.path.split('.').reversed);
    var ls = ln[0];

    File compressedImageFile;
    print("*************************** FILE EXT $ls************************");
    if (ls == "jpg" || ls == "jpeg") {
      compressedImageFile = File('$path/img_$postId.jpg')
        ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 85));
    } else if (ls == "gif") {
      compressedImageFile = File('$path/img_$postId.gif')
        ..writeAsBytesSync(Im.encodeGif(imageFile!, samplingFactor: 8));
    } else if (ls == "png") {
      compressedImageFile = File('$path/img_$postId.png')
        ..writeAsBytesSync(Im.encodePng(imageFile!, level: 5));
    } else if (ls == "tiff") {
      compressedImageFile = File('$path/img_$postId.svg')
        ..writeAsBytesSync(Im.encodeTiff(
          imageFile!,
        ));
    } else {
      compressedImageFile = File('$path/img_$postId.jpg')
        ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 85));
    }

    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    var ln = List.from(imageFile.path.split('.').reversed);
    var ls = ln[0];

    if (ls == "jpg" ||
        ls == "jpeg" ||
        ls == "png" ||
        ls == "gif" ||
        ls == "tiff") {
      print("***its there****");
      TaskSnapshot uploadTask =
          await storageRef.child("post_$postId.$ls").putFile(
              imageFile,
              SettableMetadata(
                contentType: 'image/$ls',
              ));

      String downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } else {
      print("***not there****");
      return "";
    }
  }

  createPostInFirestore(
      {required String mediaUrl,
      required String seller,
      required String item,
      required String cash,
      required String link,
      required String description}) {
    final DateTime timestamp1 = DateTime.now();
    postsRef.doc(sEller).collection("userPosts").doc(postId).set({
      "postId": postId,
      "seller": seller,
      "item": item,
      "mediaUrl": mediaUrl,
      "description": description,
      "link": link,
      "isBought": false,
      "cash": cash,
      "timestamp": timestamp1,
      "category": category
    });
  }

  fun() {
    showDialog(
        context: context,
        builder: (_) => const AlertDialog(
              title: Text("POST UPLOADED!!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "JustAnotherHand",
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              // content:  Text("You gotta follow atleast one user to see the timeline.Find some users to follow.Don't be a loner dude!!!!",style:TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white)),
            ));
  }

  // ignore: duplicate_ignore, duplicate_ignore
  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);

    createPostInFirestore(
      mediaUrl: mediaUrl,
      seller: seller.text,
      item: item.text,
      cash: cash.text,
      link: link.text,
      description: desc.text,
    );

    seller.clear();
    item.clear();
    cash.clear();
    desc.clear();
    link.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    Navigator.pop(context);

    // ignore: use_build_context_synchronously
    showDialog(
        context: context,
        builder: (_) => const AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Item Uploaded!!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ));
  }

  getDetails() {
    setState(() {
      i = item.text;
      c = cash.text;
      s = seller.text;
      d = desc.text;
    });
  }

  Future<String> apiCallLogic() async {
    getDetails();

    return Future.value("Hello World");
  }

  WillPopScope buildUploadForm() {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        clearImage();
        return Future(() => false);
      },
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: _getColorFromHex("#7338ac"),
            leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: clearImage),
            title: const Text(
              "Sell an Item",
              style: TextStyle(),
            ),
            actions: [
              TextButton(
                  onPressed: isUploading
                      ? null
                      : () {
                          if (seller.text.trim() != "" &&
                              item.text.trim() != "" &&
                              cash.text.trim() != "" &&
                              desc.text.trim() != "" &&
                              link.text.trim() != "") {
                            if (isURL(link.text.trim()) &&
                                isNumeric(cash.text.trim())) {
                              handleSubmit();
                            } else {
                              var e = "";
                              setState(() {
                                if (isURL(link.text.trim()) == false) {
                                  e = "${e}Insta link must be a valid URL\n";
                                }
                                if (isNumeric(cash.text.trim()) == false) {
                                  e = "$e\nPrice must contain only digits\n(Only Integers - no decimals)";
                                }
                              });

                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: const Text("Error",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: "Poppins-Bold",
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                        content: Text(e,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Poppins-Regular",
                                                color: Colors.black)),
                                      ));
                            }
                          } else {
                            var e = "";
                            setState(() {
                              if (seller.text.trim() == "") {
                                e = "${e}Seller Name\n";
                              }
                              if (item.text.trim() == "") e = "${e}Item Name\n";
                              if (cash.text.trim() == "") e = "${e}Price\n";
                              if (desc.text.trim() == "") {
                                e = "${e}Description\n";
                              }
                              if (link.text.trim() == "") {
                                e = "${e}Insta Link\n";
                              }
                            });

                            print("${seller.text.length}");

                            print("e: " + e);

                            showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: const Text("Error",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: "Poppins-Bold",
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                      content: Text("${e}Can't be blank !!!",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontFamily: "Poppins-Regular",
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                    ));
                          }
                        },
                  child: const Icon(
                    Icons.file_upload,
                    color: Colors.white,
                  )),
            ],
          ),
          backgroundColor: _getColorFromHex("#f0f4ff"),
          body: FutureBuilder(
              future: apiCallLogic(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: <Widget>[
                      Container(height: 5),
                      Container(
                        child: isUploading ? linearProgress() : const Text(""),
                      ),
                      Container(height: 5),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(children: [
                            Center(
                                child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.4 *
                                        0.9,
                                    child: Card(
                                      elevation: 10,
                                      color: _getColorFromHex("#7338ac"),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(0.0)),
                                      child: GestureDetector(
                                          onTap: () {
                                            _cropImage(1);
                                          },
                                          child: Container(
                                              padding: const EdgeInsets.all(8),
                                              child: AspectRatio(
                                                  aspectRatio: 5 / 5,
                                                  child: Image.file(file!,
                                                      fit: BoxFit.fill)))),
                                    ))),
                            Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: ListView(children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: DropdownButton<String>(
                                      dropdownColor:
                                          _getColorFromHex("#f0f4ff"),
                                      value: dropdownValue,
                                      icon: const Text(
                                        " ( Tap to change the category )",
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black54,
                                            fontFamily: "Poppins-Regular"),
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: const TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.black,
                                          fontFamily: "Poppins-Regular"),
                                      underline: Container(
                                        height: 1,
                                        color: Colors.black,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropdownValue = newValue!;
                                        });
                                      },
                                      items: <String>[
                                        "For Her",
                                        "For Him",
                                        "Dad",
                                        "Mom",
                                        "Brother",
                                        "Sister",
                                        "Friend",
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          onTap: () {
                                            setState(() {
                                              category = value;
                                            });
                                            print(category);
                                          },
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          i = value;
                                        });
                                      },
                                      style: const TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.black,
                                          fontFamily: "Poppins-Regular"),
                                      controller: item,
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1.0),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1.0),
                                        ),
                                        labelText: "Item Name",
                                        labelStyle: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black54,
                                            fontFamily: "Poppins-Regular"),
                                        hintText: "Enter Item Name",
                                        hintStyle: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black54,
                                            fontFamily: "Poppins-Regular"),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          s = value;
                                        });
                                      },
                                      style: const TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.black,
                                          fontFamily: "Poppins-Regular"),
                                      controller: seller,
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1.0),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1.0),
                                        ),
                                        labelText: "Seller Name",
                                        labelStyle: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black54,
                                            fontFamily: "Poppins-Regular"),
                                        hintText: "Enter Seller Name",
                                        hintStyle: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black54,
                                            fontFamily: "Poppins-Regular"),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          d = value;
                                        });
                                      },
                                      style: const TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.black,
                                          fontFamily: "Poppins-Regular"),
                                      controller: desc,
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1.0),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1.0),
                                        ),
                                        labelText: "Description",
                                        labelStyle: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black54,
                                            fontFamily: "Poppins-Regular"),
                                        hintText: "Enter Description",
                                        hintStyle: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black54,
                                            fontFamily: "Poppins-Regular"),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          c = value;
                                        });
                                      },
                                      style: const TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.black,
                                          fontFamily: "Poppins-Regular"),
                                      controller: cash,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1.0),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1.0),
                                        ),
                                        labelText: "Cost",
                                        labelStyle: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black54,
                                            fontFamily: "Poppins-Regular"),
                                        hintText: "Enter Cost",
                                        hintStyle: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black54,
                                            fontFamily: "Poppins-Regular"),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: TextFormField(
                                      style: const TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.black,
                                          fontFamily: "Poppins-Regular"),
                                      controller: link,
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1.0),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1.0),
                                        ),
                                        labelText: "Instagram Link",
                                        labelStyle: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black54,
                                            fontFamily: "Poppins-Regular"),
                                        hintText: "Enter Insta link url",
                                        hintStyle: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black54,
                                            fontFamily: "Poppins-Regular"),
                                      ),
                                    ),
                                  ),
                                ]))
                          ]))
                    ],
                  );
                } else {
                  return const Text('Some error happened');
                }
              })),
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return file == null ? buildSplashScreen() : buildUploadForm();
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
