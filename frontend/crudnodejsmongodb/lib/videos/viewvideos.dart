import 'package:crudnodejsmongodb/videos/showvideos.dart';
import 'package:crudnodejsmongodb/videos/videoplayerscreen.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../utils.dart';

class Viewvideos extends StatefulWidget {
  const Viewvideos({super.key});

  @override
  State<Viewvideos> createState() => _ViewvideosState();
}

class _ViewvideosState extends State<Viewvideos> {
  final String apiUrl = '$apiBaseUrl/api/videos';
  final searchController = TextEditingController();
  List uploads = [];
  List filteredUploads = [];
  bool isLoading = false;

  Future<void> fetchAllData() async {
    await fetchData(
      apiPath: '$apiBaseUrl/api/videos/',
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
        filteredUploads = uploads;
      });
      return;
    }
    setState(() {
      filteredUploads = uploads
          .where(
            (upload) =>
                upload['name'].toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredUploads.isEmpty
                      ? Center(child: Text("No videos found"))
                      : ListView.separated(
                          itemCount: filteredUploads.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: Colors.grey.shade300),
                          itemBuilder: (context, index) {
                            final video = filteredUploads[index];
                            final videoUrl = video['path'];
                            final videoName = video['name'] ?? 'Unnamed Video';
                            final videoAuthor =
                                'Uploader'; // သင့် API မှာရှိရင်ထည့်ပါ

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoPlayerScreen(
                                      id: video['_id'],
                                      videoUrl: videoUrl,
                                      videoName: videoName,
                                    ),
                                  ),
                                ).then((value) {
                                  if (value == true) {
                                    fetchAllData();
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 🔘 Video Thumbnail
                                    Container(
                                      width: 120,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.black12,
                                        borderRadius: BorderRadius.circular(6),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            "https://via.placeholder.com/150x100.png?text=Preview ",
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 12),

                                    // 📄 Video Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            videoName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            videoAuthor,
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            videoUrl,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Videos",
        onPressed: () async {
          await navigateAndRefresh(
            context: context,
            formBuilder: () => UploadScreen(),
            fetchAllData: fetchAllData,
          );
        },
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
