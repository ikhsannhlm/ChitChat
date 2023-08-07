import 'package:chitchat/app/data/models/chats_model.dart';
import 'package:chitchat/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../data/models/users_model.dart';

class AuthController extends GetxController {
  var isSkipIntro = false.obs;
  var isAuth = false.obs;

  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  UserCredential? userCredential;

  var user = UsersModel().obs;

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
        await _googleSignIn
            .signInSilently()
            .then((value) => _currentUser = value);
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

        // masukkan data ke firebase
        CollectionReference users = firestore.collection('users');

        await users.doc(_currentUser!.email).update({
          "lastSignInTime":
              userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
        });

        final currUser = await users.doc(_currentUser!.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        user(UsersModel.fromJson(currUserData));

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

        final checkuser = await users.doc(_currentUser!.email).get();

        if (checkuser.data() == null) {
          await users.doc(_currentUser!.email).set({
            "uid": userCredential!.user!.uid,
            "name": _currentUser!.displayName,
            "keyName": _currentUser!.displayName!.substring(0, 1).toUpperCase(),
            "email": _currentUser!.email,
            "photoUrl": _currentUser!.photoUrl ?? "noimage",
            "status": "",
            "creationTime":
                userCredential!.user!.metadata.creationTime!.toIso8601String(),
            "lastSignInTime": userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
            "updatedTime": DateTime.now().toIso8601String(),
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

  //PROFILE

  void changeProfile(String name, String status) {
    String date = DateTime.now().toIso8601String();

    // Update Firebase
    CollectionReference users = firestore.collection('users');
    users.doc(_currentUser!.email).update({
      "name": name,
      "keyName": name.substring(0, 1).toUpperCase(),
      "status": status,
      "lastSignInTime":
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      "updatedTime": date,
    });

    // Update Model
    user.update((user) {
      user!.name = name;
      user.keyName = name.substring(0, 1).toUpperCase();
      user.status = status;
      user.lastSignInTime =
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
      user.updatedTime = date;
    });

    user.refresh();
    Get.defaultDialog(
      title: "Success",
      middleText: "Change Profile Success",
    );
  }

  void updateStatus(String status) {
    String date = DateTime.now().toIso8601String();

    // Update Firebase
    CollectionReference users = firestore.collection('users');
    users.doc(_currentUser!.email).update({
      "status": status,
      "lastSignInTime":
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      "updatedTime": date,
    });

    // Update Model
    user.update((user) {
      user!.status = status;
      user.lastSignInTime =
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
      user.updatedTime = date;
    });

    user.refresh();
    Get.defaultDialog(
      title: "Success",
      middleText: "Update Status Success",
    );
  }

  //SEARCH

  void addNewConnection(String friendEmail) async {
    bool flagNewConnection = false;
    var chat_id;
    String date = DateTime.now().toIso8601String();
    CollectionReference chats = firestore.collection("chats");
    CollectionReference users = firestore.collection("users");

    final docUser = await users.doc(_currentUser!.email).get();
    final docChats = (docUser.data() as Map<String, dynamic>)["chats"] as List;

    if (docChats.length != 0) {
      // User sudah pernah chat dengan siapapun
      docChats.forEach((singleChat) {
        if (singleChat["connections"] == friendEmail) {
          chat_id = singleChat["chat_id"];
        }
      });

      if (chat_id != null) {
        // Sudah pernah buat koneksi chat dengan => friendEmail
        flagNewConnection = false;
      } else {
        // Belum pernah buat koneksi chat dengan => friendEmail
        // Buat koneksi chat baru
        flagNewConnection = true;
      }
    } else {
      // Belum pernah chat dengan siapapun
      // Buat koneksi baru
      flagNewConnection = true;
    }

    if (flagNewConnection) {
      // Cek dari chats Collection => connection _currentUser dengan friendEmail
      final chatsDocs = await chats.where(
        "connections",
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
        // Terdapat data chats
        final chatDataId = chatsDocs.docs[0].id;
        final chatsData = chatsDocs.docs[0].data() as Map<String, dynamic>;

        await users.doc(_currentUser!.email).update({
          "chats": [
            {
              "connections": friendEmail,
              "chat_id": chatDataId,
              "lastTime": chatsData["lastTime"],
            }
          ]
        });

        user.update((user) {
          user!.chats = [
            ChatUser(
              chatId: chatDataId,
              connection: friendEmail,
              lastTime: chatsData["lastTime"],
            )
          ];
        });

        chat_id = chatDataId;
        user.refresh();
      } else {
        // Buat koneksi baru
        final newChatDoc = await chats.add({
          "connections": [
            _currentUser!.email,
            friendEmail,
          ],
          "total_chats": 0,
          "total_read": 0,
          "total_unread": 0,
          "chat": [],
          "lastTime": date,
        });

        await users.doc(_currentUser!.email).update({
          "chats": [
            {
              "connections": friendEmail,
              "chat_id": newChatDoc.id,
              "lastTime": date,
            }
          ]
        });

        user.update((user) {
          user!.chats = [
            ChatUser(
              chatId: newChatDoc.id,
              connection: friendEmail,
              lastTime: date,
            )
          ];
        });

        chat_id = newChatDoc.id;
        user.refresh();
      }
    }
    Get.toNamed(Routes.CHAT_ROOM, arguments: chat_id);
  }
}
