import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/messenger.dart';
import 'package:we_chat/widgets/dialogs/profile_dialog.dart';

import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    final Size mq = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
      //color: Colors.blue,
      elevation: 1,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ChatScreen(
                        user: widget.user,
                      )));
        },
        child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list = data
                      ?.map((e) =>
                          Message.fromJson(e.data() as Map<String, dynamic>))
                      .toList() ??
                  [];
              if (list.isNotEmpty) {
                _message = list[0];
              }

              return ListTile(
                  leading: InkWell(
                    onTap: () {
                      showDialog(context: context, builder: (BuildContext) => profileDialog(user: widget.user,));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .03),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        width: mq.height * 0.055,
                        height: mq.height * 0.055,
                        imageUrl: widget.user.image,
                        //placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                  title: Text(widget.user.name),
                  //last message
                  subtitle: Text(
                    _message != null
                        ?
                    _message?.type == Type.text
                    ? _message!.msg
                    : 'Sent Image ...'
                        : widget.user.about,
                    maxLines: 1,
                  ),
                  //last message time
                  trailing: _message == null
                      ? null //show nothing when no message is send
                      : _message!.read.isEmpty &&
                              _message!.fromId != APIs.user.uid
                          ? // show for unread message
                          Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(15),
                              ),
                            )
                          : Text(
                              MyDateUtil.getLastMessageTime(
                                  context: context, time: _message!.send),
                              style: TextStyle(color: Colors.black54),
                            ));
            }),
      ),
    );
  }
}
