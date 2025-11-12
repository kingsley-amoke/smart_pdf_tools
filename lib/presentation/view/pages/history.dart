import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DocumentProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6),
          Text(
            'History',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Expanded(
            child: state.loading
                ? Center(child: CircularProgressIndicator())
                : state.recent.isEmpty
                ? Center(child: Text('No history yet'))
                : ListView.builder(
                    itemCount: state.recent.length,
                    itemBuilder: (context, i) {
                      final d = state.recent[i];
                      return ListTile(
                        leading: Icon(Icons.picture_as_pdf),
                        title: Text(d.title),
                        subtitle: Text(
                          '${(d.sizeBytes / 1024).toStringAsFixed(0)} KB',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.more_horiz),
                          onPressed: () {},
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
