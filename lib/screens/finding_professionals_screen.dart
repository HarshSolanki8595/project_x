import 'dart:async';
import '../models/service_request.dart';
import 'package:flutter/material.dart';

import 'professionals_screen.dart';

class FindingProfessionalsScreen extends StatefulWidget {

  final ServiceRequest request;

  const FindingProfessionalsScreen({
    super.key,
    required this.request,
  });

  @override
  State<FindingProfessionalsScreen> createState() =>
      _FindingProfessionalsScreenState();
}

class _FindingProfessionalsScreenState
    extends State<FindingProfessionalsScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 2,
      ),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    Timer(
      const Duration(seconds: 3),
      () {

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
           builder: (_) => ProfessionalsScreen(
  request: widget.request,
),
          ),
        );

      },
    );
  }

  @override
  void dispose() {

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xffF7F8FC),

      body: SafeArea(

        child: Center(

          child: Padding(
            padding:
                const EdgeInsets.all(30),

            child: Column(

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                ScaleTransition(

                  scale: _animation,

                  child: Container(

                    height: 120,

                    width: 120,

                    decoration: BoxDecoration(

                      color: Colors.deepPurple,

                      borderRadius:
                          BorderRadius.circular(
                        60,
                      ),

                    ),

                    child: const Icon(

                      Icons.search,

                      color: Colors.white,

                      size: 55,

                    ),

                  ),

                ),

                const SizedBox(
                  height: 40,
                ),const Text(
  "Finding Professionals",
  style: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 12,
),

const Text(
  "Searching nearby verified professionals...\nThis usually takes only a few seconds.",
  textAlign: TextAlign.center,
  style: TextStyle(
    color: Colors.grey,
    fontSize: 16,
    height: 1.5,
  ),
),

const SizedBox(
  height: 40,
),

const SizedBox(
  width: 220,
  child: LinearProgressIndicator(
    minHeight: 6,
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  ),
),

const SizedBox(
  height: 40,
),

Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
      ),
    ],
  ),
  child: const Column(
    children: [

      ListTile(
        dense: true,
        leading: Icon(
          Icons.verified,
          color: Colors.green,
        ),
        title: Text(
          "Verified Professionals Only",
        ),
      ),

      ListTile(
        dense: true,
        leading: Icon(
          Icons.location_on,
          color: Colors.deepPurple,
        ),
        title: Text(
          "Searching within your selected location",
        ),
      ),

      ListTile(
        dense: true,
        leading: Icon(
          Icons.price_check,
          color: Colors.orange,
        ),
        title: Text(
          "Waiting for quotations",
        ),
      ),

    ],
  ),
),

              ],
            ),
          ),
        ),
      ),
    );
  }
}