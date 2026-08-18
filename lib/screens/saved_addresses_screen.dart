import 'package:flutter/material.dart';

import '../core/services/address_repository.dart';
import '../models/address.dart';
import 'add_address_screen.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() =>
      _SavedAddressesScreenState();
}

class _SavedAddressesScreenState
    extends State<SavedAddressesScreen> {
  // ============================================================
  // DESIGN SYSTEM
  // Matches AppTheme / address_screen.dart exactly so this screen
  // and the one reached from the booking flow render identically.
  // ============================================================

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color lightBlue = Color(0xFFEEF3FF);
  static const Color background = Color(0xFFF7F8FC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE1E7EF);

  // ============================================================
  // STATE
  // ============================================================

  Address? _selectedAddress;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ========================================================
      // APP BAR — same title size/weight as address_screen.dart
      // ========================================================

      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Saved Addresses",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========================================================
      // SAVED ADDRESSES
      // ========================================================

      body: SafeArea(
        child: StreamBuilder<List<Address>>(
          stream: AddressRepository.addresses(),
          builder: (context, snapshot) {
            // ----------------------------------------------------
            // LOADING
            // ----------------------------------------------------

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryBlue,
                ),
              );
            }

            // ----------------------------------------------------
            // ERROR
            // ----------------------------------------------------

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFE8E8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFD92D20),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Unable to load addresses",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final addresses = snapshot.data ?? <Address>[];

            // ----------------------------------------------------
            // AUTOMATICALLY SELECT DEFAULT ADDRESS
            // ----------------------------------------------------

            if (_selectedAddress == null &&
                addresses.isNotEmpty) {
              try {
                _selectedAddress = addresses.firstWhere(
                  (address) => address.isDefault,
                );
              } catch (_) {
                _selectedAddress = addresses.first;
              }
            }

            // ----------------------------------------------------
            // MAIN CONTENT
            // ----------------------------------------------------

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // ADDRESS LIST
                  // =================================================

                  Expanded(
                    child: addresses.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            physics:
                                const BouncingScrollPhysics(),
                            padding:
                                const EdgeInsets.only(bottom: 16),
                            itemCount: addresses.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final address = addresses[index];
                              final selected =
                                  _selectedAddress?.id ==
                                      address.id;

                              return _buildAddressCard(
                                address: address,
                                selected: selected,
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 12),

                  // =================================================
                  // ADD NEW ADDRESS
                  // =================================================

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _addAddress,
                      icon: const Icon(
                        Icons.add_location_alt_outlined,
                        size: 21,
                      ),
                      label: const Text(
                        "Add New Address",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryBlue,
                        side: const BorderSide(
                          color: Color(0xFFD7E0F2),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(17),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =================================================
                  // CONTINUE
                  // =================================================

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _selectedAddress == null
                          ? null
                          : _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        disabledBackgroundColor:
                            const Color(0xFFE8EDF5),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: textSecondary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(17),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 9),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 21,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // ADDRESS ICON
  // ============================================================

  IconData _addressIcon(String label) {
    switch (label.toLowerCase()) {
      case "office":
        return Icons.business_outlined;
      case "parents":
        return Icons.family_restroom_outlined;
      case "other":
        return Icons.location_on_outlined;
      case "home":
      default:
        return Icons.home_outlined;
    }
  }

  // ============================================================
  // ADDRESS CARD — sizes matched to address_screen.dart's card
  // ============================================================

  Widget _buildAddressCard({
    required Address address,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddress = address;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: selected ? lightBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? primaryBlue : borderColor,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: selected ? .04 : .025,
              ),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // ADDRESS ICON
            // ==================================================

            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFE2EAFF)
                    : lightBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _addressIcon(address.label),
                color: primaryBlue,
                size: 24,
              ),
            ),

            const SizedBox(width: 13),

            // ==================================================
            // ADDRESS DETAILS
            // ==================================================

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          address.label,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 9),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F7EE),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Default",
                            style: TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 7),

                  Text(
                    address.fullAddress,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // =================================================
                  // EDIT
                  // =================================================

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddAddressScreen(
                                address: address,
                              ),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              color: primaryBlue,
                              size: 16,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "Edit",
                              style: TextStyle(
                                color: primaryBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 18),

                      GestureDetector(
                        onTap: () => _confirmDelete(address),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Color(0xFFD92D20),
                              size: 16,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "Delete",
                              style: TextStyle(
                                color: Color(0xFFD92D20),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ==================================================
            // RADIO BUTTON
            // ==================================================

            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? primaryBlue : textSecondary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE — same card style/sizes as address_screen.dart's
  // empty state, plus a compact button to add the first address.
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: primaryBlue,
              size: 44,
            ),
            const SizedBox(height: 14),
            const Text(
              "No saved addresses",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Add your home, office or another address to make booking services faster.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _addAddress,
                icon: const Icon(
                  Icons.add_location_alt_outlined,
                  size: 21,
                ),
                label: const Text(
                  "Add Address",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DELETE ADDRESS
  // ============================================================

  Future<void> _confirmDelete(Address address) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete address?"),
        content: Text(
          "Remove \"${address.label}\" (${address.fullAddress})? "
          "This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Color(0xFFD92D20)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AddressRepository.deleteAddress(address.id);

    if (_selectedAddress?.id == address.id) {
      setState(() {
        _selectedAddress = null;
      });
    }
  }

  // ============================================================
  // ADD ADDRESS
  // ============================================================

  Future<void> _addAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddAddressScreen(),
      ),
    );
  }

  // ============================================================
  // CONTINUE
  // ============================================================

  void _continue() {
    if (_selectedAddress == null) return;

    Navigator.pop(context, _selectedAddress);
  }
}