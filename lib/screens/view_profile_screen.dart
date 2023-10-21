import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/auth/login_screen.dart';
import 'package:we_chat/widgets/chat_user_card.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery
        .of(context)
        .size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Profile Screen'),
        ),
        body: Column(
          children: [
            SizedBox(height: size.height * 0.03),
            Center(
              child: Stack(
                children: [
                 ClipRRect(
                    borderRadius: BorderRadius.circular(size.height * 0.1),
                    child: CachedNetworkImage(
                      width: size.height * 0.2,
                      height: size.height * 0.2,
                      fit: BoxFit.fill,
                      imageUrl: widget.user.image,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Text(widget.user.email),
            SizedBox(height: size.height * 0.03),
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                  children: [
              TextSpan(text: " About : ",style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: widget.user.about)
            ]),
            ),
            Spacer(),
            Padding(
              padding:  EdgeInsets.only(bottom: size.height * 0.03),
              child: RichText(text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                TextSpan(text: " Joined in : ",style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: MyDateUtil.getCreatedUser(context: context, time: widget.user.createdAt))
              ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
