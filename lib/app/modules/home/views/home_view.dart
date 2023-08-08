import 'package:chitchat/app/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final authC = Get.find<AuthController>();

  List dataTemp = List.generate(
      10,
      (i) => ListTile(
            onTap: () => Get.toNamed(Routes.CHAT_ROOM),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.black26,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    "assets/logo/noimage.png",
                    fit: BoxFit.cover,
                  )),
            ),
            title: Text(
              "Orang ke - ${i + 1}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              "Status orang ke - ${i + 1}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Chip(
              label: Text("3"),
            ),
          )).reversed.toList();

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
                    color: Colors.black38,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.white10,
                      blurRadius: 2.0,
                      spreadRadius: 0.0,
                      offset: Offset(2.0, 2.0)),
                ],
              ),
              padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ChitChat",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Material(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.blue,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => Get.toNamed(Routes.PROFILE),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
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
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: dataTemp.length,
              itemBuilder: (context, index) => dataTemp[index],
            ),
          ),
          // Expanded(
          //   child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          //     stream: controller.chatsStream(authC.user.value.email!),
          //     builder: (context, snapshot1) {
          //       if (snapshot1.connectionState == ConnectionState.active) {
          //         var allChats = (snapshot1.data!.data()
          //             as Map<String, dynamic>)["chats"] as List;
          //         return ListView.builder(
          //           padding: EdgeInsets.zero,
          //           itemCount: allChats.length,
          //           itemBuilder: (context, index) {
          //             return StreamBuilder<
          //                 DocumentSnapshot<Map<String, dynamic>>>(
          //               stream: controller
          //                   .friendStream(allChats[index]["connection"]),
          //               builder: (context, snapshot2) {
          //                 if (snapshot2.connectionState ==
          //                     ConnectionState.active) {
          //                   var data = snapshot2.data!.data();
          //                   return data!["status"] == ""
          //                       ? ListTile(
          //                           onTap: () => Get.toNamed(Routes.CHAT_ROOM),
          //                           leading: CircleAvatar(
          //                             radius: 30,
          //                             backgroundColor: Colors.black26,
          //                             child: ClipRRect(
          //                               borderRadius:
          //                                   BorderRadius.circular(100),
          //                               child: data["photoUrl"] == "noimage"
          //                                   ? Image.asset(
          //                                       "assets/logo/noimage.png",
          //                                       fit: BoxFit.cover,
          //                                     )
          //                                   : Image.network(
          //                                       "${data["photoUrl"]}",
          //                                       fit: BoxFit.cover,
          //                                     ),
          //                             ),
          //                           ),
          //                           title: Text(
          //                             "${data["name"]}",
          //                             style: TextStyle(
          //                               fontSize: 20,
          //                               fontWeight: FontWeight.w600,
          //                             ),
          //                           ),
          //                           trailing:
          //                               allChats[index]["total_unread"] == 0
          //                                   ? SizedBox()
          //                                   : Chip(
          //                                       label: Text(
          //                                           "${allChats[index]["total_unread"]}"),
          //                                     ),
          //                         )
          //                       : ListTile(
          //                           onTap: () => Get.toNamed(Routes.CHAT_ROOM),
          //                           leading: CircleAvatar(
          //                             radius: 30,
          //                             backgroundColor: Colors.black26,
          //                             child: ClipRRect(
          //                               borderRadius:
          //                                   BorderRadius.circular(100),
          //                               child: data["photoUrl"] == "noimage"
          //                                   ? Image.asset(
          //                                       "assets/logo/noimage.png",
          //                                       fit: BoxFit.cover,
          //                                     )
          //                                   : Image.network(
          //                                       "${data["photoUrl"]}",
          //                                       fit: BoxFit.cover,
          //                                     ),
          //                             ),
          //                           ),
          //                           title: Text(
          //                             "${data["name"]}",
          //                             style: TextStyle(
          //                               fontSize: 20,
          //                               fontWeight: FontWeight.w600,
          //                             ),
          //                           ),
          //                           subtitle: Text(
          //                             "${data["status"]}",
          //                             style: TextStyle(
          //                               fontSize: 16,
          //                               fontWeight: FontWeight.w600,
          //                             ),
          //                           ),
          //                           trailing:
          //                               allChats[index]["total_unread"] == 0
          //                                   ? SizedBox()
          //                                   : Chip(
          //                                       label: Text(
          //                                           "${allChats[index]["total_unread"]}"),
          //                                     ),
          //                         );
          //                 } else {
          //                   return Center(
          //                     child: CircularProgressIndicator(),
          //                   );
          //                 }
          //               },
          //             );
          //           },
          //         );
          //       }
          //       return Center(
          //         child: CircularProgressIndicator(),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.SEARCH),
        child: Icon(Icons.search),
      ),
    );
  }
}
