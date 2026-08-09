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
  // ============================================================

  static const Color primaryBlue =
      Color(0xFF1557FF);

  static const Color lightBlue =
      Color(0xFFEEF3FF);

  static const Color background =
      Color(0xFFF7F8FC);

  static const Color textPrimary =
      Color(0xFF101828);

  static const Color textSecondary =
      Color(0xFF667085);

  static const Color borderColor =
      Color(0xFFE1E5EC);

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
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 30,
            color: textPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Service Address",
          style: TextStyle(
            color: textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========================================================
      // SAVED ADDRESSES
      // ========================================================

      body: StreamBuilder<List<Address>>(
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
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration:
                          const BoxDecoration(
                        color: Color(0xFFFFE8E8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFE53935),
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Unable to load addresses",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

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

          final addresses =
              snapshot.data ?? <Address>[];

          // ----------------------------------------------------
          // AUTOMATICALLY SELECT DEFAULT ADDRESS
          // ----------------------------------------------------

          if (_selectedAddress == null &&
              addresses.isNotEmpty) {
            try {
              _selectedAddress =
                  addresses.firstWhere(
                (address) => address.isDefault,
              );
            } catch (_) {
              _selectedAddress =
                  addresses.first;
            }
          }

          // ----------------------------------------------------
          // MAIN CONTENT
          // ----------------------------------------------------

          return Column(
            children: [
              // =================================================
              // ADDRESS LIST
              // =================================================

              Expanded(
                child: addresses.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(
                          20,
                          22,
                          20,
                          20,
                        ),
                        itemCount:
                            addresses.length,
                        itemBuilder:
                            (context, index) {
                          final address =
                              addresses[index];

                          final selected =
                              _selectedAddress?.id ==
                                  address.id;

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 18,
                            ),
                            child:
                                _buildAddressCard(
                              address: address,
                              selected: selected,
                            ),
                          );
                        },
                      ),
              ),

              // =================================================
              // BOTTOM ACTIONS
              // =================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  24,
                ),
                child: Column(
                  children: [
                    // ------------------------------------------------
                    // ADD NEW ADDRESS
                    // ------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      height: 62,
                      child:
                          OutlinedButton.icon(
                        onPressed: _addAddress,

                        icon: const Icon(
                          Icons
                              .add_location_alt_outlined,
                          size: 27,
                        ),

                        label: const Text(
                          "Add New Address",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              primaryBlue,

                          side:
                              const BorderSide(
                            color:
                                Color(0xFFD5DDEE),
                            width: 1.5,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ------------------------------------------------
                    // CONTINUE
                    // ------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed:
                            _selectedAddress == null
                                ? null
                                : _continue,

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              primaryBlue,

                          foregroundColor:
                              Colors.white,

                          disabledBackgroundColor:
                              const Color(
                            0xFFD0D5DD,
                          ),

                          disabledForegroundColor:
                              Colors.white,

                          elevation: 0,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                        ),

                        child: const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),

                            SizedBox(width: 10),

                            Icon(
                              Icons
                                  .arrow_forward_rounded,
                              size: 27,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // ADDRESS CARD
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
        duration:
            const Duration(milliseconds: 180),

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: selected
              ? lightBlue
              : Colors.white,

          borderRadius:
              BorderRadius.circular(22),

          border: Border.all(
            color: selected
                ? primaryBlue
                : borderColor,
            width: selected ? 2 : 1.2,
          ),

          boxShadow: [
            if (!selected)
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
          ],
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // ADDRESS ICON
            // ==================================================

            Container(
              height: 64,
              width: 64,

              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFE0E9FF)
                    : lightBlue,

                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: Icon(
                _addressIcon(address.label),
                color: primaryBlue,
                size: 34,
              ),
            ),

            const SizedBox(width: 18),

            // ==================================================
            // ADDRESS DETAILS
            // ==================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ------------------------------------------------
                  // LABEL + DEFAULT
                  // ------------------------------------------------

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,

                    children: [
                      Flexible(
                        child: Text(
                          address.label,

                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                textPrimary,
                          ),
                        ),
                      ),

                      if (address.isDefault) ...[
                        const SizedBox(width: 10),

                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFE0F5E8,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),

                          child: const Text(
                            "Default",
                            style: TextStyle(
                              color:
                                  Color(0xFF4CAF50),
                              fontWeight:
                                  FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ------------------------------------------------
                  // FULL ADDRESS
                  // ------------------------------------------------

                  Text(
                    address.fullAddress,

                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // =================================================
                  // EDIT BUTTON
                  // =================================================

                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddAddressScreen(
                            address: address,
                          ),
                        ),
                      );
                    },

                    child: const Row(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: primaryBlue,
                          size: 20,
                        ),

                        SizedBox(width: 6),

                        Text(
                          "Edit",
                          style: TextStyle(
                            color: primaryBlue,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ==================================================
            // RADIO BUTTON
            // ==================================================

            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,

              color: selected
                  ? primaryBlue
                  : const Color(0xFF98A2B3),

              size: 30,
            ),
          ],
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
        return Icons.business_rounded;

      case "parents":
        return Icons.family_restroom_rounded;

      case "other":
        return Icons.location_on_rounded;

      case "home":
      default:
        return Icons.home_rounded;
    }
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              height: 100,
              width: 100,

              decoration:
                  const BoxDecoration(
                color: lightBlue,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.location_on_rounded,
                color: primaryBlue,
                size: 48,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "No saved addresses",
              textAlign: TextAlign.center,

              style: TextStyle(
                color: textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Add your home, office or another address to make booking services faster.",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: textSecondary,
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 26),

            SizedBox(
              height: 54,

              child: ElevatedButton.icon(
                onPressed: _addAddress,

                icon: const Icon(
                  Icons
                      .add_location_alt_outlined,
                ),

                label: const Text(
                  "Add Address",

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

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
                      18,
                    ),
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
  // ADD ADDRESS
  // ============================================================

  Future<void> _addAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AddAddressScreen(),
      ),
    );
  }

  // ============================================================
  // CONTINUE
  // ============================================================

  void _continue() {
    if (_selectedAddress == null) return;

    Navigator.pop(
      context,
      _selectedAddress,
    );
  }
}