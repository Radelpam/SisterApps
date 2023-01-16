import 'package:babysitters_app/Styles/Styles.dart';
import 'package:babysitters_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stepper_counter_swipe/stepper_counter_swipe.dart';
import 'package:intl/intl.dart' as nt;
import 'package:babysitters_app/pages/parte2/Menu_Screen.dart' as mn;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ServiciosSolicitud extends StatefulWidget {
  var data;
  var phd;
  var phn;
  var preciofinal;
  ServiciosSolicitud(
      {required this.data, required this.phd, required this.phn});

  @override
  State<ServiciosSolicitud> createState() => _ServiciosSolicitudState();
}

class _ServiciosSolicitudState extends State<ServiciosSolicitud> {
  //Controladores
  TextEditingController observacionesController = TextEditingController();
  TextEditingController cantidadenanos = TextEditingController();
  TextEditingController direccionController = TextEditingController();
  TextEditingController ciudadController = TextEditingController();
  TextEditingController fechaInicioController = TextEditingController();
  TextEditingController fechaFinController = TextEditingController();
  TextEditingController cantidadhoras = TextEditingController();
  TextEditingController celularController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController diffController = TextEditingController();
  var valp = 2.0;
  var valn = 0.0;
  var valap;
  var valan = 0.0;
  var prf;
  @override
  void initState() {
    gettype();
    var date = TimeOfDay.now().hour;

    // TODO: implement initState
    super.initState();
  }

  var datas;
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

