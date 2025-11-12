import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final FormFieldValidator<String>? validator;

  const TextInput({super.key, required this.label, required this.controller, this.hintText, this.validator});

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  Color primaryColor = const Color.fromARGB(255, 161, 29, 28);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        TextFormField(
          controller: widget.controller,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: widget.hintText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: widget.validator,
        ),
        SizedBox(height: 20,),
      ],
    );
  }
}
