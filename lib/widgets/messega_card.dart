import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/models/messenger.dart';

class MessengerCard extends StatefulWidget {
  final Message message;

  const MessengerCard({super.key, required this.message});

  @override
  State<MessengerCard> createState() => _MessengerCardState();
}

class _MessengerCardState extends State<MessengerCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    bool isText = widget.message.type == Type.text;
    return InkWell(
      onLongPress: () {
        _ShowModalBottomSheet(isMe, isText);
      },
      child: isMe ? _blueMessage() : _greyMessage(),
    );
  }

  void _ShowModalBottomSheet(bool isMe, bool isText) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        context: context,
        builder: (_) => Container(
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 25),
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  isText
                      ? _OpitionItem(
                          icon: Icons.copy_all,
                          text: 'Copy Text',
                          onTap: () async {
                            await Clipboard.setData(
                                    ClipboardData(text: widget.message.msg))
                                .then((value) {
                              Navigator.pop(context);

                              Dialogs.showSnackbar(context, 'Text Copied!');
                            });
                          },
                          color: Colors.cyan,
                        )
                      : _OpitionItem(
                          icon: Icons.download,
                          text: 'Download Image',
                          onTap: () async {
                            try {
                              await GallerySaver.saveImage(widget.message.msg,
                                      albumName: 'We Chat')
                                  .then((success) {
                                Navigator.pop(context);

                                if (success != null && success) {
                                  Dialogs.showSnackbar(
                                      context, 'Image Successfully Saved!');
                                }
                              });
                            } catch (e) {
                              log('ErrorWhileSavingImg: $e');
                            }
                          },
                          color: Colors.cyan,
                        ),
                  const Divider(),
                  if (isMe && widget.message.type == Type.text)
                    _OpitionItem(
                      icon: Icons.edit,
                      text: 'Edit Message',
                      onTap: () {
                        Navigator.pop(context);
                        _showMessageUpdateDialog();
                      },
                      color: Colors.cyan,
                    ),
                  if (isMe)
                    _OpitionItem(
                      icon: Icons.delete_forever,
                      text: 'Delete Message',
                      onTap: () async {
                        await APIs.deleteMessage(widget.message).then((value) {
                          Navigator.pop(context);

                          Dialogs.showSnackbar(context, 'deleted!');
                        });
                      },
                      color: Colors.red,
                    ),
                  if (isMe)
                    const Divider(),
                  if (isMe)
                    _OpitionItem(
                      icon: Icons.remove_red_eye,
                      text:
                          'Send At: ${MyDateUtil.getFormattedTime(context: context, time: widget.message.send)} - ${MyDateUtil.getCreatedUser(context: context, time: widget.message.send)}',
                      onTap: () {},
                      color: Colors.cyan,
                    ),
                  if (isMe)
                    _OpitionItem(
                      icon: Icons.remove_red_eye,
                      text: widget.message.read.isEmpty
                          ? 'Not read yet'
                          : 'Read At: ${MyDateUtil.getFormattedTime(context: context, time: widget.message.read)} - ${MyDateUtil.getCreatedUser(context: context, time: widget.message.read)}',
                      onTap: () {},
                      color: Colors.green,
                    ),
                  if (isMe == false)
                    _OpitionItem(
                      icon: Icons.remove_red_eye,
                      text:
                          'Send At: ${MyDateUtil.getFormattedTime(context: context, time: widget.message.send)} - ${MyDateUtil.getCreatedUser(context: context, time: widget.message.send)}',
                      onTap: () {},
                      color: Colors.cyan,
                    ),
                  if (isMe == false)
                    _OpitionItem(
                      icon: Icons.remove_red_eye,
                      text: widget.message.read.isEmpty
                          ? 'Not read yet'
                          : 'Read At: ${MyDateUtil.getFormattedTime(context: context, time: widget.message.read)} - ${MyDateUtil.getCreatedUser(context: context, time: widget.message.read)}',
                      onTap: () {},
                      color: Colors.green,
                    ),
                ],
              ),
            ));
  }

  Widget _greyMessage() {
    final Size size = MediaQuery.of(context).size;

    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      log('message read updated ');
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: widget.message.type == Type.text
                ? EdgeInsets.all(MediaQuery.of(context).size.width * 0.04)
                : null,
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.01),
            decoration: widget.message.type == Type.text
                ? BoxDecoration(
                    color: Colors.black12,
                    border: Border.all(
                      color: Colors.black12,
                    ),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30)),
                  )
                : null,
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  )
                : Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.black38,
                        )),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CachedNetworkImage(
                        width: size.height * 0.2,
                        height: size.height * 0.25,
                        fit: BoxFit.fill,
                        imageUrl: widget.message.msg,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image),
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.send),
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        )
      ],
    );
  }

  Widget _blueMessage() {
    final Size size = MediaQuery.of(context).size;

    // update last read message if sender and receiver and different
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.04,
            ),
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all,
                color: Colors.blue,
                size: 20,
              ),
            const SizedBox(
              width: 5,
            ),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.send),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: widget.message.type == Type.text
                ? EdgeInsets.all(MediaQuery.of(context).size.width * 0.04)
                : null,
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.01),
            decoration: widget.message.type == Type.text
                ? BoxDecoration(
                    color: Colors.blue.withOpacity(0.7),
                    border: Border.all(color: Colors.blue.withOpacity(0.7)),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  )
                : null,
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  )
                : Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.black38,
                        )),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CachedNetworkImage(
                        width: size.height * 0.2,
                        height: size.height * 0.25,
                        fit: BoxFit.fill,
                        imageUrl: widget.message.msg,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: Row(
                children: const [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text(' Update Message')
                ],
              ),

              //content
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) {

                  updatedMsg = value;
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                        Navigator.pop(context);

                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),

                //update button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      APIs.updateMessage(widget.message, updatedMsg);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}

class _OpitionItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color color;

  const _OpitionItem(
      {super.key,
      required this.icon,
      required this.text,
      required this.onTap,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(text),
      onTap: onTap,
    );
  }
}
