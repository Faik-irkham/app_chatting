import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ChatRoomController extends GetxController {
  //TODO: Implement ChatRoomController
  var isShowEmoji = false.obs;
  int total_unread = 0;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late FocusNode focusNode;
  late TextEditingController chatC;

  void addEmojiToChat(Emoji emoji) {
    chatC.text = chatC.text + emoji.emoji;
  }

  void deleteEmoji() {
    chatC.text = chatC.text.substring(0, chatC.text.length - 2);
  }

  void newChat(String email, Map<String, dynamic> argument, String chat) async {
    CollectionReference chats = firestore.collection("chats");
    CollectionReference users = firestore.collection("users");
    String date = DateTime.now().toIso8601String();

    final newChat =
        await chats.doc(argument["chat_id"]).collection("chat").add({
      "pengirim": email,
      "penerima": argument["friendEmail"],
      "msg": chat,
      "time": date,
      "isRead": false,
    });

    await users.doc(email).collection("chats").doc(argument["chat_id"]).update({
      "lastTime": date,
    });

    final checkChatsFriend = await users
        .doc(argument["friendEmail"])
        .collection("chats")
        .doc(argument["chat_id"])
        .get();

    if (checkChatsFriend.exists) {
      // ada data chat di database penerima
      // cek total unread

      final checkTotalUnread = await chats
          .doc(argument["chat_id"])
          .collection("chat")
          .where("isRead", isEqualTo: false)
          .where("pengirim", isEqualTo: email)
          .get();

      // total unread => penerima
      total_unread = checkTotalUnread.docs.length;

      await users
          .doc(argument["friendEmail"])
          .collection("chats")
          .doc(argument["chat_id"])
          .update({
        "lastTime": date,
        "total_unread": total_unread,
      });
    } else {
      // tdk ada data chat di database penerima
      // new untuk database penerima
      await users
          .doc(argument["friendEmail"])
          .collection("chats")
          .doc(argument["chat_id"])
          .set({
        "connection": email,
        "lastTime": date,
        "total_unread": 1,
      });
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    chatC = TextEditingController();
    focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        isShowEmoji.value = false;
      }
    });
    super.onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    focusNode.dispose();
    chatC.dispose();
    super.dispose();
  }
}
