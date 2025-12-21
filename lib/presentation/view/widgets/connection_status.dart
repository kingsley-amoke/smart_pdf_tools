import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/connection_message_snack.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class ConnectionStatus extends StatefulWidget {
  const ConnectionStatus({super.key});

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentProvider>(
      builder: (context, provider, child) {
        return IconButton(
          color: provider.isConnected ? Colors.green : Colors.red,
          icon: Icon(provider.isConnected ? Icons.cloud_done : Icons.cloud_off),
          onPressed: () {
            provider.checkConnection();
            showConnectionMessage(
              context,
              connectionState: provider.connectionState,
              message: provider.connectionMessage,
            );
          },
        );
      },
    );
  }
}
