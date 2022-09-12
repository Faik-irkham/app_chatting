import 'package:app_chatting/app/data/models/user_model.dart';
import 'package:app_chatting/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  var user = UserModel().obs;

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

        users.doc(_currentUser!.email).update({
          "lastSignInTime":
              userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
        });

        final currUser = await users.doc(_currentUser!.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        user(UserModel(
          uid: currUserData['uid'],
          nama: currUserData['nama'],
          email: currUserData['email'],
          photoUrl: currUserData['photoUrl'],
          status: currUserData['status'],
          creationTime: currUserData['creationTime'],
          lastSignInTime: currUserData['lastSignInTime'],
          updateTime: currUserData['updateTime'],
        ));

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
          users.doc(_currentUser!.email).set({
            "uid": userCredential!.user!.uid,
            "nama": _currentUser!.displayName,
            "email": _currentUser!.email,
            "photoUrl": _currentUser!.photoUrl ?? "NoImage",
            "status": '',
            "creationTime":
                userCredential!.user!.metadata.creationTime!.toIso8601String(),
            "lastSignInTime": userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
            "updateTime": DateTime.now().toIso8601String(),
          });
        } else {
          users.doc(_currentUser!.email).update({
            "lastSignInTime": userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
          });
        }

        final currUser = await users.doc(_currentUser!.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        user(UserModel(
          uid: currUserData['uid'],
          nama: currUserData['nama'],
          email: currUserData['email'],
          photoUrl: currUserData['photoUrl'],
          status: currUserData['status'],
          creationTime: currUserData['creationTime'],
          lastSignInTime: currUserData['lastSignInTime'],
          updateTime: currUserData['updateTime'],
        ));

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

  void changeProfile(String nama, String status) {
    String date = DateTime.now().toIso8601String();

    // update firebase profile
    CollectionReference users = firestore.collection('users');

    users.doc(_currentUser!.email).update({
      "nama": nama,
      "status": status,
      "lastSignInTime":
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      "updateTime": date,
    });

    // update model
    user.update((user) {
      user!.nama = nama;
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
}
