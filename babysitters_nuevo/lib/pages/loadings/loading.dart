import 'package:babysitters_app/Styles/Styles.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      color: colorprincipal.withOpacity(0.6),
      width: media.width * 1,
      height: media.height * 1,
      child: Center(
          child: CircularProgressIndicator(
        color: textColor1,
      )),
    );
  }
}
