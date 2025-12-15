import 'package:flutter/material.dart';
import 'package:smart_pdf_tools/domain/models/split_method.dart';

class MethodSelector extends StatefulWidget {
  MethodSelector({
    super.key,
    required this.selectedMethod,
    required this.pagesPerSplitController,
    required this.rangesController,
    required this.pageCount,
  });

  SplitMethod selectedMethod;
  TextEditingController rangesController;
  TextEditingController pagesPerSplitController;
  int? pageCount;

  @override
  State<MethodSelector> createState() => _MethodSelectorState();
}

class _MethodSelectorState extends State<MethodSelector> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Split Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (widget.selectedMethod == SplitMethod.ranges) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: widget.rangesController,
                  decoration: InputDecoration(
                    hintText: '1-3, 5, 7-10',
                    border: const OutlineInputBorder(),
                    suffixIcon: widget.pageCount != null
                        ? Tooltip(
                            message: 'Total pages: $widget.pageCount',
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            RadioGroup(
              groupValue: widget.selectedMethod,
              onChanged: (value) {
                setState(() {
                  widget.selectedMethod = value!;
                });
              },
              child: Column(
                children: [
                  RadioListTile<SplitMethod>(
                    title: const Text('By Page Ranges'),
                    subtitle: const Text('e.g., 1-3, 5, 7-10'),
                    value: SplitMethod.ranges,
                  ),
                  RadioListTile<SplitMethod>(
                    title: const Text('Individual Pages'),
                    subtitle: const Text('One page per file'),
                    value: SplitMethod.individual,
                  ),
                  RadioListTile<SplitMethod>(
                    title: const Text('Every N Pages'),
                    subtitle: const Text('Split into equal chunks'),
                    value: SplitMethod.everyN,
                  ),
                ],
              ),
            ),

            if (widget.selectedMethod == SplitMethod.everyN) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: widget.pagesPerSplitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Pages per split',
                    hintText: '3',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
