import 'package:app_chatting/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchController> {
  final List<Widget> friends = List.generate(
    20,
    (index) => ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.black26,
        child: Image.asset(
          'assets/logo/noimage.png',
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        'Orang ke ${index + 1}',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        'Orang${index + 1}@gmail.com',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: GestureDetector(
        onTap: () => Get.toNamed(Routes.CHAT_ROOM),
        child: Chip(
          label: Text('message'),
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          backgroundColor: Colors.teal,
          title: Text('Search'),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back),
          ),
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(30, 40, 30, 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextField(
                controller: controller.searchC,
                cursorColor: Colors.teal,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 1,
                      )),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 1,
                      )),
                  hintText: 'Search',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  suffixIcon: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {},
                    child: Icon(
                      Icons.search,
                      color: Colors.teal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        preferredSize: Size.fromHeight(130),
      ),
      body: friends.length == 0
          ? Center(
              child: Container(
                width: Get.width * 0.7,
                height: Get.width * 0.7,
                child: Lottie.asset('assets/lottie/empty.json'),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: friends.length,
              itemBuilder: (context, index) => friends[index],
            ),
    );
  }
}
