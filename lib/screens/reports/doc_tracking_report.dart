import 'package:flutter/material.dart';

class DocTrackingReport extends StatefulWidget {
  const DocTrackingReport({super.key});

  @override
  State<DocTrackingReport> createState() => _DocTrackingReportState();
}

class _DocTrackingReportState extends State<DocTrackingReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document Tracking Report"),
      ),
      body: const Center(
        child: Text("Document Tracking Report"),
      ),
    );
  }
}