import 'package:flutter/material.dart';

import '../core/services/address_repository.dart';
import '../models/address.dart';
import '../models/service_request.dart';
import 'add_address_screen.dart';
import 'date_time_screen.dart';

class AddressScreen extends StatefulWidget {
  final ServiceRequest request;

  const AddressScreen({
    super.key,
    required this.request,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color pageBackground = Color(0xFFF7F8FC);

  Address? _selectedAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        foregroundColor: darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Service Address",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Address>>(
          stream: AddressRepository.addresses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryBlue,
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

            if (addresses.isNotEmpty && _selectedAddress == null) {
              try {
                _selectedAddress = addresses.firstWhere(
                  (e) => e.isDefault,
                );
              } catch (_) {
                _selectedAddress = addresses.first;
              }
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Where should the professional come?",
                    style: TextStyle(
                      color: darkText,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    "Choose where you need the service.",
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 22),

                  Expanded(
                    child: addresses.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: addresses.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildAddressCard(
                                addresses[index],
                              );
                            },
                          ),
                  ),

                  _buildAddAddressButton(),

                  const SizedBox(height: 12),

                  _buildContinueButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    final bool selected = _selectedAddress == address;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          _selectedAddress = address;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF3FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? primaryBlue
                : const Color(0xFFE1E7EF),
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
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFE2EAFF)
                    : const Color(0xFFEEF3FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _addressIcon(address.label),
                color: primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          address.label,
                          style: const TextStyle(
                            color: darkText,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (address.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F7EE),
                            borderRadius: BorderRadius.circular(20),
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
                  ),
                  const SizedBox(height: 7),
                  Text(
                    address.fullAddress,
                    style: const TextStyle(
                      color: secondaryText,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected
                    ? primaryBlue
                    : const Color(0xFF64748B),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _addressIcon(String label) {
    switch (label.toLowerCase()) {
      case "home":
        return Icons.home_outlined;
      case "work":
      case "office":
        return Icons.business_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE1E7EF),
          ),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              color: primaryBlue,
              size: 44,
            ),
            SizedBox(height: 14),
            Text(
              "No saved addresses",
              style: TextStyle(
                color: darkText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Add an address where the professional should visit.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryText,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAddressButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddAddressScreen(),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryBlue,
          side: const BorderSide(
            color: Color(0xFFD7E0F2),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
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
      ),
    );
  }

  Widget _buildContinueButton() {
    final enabled = _selectedAddress != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: !enabled
            ? null
            : () {
                widget.request.address =
                    _selectedAddress!.fullAddress;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DateTimeScreen(
                      request: widget.request,
                    ),
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          disabledBackgroundColor: const Color(0xFFE8EDF5),
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0xFF64748B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
