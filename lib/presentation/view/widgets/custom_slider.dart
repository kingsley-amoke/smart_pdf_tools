import 'package:flutter/material.dart';

class CustomSlider extends StatelessWidget {
  const CustomSlider({super.key, required this.value, required this.onChanged});

  final double value;
  final void Function(double)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: value,
            min: 50,
            max: 100,
            divisions: 10,
            label: '${value.toInt()}%',
            activeColor: Colors.blue,
            onChanged: onChanged,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${value.toInt()}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
