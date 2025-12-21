import 'package:flutter/material.dart';
import 'package:smart_pdf_tools/domain/models/connection_state.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/error_message.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/info_message.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/success_message.dart';

void showConnectionMessage(
  BuildContext context, {
  required ApiConnectionState connectionState,
  required String message,
}) {
  final snack = switch (connectionState) {
    ApiConnectionState.info => infoMessageSnackBar(message),

    ApiConnectionState.success => successMessageSnackBar(message),

    ApiConnectionState.error => errorMessageSnackBar(message),
  };

  ScaffoldMessenger.of(context).showSnackBar(snack);
}
