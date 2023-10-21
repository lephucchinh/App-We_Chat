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
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/auth/login_screen.dart';
import 'package:we_chat/widgets/chat_user_card.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Profile Screen'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await APIs.auth.signOut();
            await GoogleSignIn().signOut().then((value) {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            });
          },
          icon: const Icon(
            Icons.logout,
          ),
          label: const Text(
            'Logout',
          ),
        ),
        body: Form(
          key: _formkey,
          child: Column(
            children: [
              SizedBox(height: size.height * 0.03),
              Center(
                child: Stack(
                  children: [
                    _image != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(size.height * 0.1),
                            child: Image.file(
                              File(_image!),
                              width: size.height * 0.2,
                              height: size.height * 0.2,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius.circular(size.height * 0.1),
                            child: CachedNetworkImage(
                              width: size.height * 0.2,
                              height: size.height * 0.2,
                              fit: BoxFit.fill,
                              imageUrl: widget.user.image,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            _buildShowModalBottomSheet(context, size);
                          },
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: Icon(Icons.edit),
                        ))
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Text(widget.user.email),
              SizedBox(height: size.height * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                child: TextFormField(
                  onSaved: (val) => APIs.me.name = val ?? '',
                  validator: (val) =>
                      val != null && val.isNotEmpty ? null : 'Required Field',
                  initialValue: widget.user.name,
                  decoration: InputDecoration(
                    label: const Text('name'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                child: TextFormField(
                  onSaved: (val) => APIs.me.about = val ?? '',
                  validator: (val) =>
                      val != null && val.isNotEmpty ? null : 'Required Field',
                  initialValue: widget.user.about,
                  decoration: InputDecoration(
                    label: const Text('about'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: Icon(
                      Icons.info_outline,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.05),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: const StadiumBorder(),
                    minimumSize: Size(size.width * .5, size.height * .06)),
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    _formkey.currentState!.save();
                    log('inside validator');
                    APIs.updateUserInfo().then((value) {
                      Dialogs.showSnackbar(
                          context, 'Profile Updated Successfully!');
                    });
                  }
                },
                icon: const Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'UPDATE',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _buildShowModalBottomSheet(BuildContext context, Size size) {
    return showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              SizedBox(
                height: size.height * 0.03,
              ),
              const Text(
                'Pick profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
// Pick an image.
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        log('Image Path: ${image.path} -- MimeType: ${image.mimeType}');
                        setState(() {
                          _image = image.path;
                        });
                        APIs.updateProfilePicture(File(_image!));
                        // for hiding bottom sheet
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/add-photo.png'),
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      fixedSize: Size(size.width * 0.25, size.width * 0.25),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
// Pick an image.
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        log('Image Path: ${image.path}');
                        setState(() {
                          _image = image.path;
                        });
                        APIs.updateProfilePicture(File(_image!));
                        // for hiding bottom sheet
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/camera.png'),
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      fixedSize: Size(size.width * 0.25, size.width * 0.25),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
            ],
          );
        });
  }
}
