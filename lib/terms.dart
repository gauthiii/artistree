import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Terms extends StatelessWidget {
  final String text;
  Terms({required this.text});
  List<String> terms = [
    "By accessing and using the ArtisTree shopping app, you agree to comply with these terms and conditions.",
    "The ArtisTree app is intended for purchasing products only. Any unauthorized use of the app is strictly prohibited.",
    "We reserve the right to modify or update these terms and conditions at any time without prior notice. It is your responsibility to review them periodically.",
    "All content available on the ArtisTree app, including but not limited to product descriptions, images, and prices, is provided for informational purposes only.",
    "We strive to provide accurate and up-to-date information, but we do not guarantee the accuracy, completeness, or reliability of any content on the app.",
    "ArtisTree reserves the right to refuse service, terminate accounts, or cancel orders at our discretion, including cases of suspected fraudulent activity or violation of these terms.",
    "The use of the ArtisTree app is subject to applicable laws and regulations. You agree not to engage in any unlawful activities or violate the rights of others while using the app.",
    "ArtisTree may contain links to third-party websites or services that are not owned or controlled by us. We are not responsible for the content or practices of any third-party websites or services.",
    "Your personal information and data will be handled in accordance with our Privacy Policy. By using the ArtisTree app, you consent to the collection, use, and storage of your personal information as described in the Privacy Policy.",
    "In no event shall ArtisTree, its affiliates, or its partners be liable for any direct, indirect, incidental, consequential, or punitive damages arising out of your use or inability to use the app.",
  ];
  List<String> faqQ = [
    "How can I download and install the ArtisTree app on my device?",
    "What types of products are available on the ArtisTree app?",
    "How can I search for specific products on the ArtisTree app?",
    "What payment methods are accepted on the ArtisTree app?",
    "What is the shipping policy for ArtisTree orders?",
    "Can I return or exchange products purchased through the ArtisTree app?",
    "How can I contact customer support for assistance?",
    "Is my personal information secure on the ArtisTree app?",
    "Can I sell my own artwork or crafts on the ArtisTree app?",
    "Are there any additional fees or charges associated with using the ArtisTree app?",
  ];
  List<String> faqA = [
    "You can download and install the ArtisTree app by visiting the respective app store for your device (e.g., Apple App Store or Google Play Store) and searching for \"ArtisTree\".",
    "ArtisTree offers a wide range of products, including home decor, art supplies, handmade crafts, and unique gifts from various artists and artisans.",
    "You can use the search bar within the app to enter keywords, such as product names or categories, to find specific items. You can also browse through different categories and collections for inspiration.",
    "ArtisTree currently accepts major credit cards, debit cards, and popular mobile payment options such as Apple Pay and Google Pay. We prioritize security and ensure all transactions are encrypted and secure.",
    "We offer standard shipping options, and the shipping costs and delivery times may vary based on your location and the products you order. You can find detailed shipping information during the checkout process.",
    "Yes, ArtisTree has a return and exchange policy. If you are not satisfied with your purchase, please contact our customer support within [X] days of receiving the order for assistance.",
    "You can reach our customer support team by visiting the \"Contact Us\" section of the app, where you will find our email address and possibly a live chat option for immediate assistance.",
    "Yes, ArtisTree takes your privacy and data security seriously. We employ industry-standard measures to protect your personal information. For more details, please refer to our Privacy Policy.",
    "ArtisTree currently operates as a curated marketplace. However, we are always open to discovering new artists and artisans. Please contact our team through the app's \"Sell With Us\" section to discuss potential collaborations.",
    "ArtisTree does not charge any additional fees for using the app. However, please note that certain payment methods may have their own associated transaction fees, which will be communicated during the checkout process.",
  ];
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
            title: Text(
                (text == "faq")
                    ? "Frequently Asked Questions"
                    : "Terms and Conditions",
                style: const TextStyle(
                  fontFamily: "Poppins-Regular",
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center)),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            const Text("Copyright © 2023 ArtisTree™. All rights reserved.",
                style: TextStyle(
                  fontFamily: "Poppins-Regular",
                  //fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 12.0,
                ),
                textAlign: TextAlign.center),
            Container(height: 20),
            for (int i = 0; i < terms.length; i++)
              Column(
                children: [
                  if (text == "terms")
                    Text("${i + 1}. ${terms[i]}\n",
                        style: const TextStyle(
                          fontFamily: "Poppins-Regular",
                          //fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12.0,
                        ),
                        textAlign: TextAlign.start),
                  if (text == "faq")
                    Text("Q: ${faqQ[i]}",
                        style: const TextStyle(
                          fontFamily: "Poppins-Regular",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12.0,
                        ),
                        textAlign: TextAlign.start),
                  if (text == "faq")
                    Text("A: ${faqA[i]}\n",
                        style: const TextStyle(
                          fontFamily: "Poppins-Regular",
                          //fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12.0,
                        ),
                        textAlign: TextAlign.start),
                ],
              ),

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
