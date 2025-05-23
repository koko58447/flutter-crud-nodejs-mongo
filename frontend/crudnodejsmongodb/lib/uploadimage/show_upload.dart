import '/uploadimage/form_upload.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import '../utils.dart';

class ShowUpload extends StatefulWidget {
  const ShowUpload({super.key});

  @override
  _ShowUploadState createState() => _ShowUploadState();
}

class _ShowUploadState extends State<ShowUpload> {
  final String apiUrl = '$apiBaseUrl/api/uploads';
  final searchController = TextEditingController();
  List uploads = [];
  List filteredUploads = [];
  bool isLoading = false;

  Future<void> fetchAllData() async {
    await fetchData(
      apiPath: '$apiBaseUrl/api/uploads',
      onSuccess: (data) {
        setState(() {
          uploads = data;
          filteredUploads = data;
        });
      },
      onError: (message) {
        showSnackBar(context, message);
      },
      onLoadingStart: () {
        setState(() {
          isLoading = true;
        });
      },
      onLoadingEnd: () {
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredUploads = uploads; // Reset to original list
      });
      return;
    }
    setState(() {
      filteredUploads = uploads.where((upload) {
        String name = upload['name'].toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAllData();
    searchController.addListener(() {
      filterSearchResults(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uploaded Files')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by name ",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Mobile View
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                    itemCount: filteredUploads.length,
                    itemBuilder: (context, index) {
                      final upload = filteredUploads[index];
                      final imageUrl = '$apiBaseUrl/${upload['path']}'
                          .replaceAll(r'\', '/');
                      return _buildGridItem(context, upload, imageUrl);
                    },
                  );
                } else {
                  // Tablet or Desktop View - Full width table
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columnSpacing: 200,
                        columns: const [
                          DataColumn(label: Text("Image")),
                          DataColumn(label: Text("Name")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: filteredUploads.map((upload) {
                          final imageUrl = '$apiBaseUrl/${upload['path']}'
                              .replaceAll(r'\', '/');
                          return DataRow(
                            cells: [
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FullScreenImage(
                                          imageUrl: imageUrl,
                                          deleteApiUrl: apiUrl,
                                          id: upload['_id'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  upload['name'] ?? 'Unknown',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FullScreenImage(
                                          imageUrl: imageUrl,
                                          deleteApiUrl: apiUrl,
                                          id: upload['_id'],
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      fetchAllData(); // Refresh the list
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await navigateAndRefresh(
            context: context,
            formBuilder: () => const FormUpload(), // Pass the form widget
            fetchAllData: fetchAllData, // Pass the data refresh function
          );
        }, // Add icon
        backgroundColor: Colors.blue,
        child: Icon(Icons.add), // Optional: Change button color
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, dynamic upload, String imageUrl) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenImage(
              imageUrl: imageUrl,
              deleteApiUrl: apiUrl,
              id: upload['_id'],
            ),
          ),
        );
        if (result == true) {
          fetchAllData(); // Refresh the list
        }
      },
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                upload['name'] ?? 'Unknown Name',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String deleteApiUrl; // API URL for deleting the image

  const FullScreenImage({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.deleteApiUrl,
  });

  Future<void> deleteImage(BuildContext context, id) async {
    print('$deleteApiUrl/$id');
    try {
      final response = await http.delete(Uri.parse('$deleteApiUrl/$id'));
      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image deleted successfully')),
        );
        // Navigate back to the previous screen
        Navigator.pop(context, true); // Pass true to indicate deletion
      } else {
        // Show error message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to delete image')));
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // Confirm deletion
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Image'),
                  content: const Text(
                    'Are you sure you want to delete this image?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await deleteImage(context, id);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
