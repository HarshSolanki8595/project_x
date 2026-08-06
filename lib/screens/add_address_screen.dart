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

class _AddAddressScreenState
    extends State<AddAddressScreen> {
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
          content: Text(
            "Please fill all required fields.",
          ),
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
  }

  Widget field(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.address == null
              ? "Add Address"
              : "Edit Address",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _label,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Label",
              ),
              items: const [
                DropdownMenuItem(
                  value: "Home",
                  child: Text("Home"),
                ),
                DropdownMenuItem(
                  value: "Office",
                  child: Text("Office"),
                ),
                DropdownMenuItem(
                  value: "Parents",
                  child: Text("Parents"),
                ),
                DropdownMenuItem(
                  value: "Other",
                  child: Text("Other"),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  _label = v!;
                });
              },
            ),

           const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  height: 55,
  child: OutlinedButton.icon(
    icon: const Icon(Icons.map),
    label: const Text(
      "Pick Address on Map",
      style: TextStyle(
        fontSize: 16,
      ),
    ),
    onPressed: () async {

      final result =
          await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MapScreen(),
        ),
      );

      if (result != null) {

        _houseController.text =
    result["house"] ?? "";

_streetController.text =
    result["street"] ?? "";

_areaController.text =
    result["area"] ?? "";

_cityController.text =
    result["city"] ?? "";

_stateController.text =
    result["state"] ?? "";

_pincodeController.text =
    result["pincode"] ?? "";

      }

    },
  ),
),

const SizedBox(height: 20),

field("Flat / House No.", _houseController),
            field("Building / Society", _buildingController),
            field("Street", _streetController),
            field("Area", _areaController),
            field("City", _cityController),
            field("State", _stateController),
            field("Pincode", _pincodeController),
            field("Landmark (Optional)", _landmarkController),

            SwitchListTile(
              value: _isDefault,
              title: const Text("Set as Default"),
              onChanged: (v) {
                setState(() {
                  _isDefault = v;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(
                  widget.address == null
                      ? "Save Address"
                      : "Update Address",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}