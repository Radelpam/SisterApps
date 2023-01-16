import 'dart:io';

import 'package:babysitters_app/Styles/Styles.dart';
import 'package:babysitters_app/pages/loadings/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class EditProfilePage extends StatefulWidget {
  EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  var uid = FirebaseAuth.instance.currentUser!.uid;
  var datas;
  String urlprofile = "";
  TextEditingController name = TextEditingController();
  TextEditingController mail = TextEditingController();
  TextEditingController pas = TextEditingController();
  @override
  void initState() {
    gettype();
    // TODO: implement initState
    super.initState();
  }

  gettype() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          datas = documentSnapshot.data();
        });
      } else {
        print("no");
      }
    });
    (datas != null) ? urlprofile = datas['foto_perfil'] : null;
    (datas != null) ? name.text = datas['name'] : null;
    (datas != null) ? mail.text = datas['email'] : null;
    (datas != null) ? pas.text = datas['password'] : null;
  }

  final user = FirebaseAuth.instance.currentUser;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.keyboard_return_outlined)),
        title: const Text("Edita tu perfil"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              profile(),
              const SizedBox(
                height: 30,
              ),
              textform(name, TextInputType.name, "Nombre", false),
              const SizedBox(
                height: 20,
              ),
              textform(mail, TextInputType.emailAddress, "Correo electronico",
                  false),
              const SizedBox(
                height: 20,
              ),
              textform(pas, TextInputType.visiblePassword, "Contraseña", true),
              const SizedBox(
                height: 50,
              ),
              InkWell(
                onTap: () {
                  if (name.text.isNotEmpty &&
                      mail.text.isNotEmpty &&
                      mail.text.contains("@") &&
                      pas.text.length > 6) {
                    addUser(uid);
                  }
                },
                child: Container(
                  width: 130,
                  height: 50,
                  decoration: BoxDecoration(
                      color: colorprincipal,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: Center(
                      child: Text(
                    "Guardar Cambios",
                    style: GoogleFonts.podkova(color: textColor1),
                  )),
                ),
              )
            ],
          ),
          (loading == true) ? const Loading() : Container()
        ],
      ),
    );
  }

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(String uid) async {
    setState(() {
      loading = true;
    });
    // Call the user's CollectionReference to add a new user
    var succes;
    try {
      await user?.updatePassword(pas.text).then((value) async {
        await user?.updateEmail(mail.text);
        await user?.updatePhotoURL(urlprofile).then((value) async {
          await users.doc(uid).update({
            'name': name.text,
            'email': mail.text,
            'foto_perfil': urlprofile,
          }).then((value) async {
            setState(() {
              loading = false;
            });
            Navigator.pop(context, true);
          }).catchError((error) => succes == false);
        });
      }).catchError((error) {
        setState(() {
          loading = false;
        });
        snac(
            "Llevas mucho tiempo conectado, vuelve a iniciar sesion para cambiar tu contraseña");
      });
    } catch (e) {
      snac(
          "Llevas mucho tiempo conectado, vuelve a iniciar sesion para cambiar tu contraseña");
    }

    return succes;
    /* return users
          .add({
            
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error")); */
  }

  void snac(String type) {
    final snackBar = SnackBar(
      backgroundColor: Colors.pink,
      content: Text('$type'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget textform(var controller, var type, String tx, bool pas) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        obscureText: pas,
        keyboardType: type,
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: tx,
          contentPadding:
              const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorprincipal),
            borderRadius: BorderRadius.circular(25.7),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorprincipal),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget profile() {
    return InkWell(
      onTap: () {
        var i = imgFromGallery();
        setState(() {
          urlprofile;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.width * 0.3,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: (urlprofile.isNotEmpty)
                    ? NetworkImage(urlprofile)
                    : const NetworkImage(
                        "https://firebasestorage.googleapis.com/v0/b/projectbabys.appspot.com/o/icono.png?alt=media&token=12e79f9e-1be4-4ff9-90d1-f4fb43f8a9a3")),
            shape: BoxShape.circle,
            color: Colors.grey.withOpacity(0.2)),
      ),
    );
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = Path.basename(_photo!.path);
    print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAaa");
    print(fileName);
    final destination = 'files/${fileName}';
    var url;
    try {
      final ref = FirebaseStorage.instance.ref(destination).child('image/');
      await ref.putFile(_photo!);
      url = await ref.getDownloadURL();
    } catch (e) {
      print(e);
    }
    setState(() {
      url != null ? urlprofile = url : null;
    });
  }

  FirebaseStorage storage = FirebaseStorage.instance;

  File? _photo;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 25);
    var z;
    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        var v = uploadFile();
        print(v);
        if (v == true) {
          z = true;
        }
      } else {
        print('No image selected.');
      }
    });
    print(z);
    return z;
  }
}
