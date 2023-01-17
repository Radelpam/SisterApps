import 'package:babysitters_app/Styles/Styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HistorialPagePadre extends StatefulWidget {
  String tipo;
  HistorialPagePadre({super.key, required this.tipo});

  @override
  State<HistorialPagePadre> createState() => _HistorialPagePadreState();
}

class _HistorialPagePadreState extends State<HistorialPagePadre> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('servicios')
      .where('idUsuario', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where('terminado', isEqualTo: true)
      .snapshots();
  final Stream<QuerySnapshot> _usersStream2 = FirebaseFirestore.instance
      .collection('servicios')
      .where('idNinera', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where('terminado', isEqualTo: true)
      .snapshots();
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return StreamBuilder<QuerySnapshot>(
      stream: (widget.tipo == "client") ? _usersStream : _usersStream2,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Tu historial"),
          ),
          body: ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              var date = (data['FechaCreado']).toDate();
              DateFormat _dateFormat = DateFormat('y-MM-d');
              String formattedDate = _dateFormat.format(date);
              print(data);
              return Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      infoservice(data);
                    },
                    child: Container(
                      width: media.width * 0.8,
                      height: media.width * .2,
                      decoration: BoxDecoration(
                          color: colorprincipal.withOpacity(0.5),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Column(
                        children: [
                          Text(
                            data['tipo'],
                            style: GoogleFonts.poppins(
                                color: textColor1, fontSize: media.width * .07),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "Precio: ",
                                    style: GoogleFonts.poppins(
                                        color: textColor1,
                                        fontSize: media.width * .03),
                                  ),
                                  Text(
                                    "\$${data['precio']}",
                                    style: GoogleFonts.poppins(
                                        color: textColor1,
                                        fontSize: media.width * .03),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Fecha Creado: ",
                                    style: GoogleFonts.poppins(
                                        color: textColor1,
                                        fontSize: media.width * .03),
                                  ),
                                  Text(
                                    "${formattedDate}",
                                    style: GoogleFonts.poppins(
                                        color: textColor1,
                                        fontSize: media.width * .03),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Estado: ",
                                    style: GoogleFonts.poppins(
                                        color: textColor1,
                                        fontSize: media.width * .03),
                                  ),
                                  Text(
                                    (data['cancelado'] == true)
                                        ? "Cancelado"
                                        : (data['terminado'] == true)
                                            ? "Finalizado"
                                            : "Sin finalizar",
                                    style: GoogleFonts.poppins(
                                        color: (data['cancelado'] == true)
                                            ? Colors.red
                                            : (data['terminado'] == true)
                                                ? textColor1
                                                : Colors.grey,
                                        fontSize: media.width * .03),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> infoservice(var data) {
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
                    "Informacion del servicio",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pacifico(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: colorprincipal),
                  ),
                  Text(
                    "Datos de tu ${data['tipo']}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorprincipal),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Direccion:",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colorprincipal),
                      ),
                      Text(
                        "${data['direccion']}/${data['municipio']}",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: colorprincipal),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Hora:",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colorprincipal),
                      ),
                      Text(
                        " ${data['Hora']} - Fecha:${data['fechainicial']}",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: colorprincipal),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Padre:",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colorprincipal),
                      ),
                      Text(
                        "${data['NombreUsuario']}",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: colorprincipal),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Precio servicio:",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colorprincipal),
                      ),
                      Text(
                        "${data['precio']}",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: colorprincipal),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
