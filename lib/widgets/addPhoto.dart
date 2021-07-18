import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPhotoWidget extends StatefulWidget {
  const AddPhotoWidget({
    Key? key,
    required this.fbAuth,
  }) : super(key: key);

  final FirebaseAuth fbAuth;

  @override
  State<AddPhotoWidget> createState() => _AddPhotoWidgetState();
}

class _AddPhotoWidgetState extends State<AddPhotoWidget> {
  bool uploadingImage = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        try {
          final pickedFile = await ImagePicker()
              .getImage(source: ImageSource.camera, maxWidth: 500);
          setState(() {
            uploadingImage = true;
          });
          if (pickedFile != null) {
            final key = DateTime.now().toString().replaceAll('.', ':');
            TaskSnapshot snapshot = await FirebaseStorage.instance
                .ref()
                .child(
                    "governmentOfficials/${widget.fbAuth.currentUser!.uid}/$key")
                .putFile(File(pickedFile.path))
                .onError((error, stackTrace) => throw Exception());
            if (snapshot.state == TaskState.success) {
              final downloadUrl = await snapshot.ref.getDownloadURL();
              await FirebaseDatabase.instance
                  .reference()
                  .child('users/${widget.fbAuth.currentUser!.uid}/bills/$key')
                  .set(downloadUrl)
                  .onError((error, stackTrace) => throw Exception());
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Successfully uploaded the bill!"),
                backgroundColor: Colors.green,
              ));
            }
          }
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error uploading bill..."),
            backgroundColor: Colors.red,
          ));
        }
        setState(() {
          uploadingImage = false;
        });
      },
      icon: uploadingImage
          ? SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(color: Colors.white))
          : Icon(Icons.add_a_photo_outlined),
    );
  }
}
