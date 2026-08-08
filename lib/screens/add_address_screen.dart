import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/services/address_repository.dart';
import '../models/address.dart';
import 'map_screen.dart';

class AddAddressScreen extends StatefulWidget {
  final Address? address;

  const AddAddressScreen({
    super.key,
    this.address,
  });

  @override
  State<AddAddressScreen> createState() =>
      _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  static const Color primaryBlue = Color(0xFF0D47FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color pageBackground = Color(0xFFF7F9FC);

  final _houseController = TextEditingController();
  final _buildingController = TextEditingController();
  final _streetController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _landmarkController = TextEditingController();

  String _label = "Home";
  bool _isDefault = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    if (widget.address != null) {
      final a = widget.address!;

      _label = a.label;
      _isDefault = a.isDefault;

      _houseController.text = a.houseNo;
      _buildingController.text = a.building;
      _streetController.text = a.street;
      _areaController.text = a.area;
      _cityController.text = a.city;
      _stateController.text = a.state;
      _pincodeController.text = a.pincode;
      _landmarkController.text = a.landmark;
    }
  }

  @override
  void dispose() {
    _houseController.dispose();
    _buildingController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_houseController.text.trim().isEmpty ||
        _streetController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields."),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final id = widget.address?.id ??
        FirebaseFirestore.instance
            .collection("temp")
            .doc()
            .id;

    final address = Address(
      id: id,
      label: _label,
      houseNo: _houseController.text.trim(),
      building: _buildingController.text.trim(),
      street: _streetController.text.trim(),
      area: _areaController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      landmark: _landmarkController.text.trim(),
      isDefault: _isDefault,
      createdAt:
          widget.address?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.address == null) {
        await AddressRepository.addAddress(address);
      } else {
        await AddressRepository.updateAddress(address);
      }

      if (_isDefault) {
        await AddressRepository.setDefaultAddress(id);
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save address: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(
          color: darkText,
          fontSize: 15.5,
        ),
        decoration: InputDecoration(
          labelText: required ? "$label *" : label,
          hintText: hint,
          floatingLabelStyle: const TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.w600,
          ),
          labelStyle: const TextStyle(
            color: secondaryText,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xFFE1E7EF),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xFFE1E7EF),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: primaryBlue,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAddressOnMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapScreen(),
      ),
    );

    if (result != null) {
      _houseController.text = result["house"] ?? "";
      _streetController.text = result["street"] ?? "";
      _areaController.text = result["area"] ?? "";
      _cityController.text = result["city"] ?? "";
      _stateController.text = result["state"] ?? "";
      _pincodeController.text = result["pincode"] ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        foregroundColor: darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isEditing ? "Edit Address" : "Add Address",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isEditing),
              const SizedBox(height: 24),
              _buildAddressLabel(),
              const SizedBox(height: 20),
              _buildMapButton(),
              const SizedBox(height: 25),
              _buildSectionTitle(
                "Address details",
                "Tell us where the professional needs to visit.",
              ),
              const SizedBox(height: 16),
              _field(
                label: "Flat / House No.",
                controller: _houseController,
                hint: "e.g. 502",
                required: true,
              ),
              _field(
                label: "Building / Society",
                controller: _buildingController,
                hint: "e.g. Rathnakar Apartment",
              ),
              _field(
                label: "Street",
                controller: _streetController,
                hint: "Enter street name",
                required: true,
              ),
              _field(
                label: "Area / Locality",
                controller: _areaController,
                hint: "Enter area or locality",
              ),
              _field(
                label: "City",
                controller: _cityController,
                hint: "e.g. Mumbai",
                required: true,
              ),
              _field(
                label: "State",
                controller: _stateController,
                hint: "e.g. Maharashtra",
              ),
              _field(
                label: "Pincode",
                controller: _pincodeController,
                hint: "6-digit pincode",
                keyboardType: TextInputType.number,
              ),
              _field(
                label: "Landmark",
                controller: _landmarkController,
                hint: "Optional",
              ),
              const SizedBox(height: 2),
              _buildDefaultCard(),
              const SizedBox(height: 25),
              _buildSaveButton(isEditing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE1E7EF),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? "Update your address"
                      : "Where should we send the professional?",
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Your address helps us connect you with professionals who can visit you.",
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressLabel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Save this address as",
          style: TextStyle(
            color: darkText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _labelChip("Home", Icons.home_outlined),
              const SizedBox(width: 9),
              _labelChip("Office", Icons.business_outlined),
              const SizedBox(width: 9),
              _labelChip("Parents", Icons.family_restroom_outlined),
              const SizedBox(width: 9),
              _labelChip("Other", Icons.location_on_outlined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _labelChip(String value, IconData icon) {
    final selected = _label == value;

    return ChoiceChip(
      selected: selected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: selected ? primaryBlue : secondaryText,
          ),
          const SizedBox(width: 6),
          Text(value),
        ],
      ),
      labelStyle: TextStyle(
        color: selected ? primaryBlue : secondaryText,
        fontWeight: FontWeight.w600,
      ),
      selectedColor: const Color(0xFFEAF0FF),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected
            ? const Color(0xFFB8C9FF)
            : const Color(0xFFE1E7EF),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (_) {
        setState(() {
          _label = value;
        });
      },
    );
  }

  Widget _buildMapButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: _pickAddressOnMap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD7E2FF),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.map_outlined,
                color: primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pick address on map",
                    style: TextStyle(
                      color: darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    "Select a location and fill the address automatically.",
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: primaryBlue,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: secondaryText,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 12, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE1E7EF),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Set as default address",
                  style: TextStyle(
                    color: darkText,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Use this address automatically next time.",
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isDefault,
            activeTrackColor: primaryBlue,
            onChanged: (value) {
              setState(() {
                _isDefault = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          disabledBackgroundColor: const Color(0xFFD9E2F7),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: _saving
            ? const SizedBox(
                height: 23,
                width: 23,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isEditing
                        ? "Update Address"
                        : "Save Address",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 21,
                  ),
                ],
              ),
      ),
    );
  }
}
