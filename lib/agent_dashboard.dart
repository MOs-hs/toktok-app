import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_service.dart';
import 'models.dart';
import 'order_details_screen.dart';

class AgentDashboard extends StatefulWidget {
  const AgentDashboard({super.key});

  @override
  State<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard> {
  final FirebaseService _firebaseService = FirebaseService();
  bool isAvailable = false;
  String? myAgentId;

  static const Color noturnoBg = Color(0xFF001621);
  static const Color noturnoCard = Color(0xFF0A2230);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  @override
  void initState() {
    super.initState();
    if (Firebase.apps.isNotEmpty) {
      try {
        myAgentId = FirebaseAuth.instance.currentUser?.uid ?? "demo_agent";
      } catch (_) {
        myAgentId = "demo_agent";
      }
    } else {
      myAgentId = "demo_agent";
    }
  }

  void _updateStatus(Order order, OrderStatus newStatus) {
    _firebaseService.updateOrderStatus(order.id, newStatus, agentId: myAgentId);
  }

  LatLng _parseLocation(String loc) {
    try {
      final parts = loc.split(',');
      return LatLng(
        double.parse(parts[0].trim()),
        double.parse(parts[1].trim()),
      );
    } catch (_) {
      return const LatLng(33.8938, 35.5018);
    }
  }

  Future<void> _openGoogleMapsDirections(String loc) async {
    final pos = _parseLocation(loc);
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${pos.latitude},${pos.longitude}&travelmode=driving';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: noturnoBg,
      appBar: AppBar(
        title: const Text(
          "Agent Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: noturnoCard,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAvailabilityToggle(),
            const SizedBox(height: 30),

            // Listen for Active Delivery
            StreamBuilder<Order?>(
              stream: _firebaseService.getActiveOrderForAgent(myAgentId!),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Active Delivery",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildActiveOrderCard(snapshot.data!),
                    ],
                  );
                }

                // If no active delivery, show incoming orders if available
                if (isAvailable) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Incoming Orders",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<List<Order>>(
                        stream: _firebaseService.getAvailableOrders(),
                        builder: (context, ordersSnapshot) {
                          if (!ordersSnapshot.hasData ||
                              ordersSnapshot.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                "Waiting for new orders...",
                                style: TextStyle(color: Color(0xFF94A3B8)),
                              ),
                            );
                          }
                          return Column(
                            children: ordersSnapshot.data!
                                .map((o) => _buildIncomingOrderCard(o))
                                .toList(),
                          );
                        },
                      ),
                    ],
                  );
                }

                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      "Switch to 'Online' to see orders",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isAvailable
            ? Colors.green.withAlpha(30)
            : vulcanicoPrimary.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable ? Colors.green : vulcanicoPrimary,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isAvailable ? "You are Online" : "You are Offline",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isAvailable ? Colors.greenAccent : vulcanicoPrimary,
            ),
          ),
          Switch(
            value: isAvailable,
            activeTrackColor: Colors.green,
            activeThumbColor: Colors.white,
            onChanged: (value) => setState(() => isAvailable = value),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: noturnoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A4B)),
      ),
      child: ListTile(
        title: Text(
          order.productName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          "Price: \$${order.price.toStringAsFixed(2)}",
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: vulcanicoPrimary),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(
                order: order,
                onStatusUpdate: _updateStatus,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: noturnoCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: vulcanicoPrimary, width: 1.5),
        boxShadow: [
          BoxShadow(color: vulcanicoPrimary.withAlpha(60), blurRadius: 10),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Ongoing: ${order.productName}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: "Open Google Maps Directions",
                  icon: const Icon(
                    Icons.directions,
                    color: Colors.blueAccent,
                    size: 28,
                  ),
                  onPressed: () => _openGoogleMapsDirections(order.location),
                ),
                IconButton(
                  tooltip: "Order Details",
                  icon: const Icon(
                    Icons.map,
                    color: vulcanicoPrimary,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsScreen(
                          order: order,
                          onStatusUpdate: _updateStatus,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Status: ${_getStatusText(order.status)}",
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                side: const BorderSide(color: Colors.blueAccent),
              ),
              icon: const Icon(Icons.navigation),
              label: const Text("Navigate via Google Maps"),
              onPressed: () => _openGoogleMapsDirections(order.location),
            ),
            const SizedBox(height: 12),
            if (order.status == OrderStatus.accepted)
              _statusButton(
                "I AM AT MARKET",
                () => _updateStatus(order, OrderStatus.packing),
              )
            else if (order.status == OrderStatus.packing)
              _statusButton(
                "ORDER PICKED UP",
                () => _updateStatus(order, OrderStatus.pickedUp),
              )
            else if (order.status == OrderStatus.pickedUp)
              _statusButton(
                "ORDER DELIVERED",
                () => _updateStatus(order, OrderStatus.delivered),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: vulcanicoPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.accepted:
        return "Heading to market";
      case OrderStatus.packing:
        return "Market preparing order";
      case OrderStatus.pickedUp:
        return "Delivering to customer";
      default:
        return "";
    }
  }
}
