// import 'package:crudmongodb/uploadimage/form_upload.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ShowUpload extends StatefulWidget {
//   @override
//   _ShowUploadState createState() => _ShowUploadState();
// }

// class _ShowUploadState extends State<ShowUpload> {
//   final String apiUrl = '$apiBaseUrl/api/uploads";

//   Future<List<dynamic>> fetchUploads() async {
//     final response = await http.get(Uri.parse(apiUrl));
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load uploads');
//     }
//   }

//   int getCrossAxisCount(double width) {
//     if (width >= 1024) {
//       return 6;
//     } else if (width >= 600) {
//       return 4;
//     } else {
//       return 2;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Uploaded Files'),
//       ),
//       body: FutureBuilder<List<dynamic>>(
//         future: fetchUploads(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No uploads found'));
//           } else {
//             final uploads = snapshot.data!;
//             final screenWidth = MediaQuery.of(context).size.width;
//             final crossAxisCount = getCrossAxisCount(screenWidth);

//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: crossAxisCount,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                 ),
//                 itemCount: uploads.length,
//                 itemBuilder: (context, index) {
//                   final upload = uploads[index];

//                   final imageUrl = '$apiBaseUrl/${upload['path']}'
//                       .replaceAll(r'\', '/');

//                   return GestureDetector(
//                     onTap: () async {
//                       final result = await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => FullScreenImage(
//                             imageUrl: imageUrl,
//                             deleteApiUrl: apiUrl,
//                             id: upload['_id'],
//                           ),
//                         ),
//                       );
//                       if (result == true) {
//                         setState(() {
//                           fetchUploads();
//                         }); // Refresh the state to show new uploads

//                       }
//                     },
//                     child: Card(
//                       elevation: 5,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           Expanded(
//                             child: Image.network(
//                               imageUrl,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   Icon(Icons.broken_image),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               upload['name'],
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             );
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           // Add your action here
//           // Navigate to InsertForm screen
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => FormUpload()),
//           );
//           if (result == true) {
//             setState(() {
//               fetchUploads();
//             }); // Refresh the state to show new uploads

//           }
//         },
//         child: Icon(Icons.add), // Add icon
//         backgroundColor: Colors.blue, // Optional: Change button color
//       ),
//     );
//   }
// }

import 'package:crudmongodb/uploadimage/form_upload.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';

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

  Future<void> fetchUploads() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        uploads = json.decode(response.body);
        filteredUploads = uploads; // Initialize filtered list
      });
    } else {
      throw Exception('Failed to load uploads');
    }
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

  int getCrossAxisCount(double width) {
    if (width >= 1024) {
      return 6;
    } else if (width >= 600) {
      return 4;
    } else {
      return 2;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUploads();
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
      appBar: AppBar(
        title: const Text('Uploaded Files'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by name or email",
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
                final crossAxisCount = getCrossAxisCount(constraints.maxWidth);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: filteredUploads.length,
                    itemBuilder: (context, index) {
                      final upload = filteredUploads[index];
                      final imageUrl =
                          '$apiBaseUrl/${upload['path']}'
                              .replaceAll(r'\', '/');
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
                            setState(() {
                              fetchUploads();
                            }); // Refresh the state to show new uploads

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
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Add your action here
          // Navigate to InsertForm screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FormUpload()),
          );
          if (result == true) {
            setState(() {
              fetchUploads();
            }); // Refresh the state to show new uploads

          }
        }, // Add icon
        backgroundColor: Colors.blue,
        child: Icon(Icons.add), // Optional: Change button color
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String deleteApiUrl; // API URL for deleting the image

  const FullScreenImage(
      {super.key, required this.id, required this.imageUrl, required this.deleteApiUrl});

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete image')),
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
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
                  content: const Text('Are you sure you want to delete this image?'),
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
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
