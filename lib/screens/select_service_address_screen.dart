import 'package:flutter/material.dart';

import '../core/services/address_repository.dart';
import '../models/address.dart';
import 'add_address_screen.dart';

class SelectServiceAddressScreen extends StatefulWidget {
  const SelectServiceAddressScreen({
    super.key,
    this.selectedAddress,
  });

  final Address? selectedAddress;

  @override
  State<SelectServiceAddressScreen> createState() =>
      _SelectServiceAddressScreenState();
}

class _SelectServiceAddressScreenState
    extends State<SelectServiceAddressScreen> {
  Address? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.selectedAddress;
  }

  // ---------------------------------------------------------------------------
  // SELECT ADDRESS
  // ---------------------------------------------------------------------------

  void _selectAddress(Address address) {
    setState(() {
      _selectedAddress = address;
    });
  }

  // ---------------------------------------------------------------------------
  // CONFIRM
  // ---------------------------------------------------------------------------

  void _confirmAddress() {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a service address',
          ),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      _selectedAddress,
    );
  }

  // ---------------------------------------------------------------------------
  // ADD NEW ADDRESS
  // ---------------------------------------------------------------------------

  Future<void> _addNewAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddAddressScreen(),
      ),
    );

    // The StreamBuilder below will automatically
    // receive the newly saved address.
  }

  // ---------------------------------------------------------------------------
  // ICON
  // ---------------------------------------------------------------------------

  IconData _addressIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;

      case 'office':
        return Icons.business_rounded;

      case 'parents':
        return Icons.family_restroom_rounded;

      default:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFEEF3FF),
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Service Address',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
          ),
        ),

        centerTitle: true,
      ),

      body: StreamBuilder<List<Address>>(
        stream: AddressRepository.addresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final addresses = snapshot.data ?? [];

          return Column(
            children: [
              // ----------------------------------------------------------------
              // CONTENT
              // ----------------------------------------------------------------

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    30,
                  ),
                  children: [
                    const Text(
                      'Where should the professional come?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Select a saved address or add a new one.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ----------------------------------------------------------
                    // CURRENT LOCATION
                    // ----------------------------------------------------------

                    _CurrentLocationButton(
                      primaryColor: primaryColor,
                      onTap: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Current location will be available here.',
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 26),

                    if (addresses.isNotEmpty) ...[
                      const Text(
                        'Saved Addresses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 14),

                      ...addresses.map(
                        (address) {
                          final isSelected =
                              _selectedAddress?.id ==
                                  address.id;

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 14,
                            ),
                            child: _AddressSelectionCard(
                              address: address,
                              icon: _addressIcon(
                                address.label,
                              ),
                              primaryColor:
                                  primaryColor,
                              isSelected:
                                  isSelected,
                              onTap: () {
                                _selectAddress(
                                  address,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      _NoAddresses(
                        primaryColor: primaryColor,
                        onAddAddress:
                            _addNewAddress,
                      ),
                    ],

                    const SizedBox(height: 12),

                    // ----------------------------------------------------------
                    // ADD NEW ADDRESS
                    // ----------------------------------------------------------

                    InkWell(
                      onTap: _addNewAddress,
                      borderRadius:
                          BorderRadius.circular(18),
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(18),
                          border: Border.all(
                            color: primaryColor
                                .withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration:
                                  BoxDecoration(
                                color: primaryColor
                                    .withValues(
                                  alpha: 0.08,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                color:
                                    primaryColor,
                                size: 27,
                              ),
                            ),

                            const SizedBox(
                              width: 14,
                            ),

                            const Expanded(
                              child: Text(
                                'Add New Address',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),

                            Icon(
                              Icons
                                  .arrow_forward_ios_rounded,
                              size: 17,
                              color:
                                  primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ----------------------------------------------------------------
              // CONFIRM BUTTON
              // ----------------------------------------------------------------

              SafeArea(
                top: false,
                child: Container(
                  padding:
                      const EdgeInsets.fromLTRB(
                    24,
                    14,
                    24,
                    18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF3FF),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(
                          alpha: 0.08,
                        ),
                        blurRadius: 10,
                        offset:
                            const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _confirmAddress,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryColor,
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
                      child: const Text(
                        'Confirm Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =============================================================================
// CURRENT LOCATION BUTTON
// =============================================================================

class _CurrentLocationButton extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback onTap;

  const _CurrentLocationButton({
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: primaryColor.withValues(
            alpha: 0.07,
          ),
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor.withValues(
              alpha: 0.18,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),

            const SizedBox(width: 15),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use Current Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Use your current location',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 17,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ADDRESS SELECTION CARD
// =============================================================================

class _AddressSelectionCard
    extends StatelessWidget {
  final Address address;
  final IconData icon;
  final Color primaryColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressSelectionCard({
    required this.address,
    required this.icon,
    required this.primaryColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(
                  alpha: 0.07,
                )
              : Colors.white,
          borderRadius:
              BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : const Color(0xFFE6E1E6),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.05,
                ),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: primaryColor.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 30,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          address.label,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),

                      if (address.isDefault) ...[
                        const SizedBox(width: 8),

                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFD7F1DA,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              color: Color(
                                0xFF4CAF50,
                              ),
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],

                  ),

                  const SizedBox(height: 7),

                  Text(
                    address.fullAddress,
                    maxLines: 3,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color:
                          Color(0xFF6F6970),
                    ),
                  ),

                  if (address.landmark
                      .trim()
                      .isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      'Landmark: ${address.landmark}',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color:
                            Color(0xFF8A858C),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            // --------------------------------------------------------------
            // RADIO / CHECK
            // --------------------------------------------------------------

            AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 180,
              ),
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? primaryColor
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : const Color(
                          0xFFB7B1B8,
                        ),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// NO ADDRESSES
// =============================================================================

class _NoAddresses extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback onAddAddress;

  const _NoAddresses({
    required this.primaryColor,
    required this.onAddAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 55,
            color: primaryColor,
          ),

          const SizedBox(height: 12),

          const Text(
            'No saved addresses yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Add an address to make booking services faster.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 18),

          OutlinedButton(
            onPressed: onAddAddress,
            child: const Text(
              'Add Address',
            ),
          ),
        ],
      ),
    );
  }
}