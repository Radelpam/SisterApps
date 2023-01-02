// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors

import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:babysitters_app/Styles/Styles.dart';
import 'package:babysitters_app/functions/notifications/notifications.dart';
import 'package:babysitters_app/pages/home_screen.dart';
import 'package:babysitters_app/pages/parte3/padresservicios/serviciossolicitud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    gettype();

    super.initState();
    Timer.periodic(Duration(seconds: 5), (timer) {
      // Tu código para la acción a ejecutar cada 5 segundos aquí
      if (datas != null) {
        if ((datas['tipo'] == "ninera") &&
            (datas['estado'] == 1) &&
            (datas['servicio'] == false)) {
          sendPushNotificationOnNewHelpDocument();
        }
      }
    });
  }

  var datas;
  var datatemp;
  void gettype() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
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
  }

  late FirebaseMessaging _firebaseMessaging;

  void suscribirseATopico() {
    _firebaseMessaging.subscribeToTopic('n_targets');
  }

  void enviarNotificacion(String id) async {
    // Obtener usuarios con "n" en el campo "tipo_usuario"
    final usersRef = FirebaseFirestore.instance
        .collection('users')
        .where('tipo', isEqualTo: 'ninera');
    final snapshot = await usersRef.get();
    snapshot.docs.forEach((doc) async {
      // Enviar notificación a cada usuario
      final userId = doc.id;
      final payload = {
        'notification': {
          'title': 'Título de la notificación',
          'body': 'Cuerpo de la notificación',
          'id': id,
        }
      };
      print("ASSSSSSSSSSSSDDDDDDDDDDDDDDDDDDDDDAAAAAAAAAAAAAa");
      print(payload);
      messaje("Nuevo servicio", id, false);
      /*  await CloudFunctions.instance.call(
        functionName: 'sendNotification',
        parameters: {
          'topic': userId,
          'payload': payload,
        },
      ); */
    });
  }

  void sendPushNotificationOnNewHelpDocument() async {
    // Inicializa el escuchador de eventos
    final helpDocuments = FirebaseFirestore.instance.collection('servicios');
    helpDocuments.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        // Si se ha creado un nuevo documento
        if (change.type == DocumentChangeType.added) {
          // Envía la notificación a todos los usuarios

          if (datas['tipo'] == 'ninera') {
            if (change.doc.data()!['estado'] == true) {
              enviarNotificacion(change.doc.data()!['tipo']);
            }
          }
        } else {
          print("no");
        }
      });
    });
  }

  final Stream<QuerySnapshot> _nineraStream = FirebaseFirestore.instance
      .collection('servicios')
      .where("estado", isEqualTo: true)
      .snapshots();
  final Stream<QuerySnapshot> _clientStream =
      FirebaseFirestore.instance.collection('serviciosdisponibles').snapshots();
  final Stream<QuerySnapshot> _adminStream = FirebaseFirestore.instance
      .collection('users')
      .where("tipo", isEqualTo: 'ninera')
      .snapshots();

  @override
  Widget build(BuildContext context) {
//Respuesta
    if (datas != null) {
      if (datas['tipo'] == 'client') {
        final helpDocuments = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid);
        helpDocuments.snapshots().listen((snapshot) {
          setState(() {
            datas = snapshot.data();
          });
          if (datas['idnineraselec'] != "") {
            final se = FirebaseFirestore.instance
                .collection('users')
                .doc(datas['idnineraselec']);
            se.snapshots().listen((snapshot) {
              setState(() {
                datatemp = snapshot.data();
              });
            });
          } else {
            setState(() {
              datatemp?.clear();
            });
          }
        });
      } else if (datas['tipo'] == 'ninera') {
        final helpDocuments = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid);
        helpDocuments.snapshots().listen((snapshot) {
          setState(() {
            datas = snapshot.data();
          });
          if (datas['idpadreselec'] != "") {
            final se = FirebaseFirestore.instance
                .collection('users')
                .doc(datas['idpadreselec']);
            se.snapshots().listen((snapshot) {
              setState(() {
                datatemp = snapshot.data();
              });
            });
          } else {
            setState(() {
              datatemp?.clear();
            });
          }
        });
      }
    }

    return (datas != null)
        ? Scaffold(
            appBar: (datas['esperando'] == false)
                ? AppBar(backgroundColor: colorprincipal, actions: [
                    IconButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          setState(() {
                            datas = null;
                          });
                          AwesomeNotifications().cancelAll();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TestNotificaion(),
                              ));
                        },
                        icon: Icon(Icons.login))
                  ])
                : (datas['tipo'] == 'ninera' &&
                        (datas['estado'] == 1) &&
                        (datas['servicio'] == false))
                    ? AppBar(backgroundColor: colorprincipal, actions: [
                        IconButton(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              setState(() {
                                datas = null;
                              });

                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TestNotificaion(),
                                  ));
                            },
                            icon: Icon(Icons.login))
                      ])
                    : (datas['tipo'] == 'admin')
                        ? AppBar(backgroundColor: colorprincipal, actions: [
                            IconButton(
                                onPressed: () {
                                  FirebaseAuth.instance.signOut();
                                  setState(() {
                                    datas = null;
                                  });

                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TestNotificaion(),
                                      ));
                                },
                                icon: Icon(Icons.login))
                          ])
                        : null,
            backgroundColor: Colors.white,
            body: (datas['tipo'] == "ninera")
                ? (datas['estado'] == 1)
                    ? Stack(
                        children: [
                          StreamBuilder(
                            stream: _nineraStream,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text("Something went wrong");
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text("Loading");
                              }
                              return GridView(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 15.0,
                                  mainAxisSpacing: 5.0,
                                ),
                                shrinkWrap: true,
                                children: snapshot.data!.docs
                                    .map((DocumentSnapshot document) {
                                  Map<String, dynamic> data =
                                      document.data()! as Map<String, dynamic>;

                                  return InkWell(
                                    onTap: () {
                                      acceptservice(
                                          data['tipo'],
                                          data['NombreUsuario'],
                                          data['Horas'],
                                          data['celular'],
                                          data['direccion'],
                                          data['fechainicial'],
                                          data['precio'],
                                          data['cantidadenanos'],
                                          data['observaciones'],
                                          document.id,
                                          data['DiasTotal'],
                                          data);
                                    },
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Image.asset("assets/img/sd.png"),
                                          ListTile(
                                            title: Text("${data['tipo']}"),
                                            subtitle: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        "Horas: ${(data['Horas']).round()}"),
                                                    Text(
                                                        "Valor: ${data['precio']}"),
                                                  ],
                                                ),
                                                Icon(
                                                  Icons
                                                      .arrow_circle_right_sharp,
                                                  color: coloricons,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          (datas['servicio'] == true)
                              ? Container(
                                  color: colorprincipal,
                                  width: MediaQuery.of(context).size.width * 1,
                                  height:
                                      MediaQuery.of(context).size.height * 1,
                                  child: Center(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: textColor1,
                                      ),
                                      Text(
                                        "Estas en servicio",
                                        style: GoogleFonts.poppins(
                                            color: textColor1),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 45, vertical: 25),
                                        child: MaterialButton(
                                          color: textColor1,
                                          onPressed: () async {
                                            CollectionReference userdatadd =
                                                await FirebaseFirestore.instance
                                                    .collection('users');

                                            await userdatadd
                                                .doc(datas['idpadreselec'])
                                                .update({
                                              "servidoract": false,
                                              'idnineraselec': ''
                                            });
                                            await userdatadd
                                                .doc(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                .update({
                                              'servicio': false,
                                              'idpadreselec': ''
                                            });
                                          },
                                          // ignore: sort_child_properties_last
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.center,
                                                child: Container(
                                                    height: 45,
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Servicio terminado",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: coloricons),
                                                    )),
                                              ),
                                            ],
                                          ),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                        ),
                                      )
                                    ],
                                  )),
                                )
                              : Container()
                        ],
                      )
                    : Container(
                        child: Center(
                            child: Column(
                          children: [
                            CircularProgressIndicator(),
                            Text("Esperando aceptacion")
                          ],
                        )),
                      )
                : (datas['tipo'] == "client")
                    ? Stack(
                        children: [
                          Column(
                            children: [
                              bannerApp(context, datas['name']),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 70, vertical: 10),
                                child: Text(
                                  'Elige tu paquete! ' '',
                                  style: GoogleFonts.pacifico(
                                    color: Colors.black87,
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                child: StreamBuilder(
                                  stream: _clientStream,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      return Text("Something went wrong");
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text("Loading");
                                    }
                                    return ListView(
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      children: snapshot.data!.docs
                                          .map((DocumentSnapshot document) {
                                        Map<String, dynamic> data = document
                                            .data()! as Map<String, dynamic>;
                                        if (data['disponible'] == true) {
                                          /* return ListTile(
                                            title: Text("${data['nombre']}"),
                                            subtitle: Text("${data['disponible']}"),
                                          ); */
                                          return InkWell(
                                            onTap: () => descpackage(
                                                data['nombre'],
                                                data['descripcion'],
                                                data['image_desc'],
                                                data['c_ninos'],
                                                data['precio_hora_dia'],
                                                data['precio_hora_noche'],
                                                data),
                                            child: icon(
                                                data['nombre'], data['image']),
                                          );
                                        } else {
                                          return Container();
                                        }
                                      }).toList(),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 70, vertical: 10),
                                child: Text(
                                  'Menu',
                                  style: GoogleFonts.pacifico(
                                    color: Colors.black87,
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    people('assets/img/si.png', "Nuestra gente",
                                        Color.fromARGB(255, 253, 95, 148)),
                                    SizedBox(
                                      width: 29,
                                    ),
                                    people('assets/img/servicio.png',
                                        "Servicios activos", Colors.blue),
                                  ],
                                ),
                              )
                            ],
                          ),
                          (datas['esperando'] == true)
                              ? Container(
                                  color: Colors.pink.withOpacity(0.6),
                                  width: MediaQuery.of(context).size.width * 1,
                                  height:
                                      MediaQuery.of(context).size.height * 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      Text(
                                          "Esperando respuesta de alguna niñera...",
                                          style: GoogleFonts.poppins(
                                            color: textColor1,
                                          ))
                                    ],
                                  ),
                                )
                              : Container(),
                          (datas['servidoract'] == true)
                              ? (datatemp != null)
                                  ? Container(
                                      color: Colors.pink.withOpacity(0.6),
                                      width:
                                          MediaQuery.of(context).size.width * 1,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              "Una niñera acepto tu solicitud.",
                                              style: GoogleFonts.poppins(
                                                color: textColor1,
                                              )),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            decoration: BoxDecoration(
                                                color: textColor1,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Nombre: ${datatemp['name']}",
                                                    style: GoogleFonts.poppins(
                                                        color: colorprincipal,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  Text(
                                                    "Telefono: ${datatemp['celular']}",
                                                    style: GoogleFonts.poppins(
                                                        color: colorprincipal,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  Text(
                                                    "Estudios: ${datatemp['Estudios']}",
                                                    style: GoogleFonts.poppins(
                                                        color: colorprincipal,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                _launched = _makePhoneCall(
                                                    datatemp['celular']);
                                              });
                                            },
                                            child: Container(
                                              width: 150,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: coloricons,
                                                      width: 3),
                                                  color: textColor1,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                              child: Center(
                                                  child: Text(
                                                "Llamar a la niñera",
                                                style: GoogleFonts.poppins(
                                                    color: colorprincipal,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(
                                      child: CircularProgressIndicator(),
                                    )
                              : Container()
                        ],
                      )
                    : (datas['tipo'] == 'admin')
                        ? Stack(
                            children: [
                              Column(
                                children: [
                                  bannerApp(context, "Admin"),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 70, vertical: 10),
                                    child: Text(
                                      'Niñeras',
                                      style: GoogleFonts.pacifico(
                                        color: Colors.black87,
                                        fontSize: 30,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                    child: StreamBuilder(
                                      stream: _adminStream,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        if (snapshot.hasError) {
                                          return Text("Something went wrong");
                                        }

                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Text("Loading");
                                        }
                                        return ListView(
                                          physics: BouncingScrollPhysics(),
                                          shrinkWrap: true,
                                          children: snapshot.data!.docs
                                              .map((DocumentSnapshot document) {
                                            Map<String, dynamic> data =
                                                document.data()!
                                                    as Map<String, dynamic>;
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: (data['estado'] == 0)
                                                        ? Colors.red
                                                        : null,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: ListTile(
                                                  title: Text(
                                                    data['name'],
                                                    style: GoogleFonts.poppins(
                                                      color:
                                                          (data['estado'] == 0)
                                                              ? textColor1
                                                              : colorprincipal,
                                                    ),
                                                  ),
                                                  subtitle: Row(
                                                    children: [
                                                      Text((data['estado'] == 0)
                                                          ? "Inactivo"
                                                          : "Activo"),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text((data['servicio'] ==
                                                              true)
                                                          ? "Trabajando"
                                                          : "Libre"),
                                                    ],
                                                  ),
                                                  trailing: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      InkWell(
                                                        onTap: () async {
                                                          CollectionReference
                                                              userdatadd =
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users');
                                                          await userdatadd
                                                              .doc(document.id)
                                                              .update({
                                                            'estado': 1
                                                          });
                                                        },
                                                        child: Container(
                                                            color: Colors.green,
                                                            child: Icon(
                                                                Icons.check)),
                                                      ),
                                                      InkWell(
                                                        onTap: () async {
                                                          CollectionReference
                                                              userdatadd =
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users');
                                                          await userdatadd
                                                              .doc(document.id)
                                                              .update({
                                                            'estado': 0
                                                          });
                                                        },
                                                        child: Container(
                                                            color: Colors.red,
                                                            child: Icon(
                                                                Icons.close)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Container(),
          )
        : Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestNotificaion(),
                          ));
                    },
                    icon: Icon(Icons.logout))
              ],
            ),
          );
  }

  Future<void>? _launched;
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> acceptservice(
      String tipo,
      String usuario,
      var horas,
      String telefono,
      String direccion,
      String fecha,
      var valor,
      var enanos,
      String observaciones,
      String id,
      int cantidad,
      var dataso) {
    return showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.only(top: 10),
            height: 280,
            child: Column(
              children: [
                Text("Tipo: $tipo"),
                Text("Padre: $usuario"),
                Text("Cantidad niños: $enanos"),
                Text("Horas contratadas: $horas"),
                Text("Telefono de contacto: $telefono"),
                Text("Direccion: $direccion"),
                Text("Fecha de trabajo: $fecha"),
                Text("Dias: $cantidad"),
                Text("Precio final: $valor"),
                Text("Adiciones: $observaciones"),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 45, vertical: 25),
                  child: MaterialButton(
                    color: colorprincipal,
                    onPressed: () async {
                      CollectionReference usersdd = await FirebaseFirestore
                          .instance
                          .collection('servicios');
                      CollectionReference userdatadd =
                          await FirebaseFirestore.instance.collection('users');

                      await userdatadd
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'servicio': true,
                        'idpadreselec': dataso['idUsuario']
                      });

                      await userdatadd.doc(dataso['idUsuario']).update({
                        'esperando': false,
                        "servidoract": true,
                        'idnineraselec': FirebaseAuth.instance.currentUser!.uid
                      });
                      await usersdd.doc(id).update({
                        'estado': false,
                        'ninera': datas['name'],
                        'telefono': datas['celular']
                      });
                      Navigator.pop(context);
                    },
                    // ignore: sort_child_properties_last
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                              height: 45,
                              alignment: Alignment.center,
                              child: Text(
                                "Aceptar",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor1),
                              )),
                        ),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                )
              ],
            ),
          );
        });
  }

  Future<void> descpackage(String title, String textDescription, String img,
      String cninos, int phd, int phn, var data) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(top: 10),
          height: 600,
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                      width: 90,
                      child: Image.network(
                        img,
                        fit: BoxFit.contain,
                      )),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pacifico(
                        fontSize: 30, color: colorprincipal),
                  ),
                  SizedBox(
                    width: 300,
                    child: Text(
                      textDescription,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 104, 104, 104)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Cantidad de niños",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pacifico(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: colorprincipal),
                  ),
                  SizedBox(
                    width: 300,
                    child: Text(
                      cninos,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 104, 104, 104)),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Precio por Hora",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: colorprincipal),
                      ),
                      Text(
                        "\$${phd}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color.fromARGB(255, 104, 104, 104)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Precio por Hora Nocturna",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: colorprincipal),
                      ),
                      Text(
                        "\$${phn}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color.fromARGB(255, 104, 104, 104)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  buttonall(data)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buttonall(var dat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 45, vertical: 25),
      child: MaterialButton(
        color: colorprincipal,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiciosSolicitud(
                    data: dat,
                    phd: dat['precio_hora_dia'],
                    phn: dat['precio_hora_noche']),
              ));
        },
        // ignore: sort_child_properties_last
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                  height: 45,
                  alignment: Alignment.center,
                  child: Text(
                    "Solicitar",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor1),
                  )),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget people(String image, String titulo, Color color) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Column(
            children: [
              Container(
                height: 80,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200,
                        blurRadius: 20,
                      ),
                    ]),
                child: Center(
                  child: Image.asset(image),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget icon(String name, String image) {
    return GestureDetector(
      child: Row(
        children: [
          Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                height: 80,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.shade100,
                        blurRadius: 20,
                      ),
                    ]),
                child: Center(
                  child: Image.network(
                    image,
                    height: 70,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                name,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget bannerApp(BuildContext context, String name) {
    //metodo para invocar la parte superior
    return ClipPath(
      //Fondo de los iconos

      child: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height * 0.30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset("assets/img/icono.png"),
            Text('¡Bienvenido, $name!', style: GoogleFonts.pacifico()),
          ],
        ),
      ),
    );
  }
}
