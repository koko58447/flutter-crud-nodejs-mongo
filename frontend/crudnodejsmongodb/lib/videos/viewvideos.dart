import 'package:crudnodejsmongodb/videos/showvideos.dart'; // သင့်ရဲ့ video player screen
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
      appBar: AppBar(title: const Text('Videos'), centerTitle: true),
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
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredUploads.isEmpty
                      ? Center(child: Text("No videos found"))
                      : ListView.builder(
                          itemCount: filteredUploads.length,
                          itemBuilder: (context, index) {
                            final video = filteredUploads[index];
                            final videoUrl = video['path'];
                            final videoName = video['name'];

                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoPlayerScreen(
                                        videoUrl: videoUrl,
                                        videoName: videoName,
                                      ),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    child: Icon(Icons.video_library),
                                  ),
                                  title: Text(
                                    videoName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Text(videoUrl),
                                  trailing: Icon(Icons.arrow_forward_ios),
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
        backgroundColor: Colors.blueAccent,
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