  String _selectedDate = '';
  String _dateCount = '';
  String _range1 = '';
  String _range2 = '';
  String _rangeCount = '';
  String horainicio = "";
  var cantidad;
  String error = "";

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        setState(() {
          _range1 =
              '${nt.DateFormat('dd/MM/yyyy').format(args.value.startDate)}';
        });
      } else if (args.value is DateTime) {
        _selectedDate = '${nt.DateFormat('dd/MM/yyyy').format(args.value)}';
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }

  final formatCurrency = nt.NumberFormat.simpleCurrency();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              bannerApp(context, "${widget.data['nombre']}"),
              Text(
                "Fecha del servicio",
                style: TextStyle(
                    fontFamily: 'omegle',
                    fontSize: 15,
                    color: Colors.blueAccent.shade200),
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: SfDateRangePicker(
                    onSelectionChanged: _onSelectionChanged,
                    selectionMode: DateRangePickerSelectionMode.single,
                    initialSelectedRange: PickerDateRange(
                        DateTime.now().add(const Duration(days: 1)),
                        DateTime.now().add(const Duration(days: 1))),
                  )),
              (_range1 != null)
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          error = "";
                          valp = 2;
                          valn = 0;
                          prf = null;
                        });
                        tim();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: colorprincipal,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            border: Border.all(color: coloricons)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Hora de inicio",
                            style: GoogleFonts.poppins(color: textColor1),
                          ),
                        ),
                      ),
                    )
                  : Container(),
              (prf != null)
                  ? Text(
                      "Duración del servicio (${(valp).round()} horas)",
                      style: GoogleFonts.poppins(
                          fontSize: 15, color: Colors.blueAccent.shade200),
                    )
                  : Container(),
              (prf != null)
                  ? Container(
                      child: Slider(
                        value: valp,
                        min: 2,
                        max: 8,
                        divisions: 8,
                        onChanged: (values) {
                          valap = valp;
                          valp = values;
                          if (valp > valap) {
                            print(prf);
                            print(widget.preciofinal);
                            setState(() {
                              widget.preciofinal += prf;
                            });
                          } else if (valp < valap) {
                            setState(() {
                              widget.preciofinal -= prf;
                            });
                          }
                        },
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 10,
              ),
              (prf != null)
                  ? Text(
                      "Número de niños: ${(valn).round()}",
                      style: GoogleFonts.poppins(
                          fontSize: 15, color: Colors.blueAccent.shade200),
                    )
                  : Container(),
              (prf != null)
                  ? Container(
                      child: Slider(
                        value: valn,
                        min: 0,
                        max: 10,
                        divisions: 10,
                        onChanged: (values) {
                          valan = valn;
                          valn = values;
                          if (valn > valan && values > 4) {
                            widget.preciofinal += 4000;
                          } else if (valn < valan && values >= 4) {
                            widget.preciofinal -= 4000;
                          }
                          setState(() {
                            valn = values;
                          });
                        },
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 50,
              ),
              (_selectedDate != null && (prf != null))
                  ? Text(
                      "Valor a pagar (COP)",
                      style: TextStyle(
                          fontFamily: 'omegle',
                          fontSize: 15,
                          color: Colors.blueAccent.shade200),
                    )
                  : Container(),
              (_selectedDate != null && (prf != null))
                  ? Text(
                      "${formatCurrency.format((widget.preciofinal != null) ? widget.preciofinal : 0)}",
                      style: TextStyle(
                          fontFamily: 'omegle',
                          fontSize: 35,
                          color: colorprincipal),
                    )
                  : Container(),
              (_selectedDate != null && (prf != null))
                  ? Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: TextField(
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        controller: observacionesController,
                        decoration: InputDecoration(
                            labelText: '',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0)),
                            suffixIcon:
                                const Icon(Icons.edit, color: Colors.pink)),
                      ),
                    )
                  : Container(),
              (_selectedDate != null && prf != null)
                  ? buttonall(() {
                      if (valn != 0) {
                        setState(() {
                          error = "";
                        });
                        descpackage(widget.preciofinal, valn,
                            fechaInicioController.text);
                      } else {
                        setState(() {
                          error = "Debes tener almenos un niño seleccionado";
                        });
                      }
                    }, "Verifiar datos")
                  : Container(),
              (error != '')
                  ? Text(
                      error,
                      style: GoogleFonts.poppins(color: Colors.red),
                    )
                  : Container()
            ],
          )),
    );
  }

  tim() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!);
      },
    );
    var temp;
    var timeaact = (TimeOfDay.now().hour + 2);

    /* switch (timeaact) {
      case 24:
        temp = 0;
        break;
      case 25:
        temp = 1;
        break;
      default:
        temp = timeaact;
        break;
    } */

    if (newTime != null) {
      if (newTime.hour >= timeaact) {
        temp = timeaact;
        setState(() {
          horainicio = "${newTime.hour}:${newTime.minute}";
        });
      } else {
        tim();
      }

      //precio dependiendo de la hora escogida
      if (newTime.hour >= 18) {
        setState(() {
          widget.preciofinal = widget.phn;
          prf = widget.phn;
        });
      } else if (newTime.hour < 6) {
        setState(() {
          widget.preciofinal = widget.phn;
          prf = widget.phn;
        });
      } else {
        setState(() {
          widget.preciofinal = widget.phd;
          prf = widget.phd;
        });
      }
    }
  }

  Future<void> descpackage(var total, var ninos, var fecha) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(top: 10),
          height: 400,
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Text(
                    "Total precio: ${formatCurrency.format(total)}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pacifico(
                        fontSize: 30, color: colorprincipal),
                  ),
                  SizedBox(
                    width: 400,
                    child: Text(
                      "Fecha de trabajo: $_selectedDate",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 104, 104, 104)),
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    child: Text(
                      "tiempo de trabajo: ${(valp).round()} Horas",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 104, 104, 104)),
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    child: Text(
                      "direccion: ${datas['direccion']}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 104, 104, 104)),
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    child: Text(
                      "Telefono de contacto: ${datas['celular']}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 104, 104, 104)),
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    child: Text(
                      "Ciudad: ${datas['ciudad']}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 104, 104, 104)),
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    child: Text(
                      "Observaciones: ${observacionesController.text}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 104, 104, 104)),
                    ),
                  ),
                  buttonall(() {
                    addUser();
                  }, "Solicitar niñeras")
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  CollectionReference users =
      FirebaseFirestore.instance.collection('servicios');
  CollectionReference userdata = FirebaseFirestore.instance.collection('users');

  Future<void> addUser() async {
    // Call the user's CollectionReference to add a new user
    var succes;
    await users.add({
      'cantidadHoras': widget.preciofinal,
      'cantidadenanos': valn,
      'Horas': valp,
      'celular': datas['celular'],
      'direccion': datas['direccion'],
      'fecha': fechaInicioController.text,
      'municipio': datas['ciudad'],
      'NombreUsuario': datas['name'],
      'idUsuario': FirebaseAuth.instance.currentUser!.uid,
      'estado': true,
      'tipo': widget.data['nombre'],
      'precio': widget.preciofinal,
      'observaciones': observacionesController.text,
      'Hora': horainicio,
      'DiasTotal': cantidad,
      'fechainicial': _selectedDate,
      'terminado': false,
      'FechaCreado': DateTime.now()
    }).then((value) async {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    }).catchError((error) => succes == false);
    return succes;
    /* return users
          .add({
            
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error")); */
  }

  Widget buttonall(var ff, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 45, vertical: 25),
      child: MaterialButton(
        color: colorprincipal,
        onPressed: ff,
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

  Widget bannerApp(BuildContext context, String name) {
    //metodo para invocar la parte superior
    return ClipPath(
      //Fondo de los iconos

      child: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height * 0.30,
        width: MediaQuery.of(context).size.width * 1,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset("assets/img/icono.png"),
              Text('¡Bienvenido,al $name!', style: GoogleFonts.pacifico()),
            ],
          ),
        ),
      ),
    );
  }
}
