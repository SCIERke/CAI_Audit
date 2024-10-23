import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedbackScreen extends StatefulWidget {
  final String productCode;

  FeedbackScreen({
    required this.productCode,
  });

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  Map<String, dynamic> branch = {};
  bool isLoading = true;

  Future<void> fetchData() async {
    final url = Uri.parse(
        'http://localhost:8000/branch_ErrorDetail/${widget.productCode}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          branch = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e); // Handle errors
    }
  }

  Future<void> resolveIssue() async {
    final url =
        Uri.parse('http://localhost:8000/audit_Feedback/${widget.productCode}');

    try {
      final response = await http.patch(url);
      if (response.statusCode == 200) {
        setState(() {
          Navigator.popUntil(context, (route) => route.isFirst);
        });
      } else {
        throw Exception('Failed to Resolve Issue');
      }
    } catch (e) {
      print(e); // Handle errors
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback from retail'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Loading spinner
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.red,
                    child: ListTile(
                      title: Text(widget.productCode,
                          style: TextStyle(color: Colors.white)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date of alert: ${branch['error_date'] ?? ''}',
                              style: TextStyle(color: Colors.white)),
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.white),
                              SizedBox(width: 5),
                              Text('This Product Data got an error',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildDetailText(
                      'BRANCH', 'Branch ${branch['branch_id'] ?? ''}'),
                  _buildDetailText('PRODUCT_CODE', widget.productCode),
                  _buildDetailText('Does this mistake actually occur?',
                      branch['is_check'] == false ? 'YES' : 'NO'),
                  SizedBox(height: 20),
                  _buildDetailText('Final feedback:', branch['feedback'] ?? ''),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        resolveIssue();
                      },
                      child: Text('Clear'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Flexible(
            child: Text(value, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
