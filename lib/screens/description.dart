import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Description extends StatelessWidget {
  final String title, description, priority;
  final DateTime timestamp;

  const Description({
    Key? key,
    required this.title,
    required this.description,
    required this.priority,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[200],
        title: const Text('Description'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Description: $description',
              style: GoogleFonts.roboto(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Priority: $priority',
              style: GoogleFonts.roboto(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Date Added: ${DateFormat.yMd().add_jm().format(timestamp)}',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
