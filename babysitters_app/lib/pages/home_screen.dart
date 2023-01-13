// ignore_for_file: use_build_context_synchronously

import 'package:babysitters_app/Styles/Styles.dart';
import 'package:babysitters_app/pages/loadings/loading.dart';
import 'package:babysitters_app/pages/parte1/registers/registroni%C3%B1eras.dart';
import 'package:babysitters_app/pages/parte1/registers/registropadres.dart';
import 'package:babysitters_app/pages/parte2/Menu_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';

class TestNotificaion extends StatefulWidget {
  const TestNotificaion({super.key});

  @override
  State<TestNotificaion> createState() => _TestNotificaionState();
}

class _TestNotificaionState extends State<TestNotificaion> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool loadings = false;
  @override
  void initState() {
    loadings = false;
    super.initState();
  }

  TextEditingController emailpas = TextEditingController();
  static final auth = FirebaseAuth.instance;
  var _status;
  Future resetPassword({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(email: email).then((value) {
        setState(() {
          olvide = false;
        });
      });
    } catch (e) {
      if (e.toString().contains(
          'There is no user record corresponding to this identifier. The user may have been deleted.')) {
        snac('Este correo no existe registrado');
      } else if (e
          .toString()
          .contains('The email address is badly formatted.')) {
        snac("Correo electronico no valido");
      } else {
        snac(e.toString());
      }
    }

    return _status;
  }

  void snac(String type) {
    final snackBar = SnackBar(
      backgroundColor: Colors.pink,
      content: Text('$type'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool register = false;
  bool olvide = false;
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      // backgroundColor: Colors.pink.shade50,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: media.height * 1,
              //Fondo Color Iconos
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Colors.red, Colors.blue, Colors.purple])),
              child: SingleChildScrollView(
                child: Column(
                  //colocar elementos en forma vertical
                  children: [
                    bannerApp(context),
                    Text('¡Inicia sesion rapidamente!',
                        style: /* TextStyle(
                          fontSize: 20,
                          fontFamily: 'OneDay',
                          fontWeight: FontWeight.bold), */
                            GoogleFonts.daysOne(
                                fontSize: 20, fontWeight: FontWeight.bold)),

                    const SizedBox(height: 50), //separación

                    textFielEmail(),
                    textFielContrasena(), const SizedBox(height: 30),
                    textNoCuenta("¿No tienes cuenta?", () {
                      setState(() {
                        register = true;
                      });
                    }),

                    bottonlogin(
                        colorprincipal, textColor1, "Ingresar", context),
                    textNoCuenta("Olvide mi contraseña", () {
                      setState(() {
                        olvide = true;
                      });
                    }),
                    //Llamamos al metodo
                  ],
                ),
              ),
            ),
            (loadings == true) ? Loading() : Container(),
            (register == true)
                ? Container(
                    width: media.width * 1,
                    height: media.height * 1,
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: media.width * 0.8,
                          height: media.width * 0.9,
                          color: textColor1,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                    width: media.width * 0.4,
                                    height: media.width * 0.4,
                                    child: Image.asset('assets/img/b.gif')),
                                SizedBox(
                                  height: 7,
                                ),
                                Text("¿Deseas registrarte?",
                                    style: GoogleFonts.poppins()),
                                SizedBox(
                                  height: 15,
                                ),
                                Text("Escoje el rol con el que te registraras",
                                    style: GoogleFonts.poppins()),
                                SizedBox(
                                  height: 25,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    InkWell(
                                        splashColor: Colors.pink,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RegistroPadres(),
                                              ));
                                        },
                                        child: Text("Padre",
                                            style: GoogleFonts.poppins())),
                                    InkWell(
                                        splashColor: Colors.pink,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RegistroNanas(),
                                              ));
                                        },
                                        child: Text("Niñera",
                                            style: GoogleFonts.poppins())),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              register = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: Icon(
                              Icons.close,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : Container(),
            (olvide == true)
                ? Container(
                    width: media.width * 1,
                    height: media.height * 1,
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: media.width * 0.8,
                          height: media.width * 0.9,
                          color: textColor1,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                    width: media.width * 0.4,
                                    height: media.width * 0.4,
                                    child: Image.asset('assets/img/nn.png')),
                                SizedBox(
                                  height: 7,
                                ),
                                Text("¿Olvidaste tu contraseña?",
                                    style: GoogleFonts.poppins()),
                                SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: emailpas,
                                    cursorColor: Colors.white,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                        labelText: 'Ingresa tu correo'),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) => value != null &&
                                            !EmailValidator.validate(value)
                                        ? 'Ingresa un correo valido'
                                        : null,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                CupertinoButton(
                                    child: Text("Solicitar"),
                                    onPressed: () {
                                      resetPassword(
                                          email: emailpas.text.trim());
                                    })
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              olvide = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: Icon(
                              Icons.close,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget bottonlogin(
      Color color, Color textColor, String text, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 45, vertical: 25),
      child: MaterialButton(
        onPressed: () async {
          //Primero verificara que los datos ingresados esten en el correcto formato, su respectivo @, su "." y sus minima de digitos en la clave, en caso contrario, retornara un snack
          if (emailFiel.text.isNotEmpty &&
              passwordFiel.text.isNotEmpty &&
              passwordFiel.text.length > 6 &&
              emailFiel.text.contains("@") &&
              emailFiel.text.contains(".")) {
            setState(() {
              loadings = true;
            });
            //Se verificara si el correo electrnico existe
            final signInMethods = await FirebaseAuth.instance
                .fetchSignInMethodsForEmail(emailFiel.text);
            //En caso de no existir, le retornara un push donde le solicitara registrarse
            if (signInMethods.isEmpty) {
              setState(() {
                setState(() {
                  loadings = false;
                });
                register = true;
              });
            } else {
              //En caso de existir, ingresara normalmente al menu
              {
                try {
                  final credential =
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailFiel.text,
                    password: passwordFiel.text,
                  );
                  setState(() {
                    loadings = false;
                    emailFiel.text = "";
                    passwordFiel.text = "";
                  });
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MenuScreen(),
                      ),
                      (route) => false);
                } on FirebaseAuthException catch (e) {
                  print(e);
                  if (e.code == 'weak-password') {
                    setState(() {
                      loadings = false;
                    });
                    print('La contraseña proporcionada es demasiado débil.');
                  } else if (e.code == 'email-already-in-use') {
                    setState(() {
                      loadings = false;
                    });
                    print('La cuenta ya existe para ese correo electrónico.');
                  } else if (e.toString().contains(
                      'The password is invalid or the user does not have a password.')) {
                    setState(() {
                      loadings = false;
                    });
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
                    setState(() {
                      loadings = false;
                    });
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
              content: Text(
                'Correo y contraseña deben ir completos',
                textAlign: TextAlign.center,
              ),
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

  TextEditingController emailFiel = TextEditingController();
  TextEditingController passwordFiel = TextEditingController();
  Widget textNoCuenta(String texts, var funtion) {
    return GestureDetector(
      onTap: funtion,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Text(
          texts,
          style: TextStyle(fontSize: 15, color: textColor1),
        ),
      ),
    );
  }

  Widget textFielEmail() {
    //Pedir Email
    return Container(
      decoration: BoxDecoration(
          color: textColor1,
          borderRadius: BorderRadius.all(Radius.circular(18))),
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          cursorColor: colorprincipal,
          controller: emailFiel,
          decoration: InputDecoration(
              hintText: 'Correo@gmail.com',
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorprincipal),
                  borderRadius: BorderRadius.all(Radius.circular(18))),
              suffixIcon: Icon(Icons.email_outlined, color: colorprincipal)),
        ),
      ),
    );
  }

  Widget textFielContrasena() {
    //Pedir contraseña
    //Pedir Email
    return Container(
      decoration: BoxDecoration(
          color: textColor1,
          borderRadius: BorderRadius.all(Radius.circular(18))),
      margin: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: passwordFiel,
          obscureText: true, //Colocar la contraseña en puntos

          decoration: InputDecoration(
              hintText: 'Contraseña',
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorprincipal),
                  borderRadius: BorderRadius.all(Radius.circular(18))),
              suffixIcon: Icon(Icons.password, color: colorprincipal)),
        ),
      ),
    );
  }

  Widget _textTypeUser(String typeUser) {
    //Metodo para invocar a usuarios, es privado agregando _

    return Text(
      typeUser,
      style: GoogleFonts.pacifico(
          color: Colors.black, fontSize: 25, fontWeight: FontWeight.w500),
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

  Widget bannerApp(BuildContext context) {
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
            Text('¡Tus niños, nuestra prioridad!',
                style: GoogleFonts.pacifico()),
          ],
        ),
      ),
    );
  }
}
