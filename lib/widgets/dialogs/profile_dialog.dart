import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/view_profile_screen.dart';

class profileDialog extends StatefulWidget {
  final ChatUser user;
  const profileDialog({super.key, required this.user, });

  @override
  State<profileDialog> createState() => _profileDialogState();
}

class _profileDialogState extends State<profileDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 10,
        height: 270,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: Colors.white
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.user.name,style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),),
                   InkWell(
                     onTap: () {
                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: widget.user)));
                     },
                       child: Icon(Icons.info_outline,size: 35,color: Colors.black,)
                   ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(150),
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  width: 150,
                  height: 150,
                  imageUrl: widget.user.image,
                  //placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
