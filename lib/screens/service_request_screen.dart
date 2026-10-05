import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

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

  // ============================================================
  // INITIAL EMERGENCY STATE -- added 2026-09-04
  // ============================================================
  //
  // Lets a caller land here with the emergency switch already on --
  // used by EmergencyAssistanceScreen, so picking a subcategory from
  // the curated emergency list doesn't also require manually
  // flipping the switch below. Defaults to false so every existing
  // call site (CategoryGrid, QuickServicesSection, FrequentlyUsedSection,
  // TrendingServices, the "Ask Habio" free-text flow) is unaffected.
  //

  final bool initialIsEmergency;

  // ============================================================
  // MATCH GROUP -- added 2026-10-02
  // ============================================================
  //
  // The chosen subcategory's SubCategory.matchGroup (see
  // lib/models/subcategory.dart for the full explanation),
  // resolved by the caller from the same taxonomy entry subCategoryId
  // came from. Forwarded onto the request so the Cloud Function's
  // Appliances/Automobile fallback-matching tier can narrow to the
  // same trade family instead of the whole category.
  //
  // When this is exactly 'both' (a vehicle-agnostic Automobile item
  // like Battery Service or Tyre & Puncture), the subcategory id
  // alone can't tell a car job from a bike job, so this screen asks
  // the customer directly below. Null for every non-Automobile
  // category and for the free-text "Ask Habio" flow, where it stays
  // unset.
  //

  final String? matchGroup;

  const ServiceRequestScreen({
    super.key,
    required this.categoryName,
    required this.subCategoryName,
    required this.subCategoryId,
    this.categoryId = '',
    this.initialIsEmergency = false,
    this.matchGroup,
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

  late bool isEmergency;

  List<File> selectedPhotos = [];
  File? selectedVideo;

  // ============================================================
  // VOICE NOTE -- added 2026-10-02
  // ============================================================
  //
  // Optional recording describing the problem, sitting alongside
  // the existing photo/video attachments. Capped at 60 seconds
  // (_maxVoiceNoteSeconds) -- recording stops itself automatically
  // at the cap rather than just disabling the button, so the
  // customer isn't left wondering why nothing happens.
  //
  // Uploaded by ServiceRequestMediaService once a real requestId
  // exists -- see RequestService.createRequest.
  //

  static const int _maxVoiceNoteSeconds = 60;

  final AudioRecorder _voiceNoteRecorder = AudioRecorder();
  final AudioPlayer _voiceNotePreviewPlayer = AudioPlayer();

  File? selectedVoiceNote;
  bool _isRecordingVoiceNote = false;
  bool _isPlayingVoiceNotePreview = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  // ============================================================
  // MATERIAL SOURCING -- added 2026-09-04
  // ============================================================
  //
  // "Will the customer provide the material?" -- mandatory choice
  // before Continue. null means not yet chosen (deliberately, so
  // it can be validated as missing rather than defaulting silently
  // to either answer). When the customer says no, a material grade
  // is mandatory too; the brand field is always optional.
  //

  static const List<String> _materialGrades = [
    'Low',
    'Standard',
    'Luxury',
  ];

  bool? customerProvidesMaterial;
  String? materialGrade;

  final TextEditingController materialBrandController =
      TextEditingController();

  // ============================================================
  // VEHICLE TYPE -- added 2026-10-02
  // ============================================================
  //
  // Only asked when widget.matchGroup == 'both' -- see the field
  // doc comment on ServiceRequestScreen above. Mandatory in that
  // case before Continue, same validation pattern as
  // customerProvidesMaterial above.
  //

  String? vehicleType;

  @override
  void initState() {
    super.initState();
    isEmergency = widget.initialIsEmergency;

    _voiceNotePreviewPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlayingVoiceNotePreview = false;
      });
    });
  }

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

  // ============================================================
  // VOICE NOTE RECORDING -- added 2026-10-02
  // ============================================================

  Future<void> _startVoiceNoteRecording() async {
    final bool hasPermission = await _voiceNoteRecorder.hasPermission();

    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Microphone permission is needed to record a voice note.",
          ),
        ),
      );
      return;
    }

    final Directory tempDir = await getTemporaryDirectory();
    final String path =
        '${tempDir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _voiceNoteRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    setState(() {
      _isRecordingVoiceNote = true;
      _recordingSeconds = 0;
    });

    _recordingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          _recordingSeconds++;
        });

        if (_recordingSeconds >= _maxVoiceNoteSeconds) {
          _stopVoiceNoteRecording();
        }
      },
    );
  }

  Future<void> _stopVoiceNoteRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    final String? path = await _voiceNoteRecorder.stop();

    if (!mounted) return;

    setState(() {
      _isRecordingVoiceNote = false;
      if (path != null) {
        selectedVoiceNote = File(path);
      }
    });
  }

  Future<void> _deleteVoiceNote() async {
    if (_isPlayingVoiceNotePreview) {
      await _voiceNotePreviewPlayer.stop();
    }

    setState(() {
      selectedVoiceNote = null;
      _isPlayingVoiceNotePreview = false;
    });
  }

  Future<void> _toggleVoiceNotePreview() async {
    if (selectedVoiceNote == null) return;

    if (_isPlayingVoiceNotePreview) {
      await _voiceNotePreviewPlayer.pause();
      setState(() {
        _isPlayingVoiceNotePreview = false;
      });
    } else {
      await _voiceNotePreviewPlayer.play(
        DeviceFileSource(selectedVoiceNote!.path),
      );
      setState(() {
        _isPlayingVoiceNotePreview = true;
      });
    }
  }

  String _formatSeconds(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    issueController.dispose();
    materialBrandController.dispose();
    _recordingTimer?.cancel();
    _voiceNoteRecorder.dispose();
    _voiceNotePreviewPlayer.dispose();
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
    // MATERIAL SOURCING -- mandatory choice, grade required if the
    // professional is sourcing it.
    // ==========================================================

    if (customerProvidesMaterial == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please let us know who will provide the material.",
          ),
        ),
      );

      return;
    }

    if (customerProvidesMaterial == false && materialGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a material grade.",
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // VEHICLE TYPE -- mandatory only when the subcategory is
    // vehicle-agnostic (matchGroup == 'both'); the subcategory id
    // itself already says car vs bike otherwise.
    // ==========================================================

    if (widget.matchGroup == 'both' && vehicleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please let us know if this is for a car or a bike.",
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
            voiceNote:
                selectedVoiceNote,

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

            customerProvidesMaterial:
                customerProvidesMaterial,

            materialGrade:
                customerProvidesMaterial == false
                    ? materialGrade
                    : null,

            materialBrandPreference:
                customerProvidesMaterial == false &&
                        materialBrandController.text.trim().isNotEmpty
                    ? materialBrandController.text.trim()
                    : null,

            matchGroup:
                widget.matchGroup,

            vehicleType:
                widget.matchGroup == 'both' ? vehicleType : null,
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

              _buildMaterialSection(),

              if (widget.matchGroup == 'both') ...[
                const SizedBox(height: 26),
                _buildVehicleTypeSection(),
              ],

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

        // ------------------------------------------------------
        // VOICE NOTE -- added 2026-10-02
        // ------------------------------------------------------

        const SizedBox(height: 12),

        _buildVoiceNoteControl(),
      ],
    );
  }

  Widget _buildVoiceNoteControl() {
    // --------------------------------------------------------
    // RECORDED -- playback/delete card
    // --------------------------------------------------------

    if (selectedVoiceNote != null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE1E7EF),
          ),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: _toggleVoiceNotePreview,
              borderRadius: BorderRadius.circular(19),
              child: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF3FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  _isPlayingVoiceNotePreview
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: primaryBlue,
                  size: 21,
                ),
              ),
            ),

            const SizedBox(width: 10),

            const Expanded(
              child: Text(
                "Voice note recorded",
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            IconButton(
              onPressed: _deleteVoiceNote,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      );
    }

    // --------------------------------------------------------
    // RECORDING -- live elapsed-time indicator + stop button
    // --------------------------------------------------------

    if (_isRecordingVoiceNote) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFFECACA),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                "Recording... ${_formatSeconds(_recordingSeconds)} "
                "/ ${_formatSeconds(_maxVoiceNoteSeconds)}",
                style: const TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            TextButton(
              onPressed: _stopVoiceNoteRecording,
              child: const Text("Stop"),
            ),
          ],
        ),
      );
    }

    // --------------------------------------------------------
    // NOTHING RECORDED YET -- prompt to record
    // --------------------------------------------------------

    return OutlinedButton.icon(
      onPressed: _startVoiceNoteRecording,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: primaryBlue,
        side: const BorderSide(
          color: Color(0xFFDCE3EC),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        minimumSize: const Size.fromHeight(0),
      ),
      icon: const Icon(Icons.mic_none_rounded, size: 21),
      label: const Text(
        "Record a Voice Note for the Partner (optional)",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
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

  // ============================================================
  // MATERIAL SOURCING -- added 2026-09-04
  // ============================================================
  //
  // "Who's providing the material?" -- I'll provide it / Professional
  // sources it. Choosing "Professional sources it" reveals a
  // mandatory grade selector plus an optional brand-preference field,
  // so the professional's quote (and materials cost specifically --
  // see ProfessionalQuoteScreen on the professional app) reflects
  // what the customer actually wants.
  // ============================================================

  Widget _buildMaterialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Who's providing the material?",
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          "This helps the professional quote you accurately.",
          style: TextStyle(
            color: secondaryText,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _materialOptionCard(
                icon: Icons.inventory_2_outlined,
                label: "I'll provide it",
                selected: customerProvidesMaterial == true,
                onTap: () {
                  setState(() {
                    customerProvidesMaterial = true;
                    materialGrade = null;
                    materialBrandController.clear();
                  });
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _materialOptionCard(
                icon: Icons.storefront_outlined,
                label: "Professional sources it",
                selected: customerProvidesMaterial == false,
                onTap: () {
                  setState(() {
                    customerProvidesMaterial = false;
                  });
                },
              ),
            ),
          ],
        ),

        if (customerProvidesMaterial == false) ...[
          const SizedBox(height: 18),

          const Text(
            "Material grade",
            style: TextStyle(
              color: darkText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            "Required — helps the professional price the right quality.",
            style: TextStyle(
              color: secondaryText,
              fontSize: 12.5,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              for (int i = 0; i < _materialGrades.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _gradeChip(_materialGrades[i]),
                ),
              ],
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            "Preferred brand (optional)",
            style: TextStyle(
              color: darkText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFDCE3EC),
              ),
            ),
            child: TextField(
              controller: materialBrandController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(
                color: darkText,
                fontSize: 15,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                hintText: "e.g. Havells, Asian Paints, Jaguar...",
                hintStyle: TextStyle(
                  color: Color(0xFF94A1B5),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // VEHICLE TYPE -- added 2026-10-02
  // ============================================================
  //
  // Shown only when widget.matchGroup == 'both' -- see the field
  // doc comment on ServiceRequestScreen. Reuses _materialOptionCard's
  // generic icon/label/selected card styling above.
  // ============================================================

  Widget _buildVehicleTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Is this for a car or a bike?",
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          "This service covers both — let us know which one so we can send the right professional.",
          style: TextStyle(
            color: secondaryText,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _materialOptionCard(
                icon: Icons.directions_car,
                label: "Car",
                selected: vehicleType == 'car',
                onTap: () {
                  setState(() {
                    vehicleType = 'car';
                  });
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _materialOptionCard(
                icon: Icons.two_wheeler,
                label: "Bike",
                selected: vehicleType == 'bike',
                onTap: () {
                  setState(() {
                    vehicleType = 'bike';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _materialOptionCard({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF3FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? primaryBlue : const Color(0xFFE1E7EF),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? primaryBlue : secondaryText,
              size: 26,
            ),

            const SizedBox(height: 8),

            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? primaryBlue : darkText,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradeChip(String grade) {
    final bool selected = materialGrade == grade;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          materialGrade = grade;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? primaryBlue : const Color(0xFFDCE3EC),
          ),
        ),
        child: Text(
          grade,
          style: TextStyle(
            color: selected ? Colors.white : darkText,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
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