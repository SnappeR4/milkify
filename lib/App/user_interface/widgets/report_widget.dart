import 'package:flutter/material.dart';

class ReportTableWidget extends StatelessWidget {
  final String text1;
  final String text2;
  final String text3;
  final String value1;
  final String value2;
  final VoidCallback onPressed;

  const ReportTableWidget({
    super.key,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.value1,
    required this.value2,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Table(
            border: TableBorder.all(),
            children: [
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(text1),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(text2),
                ),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(value1),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(value2),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onPressed,
                  child: Text(text3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
