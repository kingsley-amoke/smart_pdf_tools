import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/data/apis/api_service.dart';
import 'package:smart_pdf_tools/data/repositories/document_repo_impl.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';
import 'package:smart_pdf_tools/pdf_smart_tools.dart';

void main() {
  final ApiService apiService = ApiService();

  final repo = DocumentRepositoryImpl(apiService: apiService);

  runApp(
    ChangeNotifierProvider(
      create: (_) => DocumentProvider(repo: repo),
      child: PdfSmartTools(),
    ),
  );
}
