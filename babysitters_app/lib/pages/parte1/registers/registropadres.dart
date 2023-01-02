// ignore_for_file: prefer_typing_uninitialized_variables, sort_child_properties_last, sized_box_for_whitespace, prefer_const_constructors, unnecessary_string_interpolations

import 'dart:io';

import 'package:babysitters_app/pages/parte2/Menu_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:babysitters_app/Styles/Styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class RegistroPadres extends StatefulWidget {
  String email;
  String password;
  String type;
  RegistroPadres(
      {super.key,
      required this.email,
      required this.password,
      required this.type});

  @override
  State<RegistroPadres> createState() => _RegistroPadresState();
}

class _RegistroPadresState extends State<RegistroPadres> {
  TextEditingController nameController = TextEditingController();
  TextEditingController cedulaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

  TextEditingController celularController = TextEditingController();
  TextEditingController direccionController = TextEditingController();
  TextEditingController ciudadController = TextEditingController();
  TextEditingController fechaNacimientoController = TextEditingController();

  String urlprofile = "";

  var _vista;
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                bannerApp(),
                textDescription(),
                SizedBox(
                  height: media.height * 0.05,
                ),
                Column(
                  children: [
                    //foto de perfil
                    profile(),
                    SizedBox(
                      height: media.width * 0.1,
                    ),
                    //Nombre de usuario
                    textFieltype(
                        "Usuario124",
                        "Nombre de usuario",
                        Icons.person,
                        TextInputType.name,
                        true,
                        false,
                        nameController),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    //Cedula
                    textFieltype("12344..", "Cedula", Icons.dns_outlined,
                        TextInputType.phone, true, false, cedulaController),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    //Correo Electronico
                    textFieltype(
                        "Email@mail.com",
                        widget.email,
                        Icons.email,
                        TextInputType.emailAddress,
                        false,
                        false,
                        emailController),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    //Contraseña
                    textFieltype(
                        widget.password,
                        widget.password,
                        Icons.security,
                        TextInputType.visiblePassword,
                        false,
                        false,
                        passwordController),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    //Confirmar Contraseña
                    textFieltype(
                        "Confirmar contraseña",
                        widget.password,
                        Icons.security,
                        TextInputType.visiblePassword,
                        true,
                        true,
                        confirmpasswordController),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    //Direccion
                    textFieltype("BRR COLOMBIA", "Dirrecion ", Icons.house,
                        TextInputType.name, true, false, direccionController),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    //Telefono
                    textFieltype("321321321", "Telefono ", Icons.phone,
                        TextInputType.phone, true, false, celularController),
                    SizedBox(
                      height: media.width * 0.05,
                    ),

                    SizedBox(
                      height: media.width * 0.05,
                    ),

                    //Ciudad
                    Padding(
                      padding: EdgeInsets.only(
                          left: media.width * 0.1, right: media.width * 0.1),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: colorprincipal),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: DropdownButton(
                          items: listaCiudades.map((String a) {
                            return DropdownMenuItem(value: a, child: Text(a));
                          }).toList(),
                          onChanged: (_value) {
                            setState(() {
                              _vista = (_value != null)
                                  ? _value
                                  : listaCiudades.first;
                              ciudadController.text = _value.toString();
                            });
                          },
                          value: _vista,
                          elevation: 8,
                          alignment: Alignment.center,
                          style: TextStyle(
                            color: colorprincipal,
                            fontSize: 18,
                          ),
                          icon: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Icon(
                              Icons.arrow_circle_down_rounded,
                              color: Colors.pink,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                          isExpanded: true,
                          dropdownColor: textColor1,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    _crearfecha(context),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    buttonLogin(),
                    textAtras()
                  ],
                ),
              ],
            ),
          ),
          (isloading == true)
              ? Container(
                  width: media.width * 1,
                  height: media.height * 1,
                  color: Colors.black.withOpacity(0.6),
                  child: Center(child: CircularProgressIndicator()),
                )
              : Container()
        ],
      ),
    );
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
                    : NetworkImage(
                        "https://www.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png")),
            shape: BoxShape.circle,
            color: Colors.grey.withOpacity(0.2)),
      ),
    );
  }

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(String uid) async {
    // Call the user's CollectionReference to add a new user
    var succes;
    await users
        .doc(uid)
        .set({
          'name': nameController.text,
          'cedula': cedulaController.text,
          'email': widget.email,
          'password': widget.password,
          'celular': celularController.text,
          'direccion': direccionController.text,
          'ciudad': ciudadController.text,
          'fechaNacimiento': fechaNacimientoController.text,
          'foto_perfil': urlprofile,
          'tipo': widget.type,
          'esperando': false,
          'servidoract': false,
          'idnineraselec': ""
        })
        .then((value) => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => MenuScreen(),
            ),
            (route) => false))
        .catchError((error) => succes == false);
    return succes;
    /* return users
          .add({
            
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error")); */
  }

  Widget buttonLogin() {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        child: MaterialButton(
          onPressed: () async {
            if (!urlprofile.isNotEmpty) {
              snac("Debes seleccionar una foto de perfil");
            } else {
              if (!nameController.text.isNotEmpty &&
                  !(nameController.text.length > 6)) {
                snac("El nombre de usuario debe ir completo");
              } else {
                if (!cedulaController.text.isNotEmpty &&
                    !(cedulaController.text.length > 6)) {
                  snac("Cedula de ciudadania debe ir completa");
                } else {
                  if (!(confirmpasswordController.text.length > 8) &&
                      !(passwordController.text ==
                          confirmpasswordController.text)) {
                    snac("Las contraseñas no coinciden, verificalas");
                  } else {
                    if (!direccionController.text.isNotEmpty) {
                      snac("Debes tener una direccion de residencia");
                    } else {
                      if (!(celularController.text.length == 10)) {
                        snac("Numero de telefono incorrecto, verificalo");
                      } else {
                        if (!ciudadController.text.isNotEmpty) {
                          snac("Debes escoger una ciudad de residencia");
                        } else {
                          if (!fechaNacimientoController.text.isNotEmpty) {
                            snac("Debes seleccionar una fecha de nacimiento");
                          } else {
                            setState(() {
                              isloading = true;
                            });
                            var id;
                            try {
                              final credential = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: widget.email,
                                password: widget.password,
                              );
                              id = credential.user!.uid;
                              setState(() {
                                isloading = false;
                              });
                              addUser(id);
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'weak-password') {
                                snac(
                                    'La contraseña proporcionada es demasiado débil.');
                              } else if (e.code == 'email-already-in-use') {
                                snac(
                                    'La cuenta ya existe para ese correo electrónico.');
                              }
                            } catch (e) {
                              print(e);
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          },
          color: colorprincipal,
          textColor: textColor1,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                    height: 45,
                    alignment: Alignment.center,
                    child: Text(
                      "Registrarse",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    )),
              ),
            ],
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ));
  }

  void snac(String type) {
    final snackBar = SnackBar(
      backgroundColor: Colors.pink,
      content: Text('$type'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget textAtras() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 50,
        alignment: Alignment.bottomLeft,
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: const Icon(
          Icons.subdirectory_arrow_left_rounded,
          color: Colors.pink,
        ),
      ),
    );
  }

  Widget _crearfecha(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        enableInteractiveSelection: false,
        controller: fechaNacimientoController,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
          hintText: 'Fecha de nacimiento',
          labelText: 'Fecha de nacimiento',
          labelStyle: GoogleFonts.roboto(color: colorprincipal),
          suffixIcon: Icon(Icons.calendar_today_outlined, color: Colors.pink),
        ),
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          _selecDate(context);
        },
      ),
    );
  }

  String fecha = '';
  _selecDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
        helpText: "Fecha de nacimiento",
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1990),
        lastDate: DateTime.now());
    if (picked != null) {
      setState(() {
        fecha = "${picked.day}/${picked.month}/${picked.year}";
        fechaNacimientoController.text = fecha;
      });
    }
  }

  Widget textDescription() {
    //Titulo Bienvenido
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: Text(
        '¡Registro Niñera!',
        style: GoogleFonts.roboto(
          color: colorprincipal,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget textFieltype(
      String hintText,
      String labelText,
      IconData icon,
      TextInputType type,
      bool enabled,
      bool pas,
      TextEditingController controller) {
    //Pedir Email
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: TextField(
        keyboardType: type,
        enabled: enabled,
        obscureText: pas,
        controller: controller,
        cursorColor: colorprincipal,
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: colorprincipal)),
            hintText: hintText,
            labelText: labelText,
            labelStyle: GoogleFonts.roboto(color: colorprincipal),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
            suffixIcon: Icon(icon, color: coloricons.withOpacity(0.6))),
      ),
    );
  }

  Widget bannerApp() {
    //metodo para invocar la parte superior
    return ClipPath(
      //Fondo de los iconos
      child: Container(
        color: Colors.white70,
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 0.30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/img/icono.png',
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Text(
                '¡Tus niños, nuestra prioridad!',
                style: GoogleFonts.pacifico(
                    fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PickImage() {}
}
