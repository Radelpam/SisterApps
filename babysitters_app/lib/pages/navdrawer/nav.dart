import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:babysitters_app/Styles/Styles.dart';
import 'package:babysitters_app/pages/navdrawer/edit_profile.dart';
import 'package:babysitters_app/pages/parte2/Menu_Screen.dart';
import 'package:babysitters_app/pages/parte3/ServiciosAdicionales/historial.dart';
import 'package:babysitters_app/pages/parte3/ServiciosAdicionales/ServiciosActivos.dart';
import 'package:babysitters_app/pages/parte3/admin/historialusuarios.dart';
import 'package:babysitters_app/pages/parte3/admin/usuarios.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../functions/controller.dart';
import '../home_screen.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Drawer(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SingleChildScrollView(
          child: (datas != null)
              ? Column(
                  children: [
                    Container(
                      width: media.width * 1,
                      height: media.height * 0.2,
                      color: colorprincipal,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                maxRadius: media.width * 0.14,
                                backgroundImage:
                                    NetworkImage(datas['foto_perfil']),
                              ),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      var result = Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditProfilePage(),
                                          ));
                                      if (result == true) {
                                        setState(() {});
                                      }
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: textColor1),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Icon(
                                            Icons.edit,
                                            color: colorprincipal,
                                          ),
                                        )),
                                  ))
                            ],
                          ),
                          Text(
                            datas['name'],
                            style: GoogleFonts.poppins(color: textColor1),
                          ),
                          Text(
                            datas['email'],
                            style: GoogleFonts.poppins(color: textColor1),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 70, vertical: 10),
                      child: Text(
                        'Menu',
                        style: GoogleFonts.pacifico(
                          color: Colors.black87,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    (datas['tipo'] != 'admin')
                        ? tiper("Servicios activos", () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ServiciosActivosD(tipo: datas['tipo']),
                                ));
                          }, Icons.design_services_sharp)
                        : tiper("Historial de servicios", () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HistorialUsuariosAdmin(),
                                ));
                          }, Icons.person),
                    Divider(),
                    SizedBox(
                      height: 10,
                    ),
                    (datas['tipo'] != 'admin')
                        ? tiper("Historial", () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HistorialPagePadre(tipo: datas['tipo']),
                                ));
                          }, Icons.history)
                        : tiper("Usuarios", () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UsuariosAdminSection(),
                                ));
                          }, Icons.person),
                    Divider(),
                    SizedBox(
                      height: media.width * 1,
                    ),
                    (datas['tipo'] != 'admin')
                        ? tiper("Eliminar cuenta", () {
                            Navigator.pop(context);
                            infoservice();
                          }, Icons.delete)
                        : Container(),
                    SizedBox(
                      height: media.width * 0.02,
                    ),
                    tiper("Cerrar Sesion", () {
                      Navigator.pop(context);
                      FirebaseAuth.instance.signOut();
                      AwesomeNotifications().cancelAll();
                      setState(() {
                        datas.clear();
                        datas = null;
                      });
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestNotificaion(),
                          ),
                          (route) => false);
                    }, Icons.logout),
                  ],
                )
              : Container(),
        ),
      ),
    );
  }

  Widget tiper(String name, var funtion, IconData icon) {
    var media = MediaQuery.of(context).size;
    return InkWell(
      onTap: funtion,
      child: Container(
        width: media.width * 1,
        height: media.width * .09,
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            Text(
              name,
              style: GoogleFonts.poppins(
                  fontSize: media.width * 0.05, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> infoservice() {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(top: 10),
          height: 200,
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "¿Estas seguro de borrar tu cuenta?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: colorprincipal),
                  ),
                  button("Borrar", () {
                    AwesomeNotifications().cancelAll();

                    CollectionReference users =
                        FirebaseFirestore.instance.collection('users');
                    users
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({'cuentaborrar': true})
                        .then((value) =>
                            {print("User Updated"), Navigator.pop(context)})
                        .catchError(
                            (error) => print("Failed to update user: $error"));
                  }),
                  button("Cancelar", () {
                    Navigator.pop(context);
                  })
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget button(String title, var funtion) {
    return MaterialButton(
      color: colorprincipal,
      onPressed: funtion,
      // ignore: sort_child_properties_last
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
                height: 45,
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor1),
                )),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
