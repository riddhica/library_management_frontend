// utils/custom_widgets.dart
import 'package:flutter/material.dart';

Widget customButton(String text, VoidCallback onPressed, {Color color = Colors.blue}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(primary: color, padding: EdgeInsets.symmetric(vertical: 15.0)),
    child: Text(text, style: TextStyle(fontSize: 18)),
  );
}

Widget customTextField(TextEditingController controller, String labelText, {bool isNumber = false}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(),
    ),
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
  );
}
