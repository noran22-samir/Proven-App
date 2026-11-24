import 'package:flutter/material.dart';
import 'add_project_page.dart';
import 'app_theme.dart';

class ClinicFlowApp extends StatelessWidget {
  const ClinicFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClinicFlow',
      theme: buildClinicFlowTheme(),
      home: const AddProjectPage(),
    );
  }
}
