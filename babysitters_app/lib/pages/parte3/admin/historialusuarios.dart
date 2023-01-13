import 'package:babysitters_app/Styles/Styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistorialUsuariosAdmin extends StatefulWidget {
  const HistorialUsuariosAdmin({super.key});

  @override
  State<HistorialUsuariosAdmin> createState() => _HistorialUsuariosAdminState();
}

class _HistorialUsuariosAdminState extends State<HistorialUsuariosAdmin> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('servicios').snapshots();
  String search = "";
  String dropdownvalue = 'client';
  var items = ['client', 'ninera'];
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: media.width * 0.75,
                    height: 30,
                    child: TextField(
                      cursorColor: colorprincipal,
                      decoration: InputDecoration(
                          suffixIconColor: Color.fromARGB(255, 1, 127, 100),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color.fromARGB(255, 1, 127, 100),
                          ),
                          hintText: 'Buscar usuario'),
                      onChanged: (val) {
                        setState(() {
                          search = val;
                        });
                      },
                    ),
                  ),
                  DropdownButton(
                    items: items.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        dropdownvalue = value!;
                      });
                    },
                    value: dropdownvalue,
                  ),
                ],
              ),
              ListView(
                shrinkWrap: true,
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;

                  if (search.isEmpty) {
                    return ListTile(
                      title: Text(data['tipo']),
                      subtitle: Row(
                        children: [
                          Text("Cliente:" + data['NombreUsuario']),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Niñera:" +
                              "${(data['ninera'] != null) ? data['ninera'] : "Sin asignar"}"),
                        ],
                      ),
                    );
                  }
                  if (data['NombreUsuario']
                          .toString()
                          .toLowerCase()
                          .contains(search.toLowerCase()) &&
                      dropdownvalue == 'client') {
                    return ListTile(
                      title: Text(data['NombreUsuario']),
                      subtitle: Text(data['tipo']),
                    );
                  } else if (data['ninera']
                          .toString()
                          .toLowerCase()
                          .contains(search.toLowerCase()) &&
                      dropdownvalue == 'ninera') {
                    return ListTile(
                      title: Text(
                          "${(data['ninera'] != null) ? data['ninera'] : "Sin asignar"}"),
                      subtitle: Text(data['tipo']),
                    );
                  }

                  return Container();
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
