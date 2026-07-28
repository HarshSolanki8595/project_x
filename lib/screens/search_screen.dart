import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Search Services",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search for any service...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.mic),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Recent Searches",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  Chip(label: Text("AC Service")),
                  Chip(label: Text("Electrician")),
                  Chip(label: Text("Plumber")),
                ],
              ),

              const SizedBox(height: 35),

              const Text(
                "Popular Services",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: ListView(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.electrical_services),
                      title: Text("Electrician"),
                    ),
                    ListTile(
                      leading: Icon(Icons.plumbing),
                      title: Text("Plumber"),
                    ),
                    ListTile(
                      leading: Icon(Icons.ac_unit),
                      title: Text("AC Repair"),
                    ),
                    ListTile(
                      leading: Icon(Icons.cleaning_services),
                      title: Text("Home Cleaning"),
                    ),
                    ListTile(
                      leading: Icon(Icons.handyman),
                      title: Text("Carpenter"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}