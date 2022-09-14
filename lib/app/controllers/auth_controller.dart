import 'package:app_chatting/app/data/models/users_model.dart';
import 'package:app_chatting/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  //TODO: Implement AuthController

  var isSkipIntro = false.obs;
  var isAuth = false.obs;

  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  UserCredential? userCredential;

  var user = UsersModel().obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> firstInitialized() async {
    await autoLogin().then((value) {
      if (value) {
        isAuth.value = true;
      }
    });

    await skipIntro().then((value) {
      if (value) {
        isSkipIntro.value = true;
      }
    });
  }

  Future<bool> skipIntro() async {
    // mengubah isSkipIntro = true
    final box = GetStorage();
    if (box.read('skipIntro') != null || box.read('skipIntro') == true) {
      return true;
    }
    return false;
  }

  Future<bool> autoLogin() async {
    // mengubah isAuth = true => auto login
    try {
      final isSignIn = await _googleSignIn.isSignedIn();
      if (isSignIn) {
        _googleSignIn.signInSilently().then((value) => _currentUser = value);
        final googleAuth = await _currentUser!.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => userCredential = value);

        print('USER CREDENTIAL');
        print(userCredential);

        // masukan data ke database firebase
        CollectionReference users = firestore.collection('users');

        await users.doc(_currentUser!.email).update({
          "lastSignInTime":
              userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
        });

        final currUser = await users.doc(_currentUser!.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        user(UsersModel.fromJson(currUserData));

        return true;
      }
      return false;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<void> login() async {
    // Get.offAllNamed(Routes.HOME);
    // fungsi login dengan google

    try {
      // untuk handle kebocoran data user sebelum login
      await _googleSignIn.signOut();

      // digunakan untuk mendapatkan google account user
      await _googleSignIn.signIn().then((value) => _currentUser = value);

      // untuk mengecek status login user
      final isSignIn = await _googleSignIn.isSignedIn();

      if (isSignIn) {
        // kondisi login berhasil
        print('SUDAH BERHASIL LOGIN DENGAN AKUN :');
        print(_currentUser);

        final googleAuth = await _currentUser!.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => userCredential = value);

        print('USER CREDENTIAL');
        print(userCredential);

        // simpan status user sudah pernah login & tidak akan menampilkan introdution kembali
        final box = GetStorage();
        if (box.read('skipIntro') != null) {
          box.remove('skipIntro');
        }
        box.write('skipIntro', true);

        // masukan data ke database firebase
        CollectionReference users = firestore.collection('users');

        final checkUser = await users.doc(_currentUser!.email).get();

        if (checkUser.data() == null) {
          await users.doc(_currentUser!.email).set({
            "uid": userCredential!.user!.uid,
            "name": _currentUser!.displayName,
            "keyName": _currentUser!.displayName!.substring(0, 1).toUpperCase(),
            "email": _currentUser!.email,
            "photoUrl": _currentUser!.photoUrl ?? "NoImage",
            "status": '',
            "creationTime":
                userCredential!.user!.metadata.creationTime!.toIso8601String(),
            "lastSignInTime": userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
            "updateTime": DateTime.now().toIso8601String(),
            "chats": [],
          });
        } else {
          await users.doc(_currentUser!.email).update({
            "lastSignInTime": userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
          });
        }

        final currUser = await users.doc(_currentUser!.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        user(UsersModel.fromJson(currUserData));

        isAuth.value = true;
        Get.offAllNamed(Routes.HOME);
      } else {
        // kondisi login gagal
        print('TIDAK BERHASIL LOGIN');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> logout() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }

  // Profile

  void changeProfile(String name, String status) {
    String date = DateTime.now().toIso8601String();

    // update firebase profile
    CollectionReference users = firestore.collection('users');

    users.doc(_currentUser!.email).update({
      "name": name,
      "keyName": name.substring(0, 1).toUpperCase(),
      "status": status,
      "lastSignInTime":
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      "updateTime": date,
    });

    // update model
    user.update((user) {
      user!.name = name;
      user.keyName = name.substring(0, 1).toUpperCase();
      user.status = status;
      user.lastSignInTime =
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
      user.updateTime = date;
    });

    user.refresh();
    Get.defaultDialog(
      title: 'SUKSES',
      middleText: 'change profile successfull',
    );
  }

  // update status
  void updateStatus(String status) {
    String date = DateTime.now().toIso8601String();
    // update firebase
    CollectionReference users = firestore.collection('users');

    users.doc(_currentUser!.email).update({
      "status": status,
      "lastSignInTime":
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      "updateTime": date,
    });

    // update model
    user.update((user) {
      user!.status = status;
      user.lastSignInTime =
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
      user.updateTime = date;
    });

    user.refresh();
    Get.defaultDialog(
      title: 'SUKSES',
      middleText: 'update status success',
    );
  }

  // Search

  // fungsi connection chat
  void addNewConnection(String friendEmail) async {
    bool flagNewConnection = false;
    var chat_id;
    String date = DateTime.now().toIso8601String();
    CollectionReference chats = firestore.collection("chats");
    CollectionReference users = firestore.collection("users");

    final docUser = await users.doc(_currentUser!.email).get();
    final docChats = (docUser.data() as Map<String, dynamic>)["chats"] as List;

    if (docChats.length != 0) {
      // user sudah pernah chat dengan siapapun

      docChats.forEach((singleChat) {
        if (singleChat["connection"] == friendEmail) {
          chat_id = singleChat["chat_id"];
        }
      });

      if (chat_id != null) {
        // sudah pernah buat koneksi => friendEmail
        flagNewConnection = false;
      } else {
        // blm pernah buat koneksi => friendEmail
        // buat koneksi baru...
        flagNewConnection = true;
      }
    } else {
      // blm pernah chat dengan siapapun
      // buat koneksi baru...
      flagNewConnection = true;
    }

    if (flagNewConnection) {
      // cek dari chats connections == mereka berdua
      final chatsDocs = await chats.where(
        "connection",
        whereIn: [
          [
            _currentUser!.email,
            friendEmail,
          ],
          [
            friendEmail,
            _currentUser!.email,
          ],
        ],
      ).get();

      if (chatsDocs.docs.length != 0) {
        // terdapat data chats dan tidak buat connection baru
        final chatDataId = chatsDocs.docs[0].id;
        final chatsData = chatsDocs.docs[0].data() as Map<String, dynamic>;

        docChats.add({
          "connection": friendEmail,
          "chat_id": chatDataId,
          "lastTime": chatsData["lastTime"],
          "total_unread": 0,
        });

        await users.doc(_currentUser!.email).update({"chats": docChats});
        user.update((user) {
          user!.chats = docChats as List<ChatUser>;
        });

        chat_id = chatDataId;
        user.refresh();
      } else {
        // tidak ada data chats dan buat connection baru
        final newChatDoc = await chats.add({
          "connection": [
            _currentUser!.email,
            friendEmail,
          ],
          "chat": [],
        });

        docChats.add({
          "connection": friendEmail,
          "chat_id": newChatDoc.id,
          "lastTime": date,
          "total_unread": 0,
        });

        await users.doc(_currentUser!.email).update({"chats": docChats});
        user.update((user) {
          user!.chats = docChats as List<ChatUser>;
        });

        chat_id = newChatDoc.id;
        user.refresh();
      }
    }

    print(chat_id);
    Get.toNamed(Routes.CHAT_ROOM, arguments: chat_id);
  }
}
