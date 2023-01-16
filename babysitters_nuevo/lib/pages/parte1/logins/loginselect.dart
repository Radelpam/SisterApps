// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:babysitters_app/pages/parte1/registers/registroni%C3%B1eras.dart';
import 'package:babysitters_app/pages/parte1/registers/registropadres.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../parte2/Menu_Screen.dart';

class LoginAndRegisterDaddys extends StatefulWidget {
  String type;
  LoginAndRegisterDaddys({required this.type});

  @override
  State<LoginAndRegisterDaddys> createState() => _LoginAndRegisterDaddysState();
}

class _LoginAndRegisterDaddysState extends State<LoginAndRegisterDaddys> {
  TextEditingController emailFiel = TextEditingController();
  TextEditingController passwordFiel = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            bannerApp(),
            textDescription(),
            //textLogin(),
            textFielEmail(),
            textFielContrasena(),
            bottonlogin(
                Colors.pink, Colors.white, "Ingresar", Icons.login, context),
            textAtras(),
          ],
        ),
      ),
    );
  }

  Widget textDescription() {
    //Titulo Bienvenido
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Text(
        '¡Bienvenido!',
        style: GoogleFonts.roboto(
          color: Colors.pink,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget textFielEmail() {
    //Pedir Email
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: TextField(
        controller: emailFiel,
        decoration: const InputDecoration(
            hintText: 'Correo@gmail.com',
            labelText: 'Correo electronico',
            suffixIcon: Icon(Icons.email_outlined, color: Colors.pink)),
      ),
    );
  }

  Widget bottonlogin(Color color, Color textColor, String text, IconData icon,
      BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 45, vertical: 25),
      child: MaterialButton(
        onPressed: () async {
          if (emailFiel.text.isNotEmpty &&
              passwordFiel.text.isNotEmpty &&
              passwordFiel.text.length > 6 &&
              emailFiel.text.contains("@") &&
              emailFiel.text.contains(".")) {
            print("HOLIS");
            final signInMethods = await FirebaseAuth.instance
                .fetchSignInMethodsForEmail(emailFiel.text);

            print(signInMethods);
            if (signInMethods.isEmpty) {
              // Si el correo electrónico no está asociado a ninguna cuenta,
              // redirige al usuario a la página de registro
              // Navigator.of(context).push(MaterialPageRoute(builder: (context) => null,));

              if (widget.type == "client") {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RegistroPadres(
                      email: emailFiel.text,
                      password: passwordFiel.text,
                      type: widget.type),
                ));
              } else if (widget.type == "ninera") {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RegistroNanas(
                      email: emailFiel.text,
                      password: passwordFiel.text,
                      type: widget.type),
                ));
              } else if (widget.type == "admin") {
                CollectionReference users =
                    FirebaseFirestore.instance.collection('users');
                final credential =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: emailFiel.text,
                  password: passwordFiel.text,
                );
                var id = await credential.user!.uid;
                await users
                    .doc(id)
                    .set({
                      'email': emailFiel.text,
                      'password': passwordFiel.text,
                      'tipo': 'admin'
                    })
                    .then((value) => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => MenuScreen(),
                        ),
                        (route) => false))
                    .catchError((error) => true);
              }
            } else {
              {
                try {
                  final credential =
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailFiel.text,
                    password: passwordFiel.text,
                  );
                } on FirebaseAuthException catch (e) {
                  print(e);
                  if (e.code == 'weak-password') {
                    print('La contraseña proporcionada es demasiado débil.');
                  } else if (e.code == 'email-already-in-use') {
                    print('La cuenta ya existe para ese correo electrónico.');
                  } else if (e.toString().contains(
                      'The password is invalid or the user does not have a password.')) {
                    final snackBar = SnackBar(
                      backgroundColor: Colors.pink,
                      content: Text(
                          'Esta contraseña es incorrecta, porfavor compruebala'),
                    );

                    // Find the ScaffoldMessenger in the widget tree
                    // and use it to show a SnackBar.
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else if (e.toString().contains(
                      'We have blocked all requests from this device due to unusual activity. Try again later.')) {
                    final snackBar = SnackBar(
                      backgroundColor: Colors.pink,
                      content: Text(
                          'Cuenta bloqueada temporalmente, actividad sospechosa'),
                    );

                    // Find the ScaffoldMessenger in the widget tree
                    // and use it to show a SnackBar.
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                } catch (e) {
                  print(e);
                }
              }
            }
          } else {
            final snackBar = SnackBar(
              backgroundColor: Colors.pink,
              content: Text('Correo y contraseña deben ir completos'),
            );

            // Find the ScaffoldMessenger in the widget tree
            // and use it to show a SnackBar.
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        color: color,
        textColor: textColor,
        // ignore: sort_child_properties_last
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                  height: 45,
                  alignment: Alignment.center,
                  child: Text(
                    text,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  )),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget textFielContrasena() {
    //Pedir contraseña
    //Pedir Email
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: TextField(
        controller: passwordFiel,
        obscureText: true, //Colocar la contraseña en puntos

        decoration: const InputDecoration(
            labelText: 'Contraseña',
            suffixIcon: Icon(Icons.lock_open_outlined, color: Colors.pink)),
      ),
    );
  }

  Widget textAtras() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 50,
        alignment: Alignment.bottomLeft,
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        child: const Icon(
          Icons.subdirectory_arrow_left_rounded,
          color: Colors.pink,
        ),
      ),
    );
  }

  Widget textNoCuenta() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: const Text(
          '¿No tienes cuenta?',
          style: TextStyle(fontSize: 15, color: Colors.pink),
        ),
      ),
    );
  }

  Widget textLogin() {
    //Titulo Login
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: const Text(
        'Ingresa',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget bannerApp() {
    //metodo para invocar la parte superior
    return ClipPath(
      //Fondo de los iconos
      child: Container(
        color: Colors.blue.shade50,
        height: MediaQuery.of(context).size.height * 0.30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/img/ninos.gif',
              width: 250,
              height: 200,
            ),
          ],
        ),
      ),
    );
  }
}
