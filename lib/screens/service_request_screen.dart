import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'address_screen.dart';
import '../models/service_request.dart';

class ServiceRequestScreen extends StatefulWidget {
  final String categoryName;
  final String subCategoryName;

  const ServiceRequestScreen({
    super.key,
    required this.categoryName,
    required this.subCategoryName,
  });

  @override
  State<ServiceRequestScreen> createState() =>
      _ServiceRequestScreenState();
}

class _ServiceRequestScreenState
    extends State<ServiceRequestScreen> {
  final TextEditingController issueController =
      TextEditingController();

  bool isEmergency = false;

  final ImagePicker _picker = ImagePicker();

  List<File> selectedPhotos = [];

  File? selectedVideo;

  Future<void> pickPhotos() async {
    final List<XFile> images =
        await _picker.pickMultiImage(
      imageQuality: 80,
    );

    if (images.isNotEmpty) {
      setState(() {
        selectedPhotos.addAll(
          images.map(
            (image) => File(image.path),
          ),
        );
      });
    }
  }

  Future<void> pickVideo() async {
    final XFile? video =
        await _picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (video != null) {
      setState(() {
        selectedVideo = File(video.path);
      });
    }
  }

  @override
  void dispose() {
    issueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Describe Your Issue"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [              Text(
                widget.categoryName,
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                widget.subCategoryName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Describe your issue",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: issueController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText:
                      "Describe the problem in detail...\n\n"
                      "Example:\n"
                      "The ceiling fan makes noise and stops after 5 minutes.",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Upload Photos (Optional)",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: pickPhotos,
                icon: const Icon(Icons.photo),
                label: const Text("Add Photos"),
              ),

              if (selectedPhotos.isNotEmpty) ...[
                const SizedBox(height: 15),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(
                    selectedPhotos.length,
                    (index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(12),
                            child: Image.file(
                              selectedPhotos[index],
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),

                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedPhotos.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 25),

              const Text(
                "Upload Video (Optional)",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: pickVideo,
                icon: const Icon(Icons.videocam),
                label: const Text("Add Video"),
              ),              if (selectedVideo != null) ...[
                const SizedBox(height: 15),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.video_file,
                        color: Colors.deepPurple,
                      ),

                      const SizedBox(width: 10),

                      const Expanded(
                        child: Text(
                          "1 video selected",
                        ),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedVideo = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),

              SwitchListTile(
                value: isEmergency,
                activeThumbColor: Colors.red,
                activeTrackColor: Colors.red.shade200,
                title: const Text(
                  "Emergency Service",
                ),
                subtitle: const Text(
                  "Need immediate assistance?",
                ),
                onChanged: (value) {
                  setState(() {
                    isEmergency = value;
                  });
                },
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (issueController.text
                        .trim()
                        .isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please describe your issue.",
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddressScreen(
                          request: ServiceRequest(
                            categoryName:
                                widget.categoryName,
                            subCategoryName:
                                widget.subCategoryName,
                            issueDescription:
                                issueController.text
                                    .trim(),
                            isEmergency:
                                isEmergency,
                            photos:
                                selectedPhotos,
                            video:
                                selectedVideo,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),            ],
          ),
        ),
      ),
    );
  }
}