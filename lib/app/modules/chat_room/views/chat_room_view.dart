import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/chat_room_controller.dart';

class ChatRoomView extends GetView<ChatRoomController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: InkWell(
          onTap: () => Get.back(),
          borderRadius: BorderRadius.circular(100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 5),
              Icon(Icons.arrow_back),
              SizedBox(width: 5),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey,
                child: Image.asset('assets/logo/noimage.png'),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.teal,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama Anda',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Status anda',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: WillPopScope(
        onWillPop: () {
          if(controller.isShowEmoji.isTrue) {
            controller.isShowEmoji.value = false;
          } else {
            Navigator.pop(context);
          }
          return Future.value(false);
        },
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: ListView(
                  children: [
                    ItemChat(isSender: true),
                    ItemChat(isSender: false),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  bottom: controller.isShowEmoji.isTrue
                      ? 5
                      : context.mediaQueryPadding.bottom),
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              width: Get.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      child: TextField(
                        controller: controller.chatC,
                        focusNode: controller.focusNode,
                        decoration: InputDecoration(
                          prefixIcon: IconButton(
                            onPressed: () {
                              controller.focusNode.unfocus();
                              controller.isShowEmoji.toggle();
                            },
                            icon: Icon(Icons.emoji_emotions_outlined),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Material(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.teal,
                    child: InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(13),
                        child: Icon(
                          Icons.send,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => (controller.isShowEmoji.isTrue)
                  ? Container(
                      height: 250,
                      child: EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          // Do something when emoji is tapped (optional)
                          controller.addEmojiToChat(emoji);
                        },
                        onBackspacePressed: () {
                          // Do something when the user taps the backspace button (optional)
                          controller.deleteEmoji();
                        },
                        // textEditingController:
                        //     textEditionController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                        config: Config(
                          columns: 7,
                          emojiSizeMax: 32 *
                              (Platform.isIOS
                                  ? 1.30
                                  : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                          verticalSpacing: 0,
                          horizontalSpacing: 0,
                          gridPadding: EdgeInsets.zero,
                          initCategory: Category.RECENT,
                          bgColor: Color(0xFFF2F2F2),
                          indicatorColor: Colors.teal,
                          iconColor: Colors.grey,
                          iconColorSelected: Colors.teal,
                          progressIndicatorColor: Colors.teal,
                          backspaceColor: Colors.teal,
                          skinToneDialogBgColor: Colors.white,
                          skinToneIndicatorColor: Colors.grey,
                          enableSkinTones: true,
                          showRecentsTab: true,
                          recentsLimit: 28,
                          noRecents: const Text(
                            'No Recents',
                            style: TextStyle(fontSize: 20, color: Colors.black26),
                            textAlign: TextAlign.center,
                          ),
                          tabIndicatorAnimDuration: kTabScrollDuration,
                          categoryIcons: const CategoryIcons(),
                          buttonMode: ButtonMode.MATERIAL,
                        ),
                      ))
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemChat extends StatelessWidget {
  const ItemChat({
    Key? key,
    required this.isSender,
  }) : super(key: key);

  final bool isSender;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 20,
      ),
      // color: Colors.amber,
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: isSender
                  ? BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    )
                  : BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
            ),
            padding: EdgeInsets.all(15),
            child: Text(
              'Test chat masuk',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 5),
          Text('12.23'),
        ],
      ),
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
    );
  }
}
