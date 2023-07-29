import 'package:chitchat/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  var isSkipIntro = false.obs;
  var isAuth = false.obs;

  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  UserCredential? userCredential;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> firstInitialized() async {
    await autologin().then((value) {
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

  Future<bool> autologin() async {
    // untuk mengubah isAuth => true => auto login
    try {
      final isSignIn = await _googleSignIn.isSignedIn();
      if (isSignIn) {
        return true;
      } else {
        return false;
      }
    } catch (err) {
      return false;
    }
  }

  Future<bool> skipIntro() async {
    // untuk mengubah isSkipIntro => true
    final box = GetStorage();
    if (box.read('skipIntro') != null || box.read('skipIntro') == true) {
      return true;
    }
    return false;
  }

  Future<void> login() async {
    try {
      // untuk handle kebocoran data user sebelum login
      await _googleSignIn.signOut();

      // untuk mendapatkan google account
      await _googleSignIn.signIn().then((value) => _currentUser = value);

      // untuk cek status login user
      final isSignIn = await _googleSignIn.isSignedIn();

      if (isSignIn) {
        // Kondisi berhasil login
        print("Login Success with User:");
        print(_currentUser);

        // untuk mendapatkan Google Auth
        final googleAuth = await _currentUser!.authentication;

        // untuk mendapatkan credential ke firebase Auth
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => userCredential = value);

        print("User credential:");
        print(userCredential);

        // simpan status user pernah login untuk menghindari halaman intro kesekian kali
        final box = GetStorage();
        if (box.read('skipIntro') != null) {
          box.remove('skipIntro');
        }
        box.write('skipIntro', true);

        // masukkan data ke firebase
        CollectionReference users = firestore.collection('users');
        users.doc(_currentUser!.email).set({
          "uid": userCredential!.user!.uid,
          "name": _currentUser!.displayName,
          "email": _currentUser!.email,
          "photoUrl": _currentUser!.photoUrl,
          "status": "",
          "creationTime":
              userCredential!.user!.metadata.creationTime!.toIso8601String(),
          "lastSignInTime":
              userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
          "updateTime": DateTime.now().toIso8601String(),
        });

        // untuk route ke halaman utama
        isAuth.value = true;
        Get.offAllNamed(Routes.HOME);
      } else {
        print("Login Failed");
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
}
