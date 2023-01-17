import 'package:babysitters_app/Styles/Styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UsuariosAdminSection extends StatefulWidget {
  const UsuariosAdminSection({super.key});

  @override
  State<UsuariosAdminSection> createState() => _UsuariosAdminSectionState();
}

class _UsuariosAdminSectionState extends State<UsuariosAdminSection> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();
  String search = "";
  String dropdownvalue = 'todos';
  var items = ['todos', 'client', 'ninera'];
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
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(data['foto_perfil']),
                      ),
                      title: Text(data['name']),
                      subtitle: Text(data['celular']),
                      trailing: (data['tipo'] == 'admin')
                          ? InkWell(
                              onTap: () {
                                CollectionReference users = FirebaseFirestore
                                    .instance
                                    .collection('users');
                                users
                                    .doc(document.id)
                                    .update({'tipo': 'client'})
                                    .then((value) => {
                                          print("User Updated"),
                                        })
                                    .catchError((error) =>
                                        print("Failed to update user: $error"));
                              },
                              child: Text(
                                'Admin',
                                style: GoogleFonts.poppins(color: Colors.blue),
                              ))
                          : InkWell(
                              onTap: () {
                                CollectionReference users = FirebaseFirestore
                                    .instance
                                    .collection('users');
                                users
                                    .doc(document.id)
                                    .update({'tipo': 'admin'})
                                    .then((value) => {
                                          print("User Updated"),
                                        })
                                    .catchError((error) =>
                                        print("Failed to update user: $error"));
                              },
                              child: Text(
                                'Volver Admin',
                                style:
                                    GoogleFonts.poppins(color: colorprincipal),
                              )),
                    );
                  }
                  if (data['name']
                          .toString()
                          .toLowerCase()
                          .contains(search.toLowerCase()) &&
                      dropdownvalue == 'todos') {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(data['foto_perfil']),
                      ),
                      title: Text(data['name']),
                      subtitle: Text(data['celular']),
                      trailing: (data['tipo'] == 'admin')
                          ? Text('Admin')
                          : Text('Volver Admin'),
                    );
                  } else if (data['name']
                          .toString()
                          .toLowerCase()
                          .contains(search.toLowerCase()) &&
                      data["tipo"]
                          .toString()
                          .toLowerCase()
                          .contains(dropdownvalue)) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(data['foto_perfil']),
                      ),
                      title: Text(data['name']),
                      subtitle: Text(data['celular']),
                      trailing: (data['tipo'] == 'admin')
                          ? Text('Admin')
                          : Text('Volver Admin'),
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
