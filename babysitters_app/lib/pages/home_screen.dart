import 'package:babysitters_app/pages/parte1/logins/loginselect.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TestNotificaion extends StatefulWidget {
  const TestNotificaion({super.key});

  @override
  State<TestNotificaion> createState() => _TestNotificaionState();
}

class _TestNotificaionState extends State<TestNotificaion> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Cada vez que se cree un nuevo documento :v
    /* void sendPushNotificationOnNewHelpDocument() async {
      // Inicializa el escuchador de eventos
      final helpDocuments = FirebaseFirestore.instance.collection('servicios');
      helpDocuments.snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((change) {
          // Si se ha creado un nuevo documento
          if (change.type == DocumentChangeType.added) {
            // Envía la notificación a todos los usuarios

            print(change.doc.id);
          }
        });
      });
    } */

    return Scaffold(
      // backgroundColor: Colors.pink.shade50,
      body: SafeArea(
        child: Container(
          //Fondo Color Iconos
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.red, Colors.blue, Colors.purple])),
          child: Column(
            //colocar elementos en forma vertical
            children: [
              bannerApp(context),
              Text('Selecciona tu rol!',
                  style: /* TextStyle(
                    fontSize: 20,
                    fontFamily: 'OneDay',
                    fontWeight: FontWeight.bold), */
                      GoogleFonts.daysOne(
                          fontSize: 20, fontWeight: FontWeight.bold)),

              const SizedBox(height: 50), //separación

              const SizedBox(height: 30),
              imageTypeUser('assets/img/padres.png', context, 'client'),
              const SizedBox(height: 10),
              _textTypeUser(
                  'Acudiente'), //Llamamos a  Acudiente mediante el metodo
              const SizedBox(height: 30),
              imageTypeUser('assets/img/ninera.png', context, 'niñera'),
              const SizedBox(height: 10),
              _textTypeUser('ninera'),
              const SizedBox(height: 10),
              iconAdmin(context, 'admin'),
              //Llamamos al metodo
            ],
          ),
        ),
      ),
    );
  }

  Widget iconAdmin(BuildContext context, String typeUser) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LoginAndRegisterDaddys(type: "admin"),
        ));
      },
      child: Container(
        height: 50,
        alignment: Alignment.bottomLeft,
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        child: const Icon(
          Icons.account_circle_rounded,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget imageTypeUser(String image, BuildContext context, String typeUser) {
    //metodo para invocar iconos de usuarios
    return GestureDetector(
      onTap: () {
        if (typeUser == "client") {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => LoginAndRegisterDaddys(type: "client"),
          ));
        } else if (typeUser == "niñera") {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => LoginAndRegisterDaddys(type: "ninera"),
          ));
        }
      },
      child: CircleAvatar(
        backgroundImage: AssetImage(image),
        radius: 50,
        backgroundColor: Colors.grey,
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
