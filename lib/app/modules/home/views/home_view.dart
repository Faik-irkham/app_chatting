import 'package:app_chatting/app/controllers/auth_controller.dart';
import 'package:app_chatting/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Material(
            elevation: 5,
            child: Container(
              margin: EdgeInsets.only(top: context.mediaQueryPadding.top),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black26,
                  ),
                ),
              ),
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Material(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.teal,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => Get.toNamed(Routes.PROFILE),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: controller.chatsStream(authC.user.value.email!),
              builder: (context, snapshot1) {
                if (snapshot1.connectionState == ConnectionState.active) {
                  var listDocsChats = snapshot1.data!.docs;
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: listDocsChats.length,
                    itemBuilder: (context, index) {
                      return StreamBuilder<
                          DocumentSnapshot<Map<String, dynamic>>>(
                        stream: controller
                            .friendStream(listDocsChats[index]["connection"]),
                        builder: (context, snapshot2) {
                          if (snapshot2.connectionState ==
                              ConnectionState.active) {
                            var data = snapshot2.data!.data();
                            return data!["status"] == ""
                                ? ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                    onTap: () => Get.toNamed(Routes.CHAT_ROOM),
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.black26,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: data["photoUrl"] == "noImage"
                                            ? Image.asset(
                                                'assets/logo/noimage.png',
                                                fit: BoxFit.cover,
                                              )
                                            : Image.network(
                                                '${data["photoUrl"]}',
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    title: Text(
                                      '${data["name"]}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: listDocsChats[index]
                                                ["total_unread"] ==
                                            0
                                        ? SizedBox()
                                        : Chip(
                                          backgroundColor: Colors.teal,
                                            label: Text(
                                                '${listDocsChats[index]["total_unread"]}'),
                                          ),
                                  )
                                : ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                    onTap: () => Get.toNamed(Routes.CHAT_ROOM),
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.black26,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: data["photoUrl"] == "noImage"
                                            ? Image.asset(
                                                'assets/logo/noimage.png',
                                                fit: BoxFit.cover,
                                              )
                                            : Image.network(
                                                '${data["photoUrl"]}',
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    title: Text(
                                      '${data["name"]}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${data["status"]}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: listDocsChats[index]
                                                ["total_unread"] ==
                                            0
                                        ? SizedBox()
                                        : Chip(
                                          backgroundColor: Colors.teal,
                                            label: Text(
                                                '${listDocsChats[index]["total_unread"]}'),
                                          ),
                                  );
                          }
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => Get.toNamed(Routes.SEARCH),
        child: Icon(
          Icons.search_rounded,
          size: 30,
        ),
      ),
    );
  }
}
