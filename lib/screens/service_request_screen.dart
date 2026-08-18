import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'address_screen.dart';
import '../models/service_request.dart';

class ServiceRequestScreen extends StatefulWidget {
  final String categoryName;
  final String subCategoryName;

  // ============================================================
  // SUBCATEGORY ID
  // ============================================================
  //
  // This is the SAME id professionals select on their side during
  // onboarding (see ProfessionalCategory / subcategoryIds on the
  // professional app). It is used directly as the request's
  // capabilityId so matching compares real category ids instead
  // of guessing from free-text description.
  //

  final String subCategoryId;

  // Main category id (e.g. "appliances") the subcategory belongs
  // to — used as a fallback match if no professional's exact
  // subcategoryIds contains subCategoryId.
  final String categoryId;

  const ServiceRequestScreen({
    super.key,
    required this.categoryName,
    required this.subCategoryName,
    required this.subCategoryId,
    this.categoryId = '',
  });

  @override
  State<ServiceRequestScreen> createState() =>
      _ServiceRequestScreenState();
}

class _ServiceRequestScreenState
    extends State<ServiceRequestScreen> {
  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color pageBackground = Color(0xFFF7F8FC);

  final TextEditingController issueController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();

  bool isEmergency = false;

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

  void _continue() {
    if (issueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please describe your issue.",
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // FIREBASE AUTHENTICATED CUSTOMER
    // ==========================================================

    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please log in before creating a service request.",
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
                issueController.text.trim(),
            isEmergency:
                isEmergency,
            photos:
                selectedPhotos,
            video:
                selectedVideo,

            // ==================================================
            // CAPABILITY / REQUEST TYPE
            // ==================================================
            //
            // Use the real subcategory id the customer picked
            // (e.g. "air_conditioner") as the capability to match
            // against, instead of re-guessing it from free text
            // later. This is the same id professionals register
            // under during onboarding.
            //

            capabilityId:
                widget.subCategoryId.isEmpty
                    ? null
                    : widget.subCategoryId,

            requestTypeId:
                widget.subCategoryId.isEmpty
                    ? null
                    : widget.subCategoryId,

            categoryId:
                widget.categoryId.isEmpty
                    ? null
                    : widget.categoryId,

            // ==================================================
            // IMPORTANT:
            // REAL FIREBASE AUTH UID
            // ==================================================

            customerId:
                currentUser.uid,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: darkText,
        title: const Text(
          "Describe Your Issue",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildServiceHeader(),

              const SizedBox(height: 28),

              _buildIssueSection(),

              const SizedBox(height: 26),

              _buildMediaSection(),

              const SizedBox(height: 26),

              _buildEmergencyCard(),

              const SizedBox(height: 30),

              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color:
              const Color(0xFFE5EAF1),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFEEF3FF),
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),
            child: const Icon(
              Icons.build_circle_outlined,
              color: primaryBlue,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryName,
                  style:
                      const TextStyle(
                    color: primaryBlue,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.subCategoryName,
                  style:
                      const TextStyle(
                    color: darkText,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "What’s wrong?",
          style: TextStyle(
            color: darkText,
            fontSize: 24,
            fontWeight:
                FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          "Tell us what is happening so the right professional can help.",
          style: TextStyle(
            color: secondaryText,
            fontSize: 14,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 14),

        Container(
          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color:
                  const Color(0xFFDCE3EC),
            ),
          ),
          child: TextField(
            controller:
                issueController,
            maxLines: 7,
            textCapitalization:
                TextCapitalization.sentences,
            style:
                const TextStyle(
              color: darkText,
              fontSize: 16,
              height: 1.45,
            ),
            decoration:
                const InputDecoration(
              border:
                  InputBorder.none,
              contentPadding:
                  EdgeInsets.fromLTRB(
                17,
                16,
                17,
                16,
              ),
              hintText:
                  "Describe the problem...",
              hintStyle:
                  TextStyle(
                color:
                    Color(0xFF64748B),
                fontSize: 16,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(13),
          decoration:
              BoxDecoration(
            color:
                const Color(0xFFEEF3FF),
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                Icons
                    .lightbulb_outline_rounded,
                color: primaryBlue,
                size: 20,
              ),

              SizedBox(width: 9),

              Expanded(
                child: Text(
                  "Example: The ceiling fan makes noise and stops after 5 minutes.",
                  style: TextStyle(
                    color:
                        Color(0xFF475569),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "Help the professional understand",
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          "Photos or a video are optional, but they can help.",
          style: TextStyle(
            color: secondaryText,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _mediaButton(
                icon:
                    Icons.photo_camera_outlined,
                label: "Add Photos",
                onTap: pickPhotos,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _mediaButton(
                icon:
                    Icons.videocam_outlined,
                label: "Add Video",
                onTap: pickVideo,
              ),
            ),
          ],
        ),

        if (selectedPhotos.isNotEmpty) ...[
          const SizedBox(height: 15),

          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection:
                  Axis.horizontal,
              itemCount:
                  selectedPhotos.length,
              separatorBuilder:
                  (_, __) =>
                      const SizedBox(
                width: 10,
              ),
              itemBuilder:
                  (context, index) {
                return Stack(
                  clipBehavior:
                      Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                      child: Image.file(
                        selectedPhotos[
                            index],
                        width: 82,
                        height: 82,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Positioned(
                      top: -5,
                      right: -5,
                      child:
                          GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPhotos
                                .removeAt(
                              index,
                            );
                          });
                        },
                        child: Container(
                          height: 23,
                          width: 23,
                          decoration:
                              const BoxDecoration(
                            color:
                                Color(0xFF0F172A),
                            shape:
                                BoxShape.circle,
                          ),
                          child:
                              const Icon(
                            Icons.close,
                            color:
                                Colors.white,
                            size: 14,
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

        if (selectedVideo != null) ...[
          const SizedBox(height: 12),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 10,
            ),
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              border: Border.all(
                color:
                    const Color(0xFFE1E7EF),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(0xFFEEF3FF),
                    borderRadius:
                        BorderRadius.circular(
                      11,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .video_file_outlined,
                    color: primaryBlue,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    "Video selected",
                    style: TextStyle(
                      color: darkText,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedVideo = null;
                    });
                  },
                  icon: const Icon(
                    Icons
                        .delete_outline_rounded,
                    color:
                        Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _mediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style:
          OutlinedButton.styleFrom(
        backgroundColor:
            Colors.white,
        foregroundColor:
            primaryBlue,
        side:
            const BorderSide(
          color:
              Color(0xFFDCE3EC),
        ),
        padding:
            const EdgeInsets.symmetric(
          vertical: 14,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            15,
          ),
        ),
      ),
      icon: Icon(
        icon,
        size: 21,
      ),
      label: Text(
        label,
        style:
            const TextStyle(
          fontSize: 14,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return AnimatedContainer(
      duration:
          const Duration(
        milliseconds: 200,
      ),
      padding:
          const EdgeInsets.fromLTRB(
        16,
        15,
        12,
        15,
      ),
      decoration:
          BoxDecoration(
        color: isEmergency
            ? const Color(0xFFFFF2F2)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(19),
        border: Border.all(
          color: isEmergency
              ? const Color(0xFFFCA5A5)
              : const Color(0xFFE1E7EF),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration:
                BoxDecoration(
              color: isEmergency
                  ? const Color(0xFFFFE1E1)
                  : const Color(0xFFEEF3FF),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              Icons
                  .priority_high_rounded,
              color: isEmergency
                  ? const Color(
                      0xFFDC2626,
                    )
                  : primaryBlue,
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Need urgent help?",
                  style: TextStyle(
                    color: darkText,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  "Mark this request as an emergency.",
                  style: TextStyle(
                    color:
                        secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value: isEmergency,
            activeTrackColor:
                Color(0xFFEF4444),
            onChanged: (value) {
              setState(() {
                isEmergency = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _continue,
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              primaryBlue,
          foregroundColor:
              Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              17,
            ),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Text(
              "Continue",
              style:
                  TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            SizedBox(width: 9),

            Icon(
              Icons
                  .arrow_forward_rounded,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }
}