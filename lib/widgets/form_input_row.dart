// widgets/form_screen/form_input_row.dart
import 'package:flutter/material.dart';

class FormInputRow extends StatelessWidget {
  final List<Widget> children;

  const FormInputRow({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children,
    );
  }
}