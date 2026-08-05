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
  State<AddressScreen> createState() =>
      _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  Address? _selectedAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        title: const Text("Service Address"),
      ),
      body: StreamBuilder<List<Address>>(
        stream: AddressRepository.addresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final addresses = snapshot.data ?? [];

          if (addresses.isNotEmpty &&
              _selectedAddress == null) {
            try {
              _selectedAddress = addresses.firstWhere(
                (e) => e.isDefault,
              );
            } catch (_) {
              _selectedAddress = addresses.first;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Where do you need the service?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Select one of your saved addresses.",
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: addresses.isEmpty
                      ? const Center(
                          child: Text(
                            "No saved addresses.",
                          ),
                        )
                      : ListView.builder(
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            final address =
                                addresses[index];

                            return Card(
                              margin:
                                  const EdgeInsets.only(
                                      bottom: 16),
                              child: RadioListTile<Address>(
                                value: address,
                                groupValue:
                                    _selectedAddress,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAddress =
                                        value;
                                  });
                                },
                                title: Row(
                                  children: [
                                    Text(
                                      address.label,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                    if (address
                                        .isDefault) ...[
                                      const SizedBox(
                                          width: 8),
                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration:
                                            BoxDecoration(
                                          color: Colors
                                              .green
                                              .shade100,
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      20),
                                        ),
                                        child:
                                            const Text(
                                          "Default",
                                          style:
                                              TextStyle(
                                            color: Colors
                                                .green,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                                subtitle: Text(
                                  address.fullAddress,
                                ),
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.add_location_alt,
                    ),
                    label: const Text(
                      "Add New Address",
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddAddressScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                        _selectedAddress == null
                            ? null
                            : () {
                                widget.request.address =
                                    _selectedAddress!
                                        .fullAddress;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DateTimeScreen(
                                      request:
                                          widget.request,
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}