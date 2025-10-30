import 'package:flutter/material.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  Color primaryColor = const Color.fromARGB(255, 161, 29, 28);
  Color myGrey = Color(0xFFECECEC);
  final _formKey = GlobalKey<FormState>();

  String selected = "Success";
  final List<String> filters = ["Danger", "Success", "Primary", "Warning"];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Event'), backgroundColor: myGrey),
      backgroundColor: myGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          controller: _scrollController,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Event Title",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.black),
                  keyboardType: const TextInputType.numberWithOptions(),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    focusColor: primaryColor,
                    hoverColor: primaryColor,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Text(
                  "Event Type",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Wrap(
                      spacing: 13.0,
                      children: filters.map((filter) {
                        return ChoiceChip(
                          label: Text(filter),
                          selected: selected == filter,
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: selected == filter
                                ? Colors.white
                                : primaryColor,
                          ),
                          backgroundColor: Colors.white,
                          side:  BorderSide(
                            color: primaryColor,
                          ),
                          onSelected: (bool value) {
                            setState(() {
                              selected = filter;
                            });
                          },

                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  "Starting Date",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextFormField(
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    focusColor: primaryColor,
                    hoverColor: primaryColor,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Starting date is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Text( 
                  "Ending Date",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    focusColor: primaryColor,
                    hoverColor: primaryColor,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Ending date is required';
                    }
                    return null;
                  },
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
