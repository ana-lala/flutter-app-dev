import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Future<void> showErrorDialog(
  BuildContext context, 
  String text,
  ) {
    return showDialog(
    context: context, 
    builder: (context) {
      return AlertDialog(
        title: const Text('An error ocurred'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            }, 
            child: const Text('OK'),
            )
        ],
      );
    },);
}