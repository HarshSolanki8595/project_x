import 'package:flutter/material.dart';

import '../core/services/address_repository.dart';
import '../models/address.dart';
import 'add_address_screen.dart';

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Addresses"),
        centerTitle: true,
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

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No Saved Addresses",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Save your Home, Office or Parents\naddress to book services faster.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];

              return Card(
                margin:
                    const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Colors.deepPurple.shade50,
                    child: Icon(
                      address.label == "Home"
                          ? Icons.home
                          : address.label ==
                                  "Office"
                              ? Icons.business
                              : address.label ==
                                      "Parents"
                                  ? Icons.family_restroom
                                  : Icons.location_on,
                      color: Colors.deepPurple,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Colors.green.shade100,
                            borderRadius:
                                BorderRadius.circular(
                                    20),
                          ),
                          child: const Text(
                            "Default",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                  subtitle: Padding(
                    padding:
                        const EdgeInsets.only(top: 6),
                    child: Text(
                      address.fullAddress,
                    ),
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (value) async {
                      if (value == "edit") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddAddressScreen(
                              address: address,
                            ),
                          ),
                        );
                      }

                      if (value == "default") {
                        await AddressRepository
                            .setDefaultAddress(
                                address.id);
                      }

                      if (value == "delete") {
                        final delete =
                            await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text(
                                "Delete Address"),
                            content: const Text(
                              "Are you sure you want to delete this address?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(
                                        context,
                                        false),
                                child:
                                    const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(
                                        context,
                                        true),
                                child:
                                    const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (delete == true) {
                          await AddressRepository
                              .deleteAddress(
                                  address.id);
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: "edit",
                        child: Text("Edit"),
                      ),
                      PopupMenuItem(
                        value: "default",
                        child: Text(
                            "Set as Default"),
                      ),
                      PopupMenuItem(
                        value: "delete",
                        child: Text("Delete"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
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
    );
  }
}