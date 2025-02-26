import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SocketService {
  static const String socketUrl =
      'wss://bustrackingapp-oezp.onrender.com'; // ✅ Removed :10000
  static late io.Socket socket;
  static Function(LatLng, String)? onLocationUpdate;

  /// ✅ Connect to WebSocket Server
  static void connectToSocket() {
    socket = io.io(
      socketUrl,
      io.OptionBuilder().setTransports(['websocket']).setExtraHeaders(
              {'withCredentials': 'false'}) // ✅ Fix CORS issues
          .build(),
    );

    socket.onConnect((_) {
      print("🟢 Connected to WebSocket Server");
      socket.emit("busLocationRequest",
          {"request": "nearbyBuses"}); // ✅ Request bus locations
    });

    socket
        .onConnectError((data) => print("⚠ WebSocket Connection Error: $data"));
    socket.onError((data) => print("❌ WebSocket Error: $data"));
    socket.onDisconnect((_) => print("🔴 Disconnected from WebSocket"));

    /// ✅ Listen for Bus Location Updates
    socket.on("busLocation", (data) {
      print("📍 Received Live Bus Location: $data"); // ✅ Debugging Log

      if (data != null &&
          data['latitude'] != null &&
          data['longitude'] != null) {
        LatLng location = LatLng(data['latitude'], data['longitude']);
        String busId = data['busId'];

        if (onLocationUpdate != null) {
          onLocationUpdate!(location, busId);
        }
      } else {
        print("⚠ Invalid Bus Location Data Received");
      }
    });

    socket.connect();
  }

  /// ✅ Disconnect WebSocket
  static void disconnectSocket() {
    if (socket.connected) {
      socket.disconnect();
      print("🔴 WebSocket Disconnected");
    }
  }
}
