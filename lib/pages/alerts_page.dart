import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // ✅ For Timestamp Formatting
import 'package:socket_io_client/socket_io_client.dart' as io;

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  _AlertsPageState createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  List<Map<String, dynamic>> _alerts = [];
  late io.Socket _socket;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
    _connectToSocket();
  }

  /// ✅ Fetch Alerts from API
  Future<void> _fetchAlerts() async {
    try {
      final response = await http.get(
        Uri.parse("https://bustrackingapp-oezp.onrender.com/alerts"),
      );

      if (response.statusCode == 200) {
        setState(() {
          _alerts = List<Map<String, dynamic>>.from(jsonDecode(response.body));
          _isLoading = false;
        });
      } else {
        _showError("⚠️ Failed to load alerts");
      }
    } catch (e) {
      _showError("❌ Error fetching alerts: $e");
    }
  }

  /// ✅ Connect to WebSocket for Real-Time Alerts
  void _connectToSocket() {
    _socket = io.io("wss://bustrackingapp-oezp.onrender.com", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });

    _socket.connect();
    _socket.on("newAlert", (data) {
      setState(() {
        _alerts.insert(0, Map<String, dynamic>.from(data));
      });

      // ✅ Show Snackbar Notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🚨 New Alert: ${data['message']}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    });
  }

  /// ✅ Show Error in Snackbar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    setState(() {
      _isLoading = false;
    });
  }

  /// ✅ Format Timestamp for Readability
  String _formatTimestamp(String timestamp) {
    DateTime parsedTime = DateTime.parse(timestamp);
    return DateFormat("MMM dd, yyyy - hh:mm a").format(parsedTime);
  }

  /// ✅ Get Icon for Alert Type
  IconData _getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'delay':
        return Icons.timer;
      case 'route change':
        return Icons.alt_route;
      case 'emergency':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  /// ✅ Get Color for Alert Type
  Color _getAlertColor(String type) {
    switch (type.toLowerCase()) {
      case 'delay':
        return Colors.orangeAccent;
      case 'route change':
        return Colors.blueAccent;
      case 'emergency':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🚨 Alerts & Announcements"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _getAlertColor(alert["type"]),
                      child: Icon(
                        _getAlertIcon(alert["type"]),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      alert["message"],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Bus: ${alert["busId"]} • ${_formatTimestamp(alert["timestamp"])}",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
