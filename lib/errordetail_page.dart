import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ErrorDetailPage extends StatefulWidget {
  final String productCode;
  final VoidCallback onSeeFeedback;

  ErrorDetailPage({
    required this.productCode,
    required this.onSeeFeedback,
  });

  @override
  _ErrorDetailPageState createState() => _ErrorDetailPageState();
}

class _ErrorDetailPageState extends State<ErrorDetailPage> {
  Map<String, dynamic> branch = {};
  bool isLoading = true;

  Future<void> fetchData() async {
    final url = Uri.parse(
        'http://localhost:8000/branch_ErrorDetail/${widget.productCode}');

    try {
      final response = await http.get(url);

      print(response.statusCode);

      if (response.statusCode == 200) {
        setState(() {
          branch = json.decode(response.body);
          isLoading = false; // Data has been loaded
        });
      } else {
        throw Exception('Failed to load data');
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
        title: Text('Error Detail'),
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
                      'PRODUCT_CODE', branch['product_code'] ?? ''),
                  _buildDetailText('BRANCH_ID', branch['branch_id'] ?? ''),
                  _buildDetailText('REC_TYPE', branch['rec_type'] ?? ''),
                  _buildDetailText('DOC_TYPE', branch['doc_type'] ?? ''),
                  _buildDetailText('TRANS_TYPE', branch['trans_type'] ?? ''),
                  _buildDetailText('DOC_DATE', branch['doc_date'] ?? ''),
                  _buildDetailText('DOC_NO', branch['doc_no'] ?? ''),
                  _buildDetailText('REASON_CODE', branch['reason_code'] ?? ''),
                  _buildDetailText('CV_CODE', branch['cv_code'] ?? ''),
                  _buildDetailText('PMA_CODE', branch['pma_code'] ?? ''),
                  _buildDetailText(
                      'CATEGORY_CODE', branch['category_code'] ?? ''),
                  _buildDetailText(
                      'SUBCATEGORY_CODE', branch['subcategory_code'] ?? ''),
                  _buildDetailText('QTY', branch['quantity']?.toString() ?? ''),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: widget.onSeeFeedback,
                      child: Text('See Feedback'),
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
          Text(value),
        ],
      ),
    );
  }
}
