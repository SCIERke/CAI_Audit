import 'package:flutter/material.dart';
import 'errordetail_page.dart';
import 'feedback_page.dart';
import 'uploadfile_page.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '7-11 Branches',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: BranchList(),
    );
  }
}

class BranchList extends StatefulWidget {
  @override
  _BranchListState createState() => _BranchListState();
}

class BranchCard extends StatelessWidget {
  final Map<String, dynamic> branch;
  final VoidCallback onQuickAccess;

  BranchCard({required this.branch, required this.onQuickAccess});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: branch['is_error'] ? Colors.red : Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Image.asset(
              'assets/pngegg.png',
              height: 80,
            ),
            Text(
              'Branch ' + branch['branch_id'],
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            if (branch['is_error'])
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                  onPressed: onQuickAccess,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.access_alarm, color: Colors.red),
                      SizedBox(width: 8),
                      Text('quick access', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BranchListState extends State<BranchList> {
  List<Map<String, dynamic>> branches = [];
  List<Map<String, dynamic>> filteredBranches = [];

  TextEditingController searchController = TextEditingController();

  void resolveIssue(int branchId) {
    setState(() {
      branches.firstWhere(
          (branch) => branch['branch_id'] == branchId)['is_error'] = false;
      filteredBranches =
          branches; // Update filtered list after resolving the issue
    });
  }

  Future<void> fetchData() async {
    final url = Uri.parse('http://localhost:8000/branch_ErrorList');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          // Cast the decoded data to List<Map<String, dynamic>>
          branches =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          print(branches);
          branches.sort((a, b) {
            if (a['is_error'] == b['is_error']) {
              return a['branch_id'].compareTo(b['branch_id']);
            }
            return a['is_error'] ? -1 : 1;
          });
          filteredBranches =
              branches; // Initially, the filtered list is the same as the full list
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e); // Handle errors
    }
  }

  void _refreshDataOnReturn() async {
    // Trigger data fetching again when the screen is reloaded
    await fetchData();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void _filterBranches() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredBranches = branches.where((branch) {
        return branch['branch_id'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset('assets/ce00aca9cb774dbb1c13a664bdfb90da.png',
              width: 110),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/4DQpjUtzLUwmJZZSGobOaoB2l01CJneHJRJAJg0MevRX.jpg'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.add_box_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FileUploadPage()),
              );
            },
            tooltip: 'Go to File Upload',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          SearchBar(controller: searchController),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 3 / 4,
              ),
              itemCount: filteredBranches.length,
              itemBuilder: (context, index) {
                final branch = filteredBranches[index];
                return BranchCard(
                  branch: branch,
                  onQuickAccess: () async {
                    if (branch['is_error']) {
                      // Navigate to the detail page and wait for result when coming back
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ErrorDetailPage(
                            productCode: branch['product_code'],
                            onSeeFeedback: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FeedbackScreen(
                                    productCode: branch['product_code'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                      // When the user comes back from the detail page, refetch the data
                      if (result != null && result == 'updated') {
                        _refreshDataOnReturn();
                      }
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController controller;

  SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search reported history',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
