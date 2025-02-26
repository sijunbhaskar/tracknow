import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ETAPage extends StatefulWidget {
  const ETAPage({super.key});

  @override
  _ETAPageState createState() => _ETAPageState();
}

class _ETAPageState extends State<ETAPage> {
  String? _selectedBus;
  String? _selectedStop;
  String _etaResult = "";
  bool _isLoading = false;
  List<Map<String, String>> _buses = [];
  List<Map<String, String>> _stops = [];

  @override
  void initState() {
    super.initState();
    _fetchBuses();
    _fetchStops();
  }

  /// ✅ Fetch buses in a specific route from backend
  Future<void> _fetchBuses() async {
    try {
      final response = await http.get(
        Uri.parse("https://bustrackingapp-oezp.onrender.com/buses"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _buses = List<Map<String, String>>.from(data.map((bus) =>
              {"id": bus["busId"].toString(), "name": "Bus ${bus["busId"]}"}));
        });
      } else {
        print("❌ Failed to fetch buses (Error ${response.statusCode})");
      }
    } catch (e) {
      print("🚨 Error fetching buses: $e");
    }
  }

  // ✅ Fetch bus stops from backend
  Future<void> _fetchStops() async {
    try {
      final response = await http.get(
        Uri.parse("https://bustrackingapp-oezp.onrender.com/stops"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _stops = List<Map<String, String>>.from(data.map((stop) => {
                "id": stop["stopId"].toString(),
                "name": "Stop ${stop["stopName"]}"
              }));
        });
      } else {
        print("❌ Failed to fetch stops");
      }
    } catch (e) {
      print("⚠ Error fetching stops: $e");
    }
  }

  /// ✅ Fetch ETA from backend
  Future<void> _fetchETA() async {
    if (_selectedBus == null || _selectedStop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a bus and stop")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _etaResult = "";
    });

    try {
      final response = await http.get(
        Uri.parse(
          "https://bustrackingapp-oezp.onrender.com/buses/eta?busId=$_selectedBus&stopId=$_selectedStop",
        ),
      );
      print("🟢 API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _etaResult =
              "ETA: ${data['eta']} minutes (Distance: ${data['distance']} km)";
        });
      } else {
        setState(() {
          _etaResult = "⚠️ Failed to fetch ETA";
        });
      }
    } catch (e) {
      setState(() {
        _etaResult = "❌ Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estimated Time of Arrival (ETA)"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Bus:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              value: _selectedBus,
              hint: const Text("Choose a bus"),
              items: _buses.map((bus) {
                return DropdownMenuItem<String>(
                  value: bus["id"],
                  child: Text(bus["name"]!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBus = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text("Select Stop:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              value: _selectedStop,
              hint: const Text("Choose a stop"),
              items: _stops.map((stop) {
                return DropdownMenuItem<String>(
                  value: stop["id"],
                  child: Text(stop["name"]!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStop = value;
                });
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _fetchETA,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Get ETA", style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                _etaResult,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
