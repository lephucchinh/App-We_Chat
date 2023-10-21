import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/messenger.dart';
import 'package:we_chat/screens/view_profile_screen.dart';
import 'package:we_chat/widgets/messega_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];

  final _textController = TextEditingController();

  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final Size mq = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            appBar: AppBar(
              elevation: 1,
              toolbarHeight: 70,
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(context, mq),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: APIs.getAllMessenger(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          // if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const SizedBox();
                          // if some or all data is loaded then now it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];
                        }

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              reverse: true,
                              shrinkWrap: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessengerCard(
                                  message: _list[index],
                                );
                              });
                        } else {
                          return const Center(
                            child: Text(
                              'Say hi! 🤭',
                              style: TextStyle(fontSize: 20),
                            ),
                          );
                        }
                      }),
                ),
                if (_isUploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                SizedBox(
                  height: mq.height * .03,
                ),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      onBackspacePressed: () {},
                      textEditingController: _textController,
                      config: Config(
                          bgColor: Colors.white,
                          columns: 7,
                          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0)),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _chatInput() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Card(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onTap: () {
                        if (_showEmoji)
                          setState(() => _showEmoji = !_showEmoji);
                      },
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            setState(() => _showEmoji = !_showEmoji);
                          },
                          icon: const Icon(Icons.emoji_emotions),
                          color: Colors.blue,
                        ),
                        hintText: 'type something ...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // picking multiple image
                        final List<XFile> image =
                            await picker.pickMultiImage(imageQuality: 70);

                        // uploading & sending image one by one
                        for (var i in image) {
                          log('Image Path: ${i.path} ');
                          setState(() => _isUploading = true);
                          await APIs.sendChatImage(widget.user, File((i.path)));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blue,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          log('Image Path: ${image.path} ');
                          setState(() => _isUploading = true);
                          await APIs.sendChatImage(
                              widget.user, File((image.path)));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.blue,
                      )),
                ],
              ),
            ),
          ),
        ),
        MaterialButton(
          minWidth: 0,
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              if(_list.isEmpty){
                APIs.sendFirstMessage(widget.user, _textController.text, Type.text);
              }
              else{
                APIs.sendMessage(widget.user, _textController.text, Type.text);

              }
              _textController.text = '';
            }


          },
          color: Colors.blue,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.send,
            color: Colors.white,
          ),
        )
      ],
    );
  }

  InkWell _appBar(BuildContext context, Size mq) {
    return InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: widget.user,)));
        },
        child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list = data
                    ?.map((e) =>
                        ChatUser.fromJson(e.data() as Map<String, dynamic>))
                    .toList() ??
                [];
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.keyboard_backspace)),
                Expanded(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .03),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        width: mq.height * 0.055,
                        height: mq.height * 0.055,
                        imageUrl:
                            list.isNotEmpty ? list[0].image : widget.user.image,
                        //placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    title: Text(
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(list.isNotEmpty
                        ? list[0].isOnline
                            ? 'Online'
                            : MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                        : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive,)
                    ),
                  ),
                ),
              ],
            );
          },
        ));
  }
}
