import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;
  final Function(Order, OrderStatus) onStatusUpdate;

  static const Color noturnoBg = Color(0xFF001621);
  static const Color noturnoCard = Color(0xFF0A2230);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.onStatusUpdate,
  });

  LatLng _parseLocation(String loc) {
    try {
      final parts = loc.split(',');
      return LatLng(
        double.parse(parts[0].trim()),
        double.parse(parts[1].trim()),
      );
    } catch (e) {
      return const LatLng(33.8938, 35.5018);
    }
  }

  Future<void> _openInGoogleMaps(LatLng pos) async {
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
    final LatLng customerPos = _parseLocation(order.location);

    return Scaffold(
      backgroundColor: noturnoBg,
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: noturnoCard,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                SafeGoogleMapPreview(
                  targetPosition: customerPos,
                  onMapTap: () => _openInGoogleMaps(customerPos),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton.extended(
                    heroTag: 'navigate_fab',
                    onPressed: () => _openInGoogleMaps(customerPos),
                    backgroundColor: vulcanicoPrimary,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.directions),
                    label: const Text("Directions"),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: noturnoCard,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(color: Color(0xFF1E3A4B), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          order.productName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        "\$${order.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: vulcanicoPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Delivery Location: ${order.location}",
                          style: const TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ],
                  ),
                  if (order.remarks.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      "Remarks: ${order.remarks}",
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (order.status == OrderStatus.placed)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: () {
                              onStatusUpdate(order, OrderStatus.accepted);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "ACCEPT DELIVERY",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.navigation, color: Colors.white),
                        label: const Text("OPEN GOOGLE MAPS DIRECTIONS"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: vulcanicoPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 6,
                        ),
                        onPressed: () => _openInGoogleMaps(customerPos),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SafeGoogleMapPreview extends StatefulWidget {
  final LatLng targetPosition;
  final VoidCallback onMapTap;

  const SafeGoogleMapPreview({
    super.key,
    required this.targetPosition,
    required this.onMapTap,
  });

  @override
  State<SafeGoogleMapPreview> createState() => _SafeGoogleMapPreviewState();
}

class _SafeGoogleMapPreviewState extends State<SafeGoogleMapPreview> {
  bool _hasError = false;

  static const Color noturnoCard = Color(0xFF0A2230);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildFallback();
    }

    final originalErrorBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) {
      ErrorWidget.builder = originalErrorBuilder;
      return _buildFallback();
    };

    try {
      final widgetResult = GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.targetPosition,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('customer'),
            position: widget.targetPosition,
            infoWindow: const InfoWindow(title: 'Customer Location'),
            onTap: widget.onMapTap,
          ),
        },
      );
      ErrorWidget.builder = originalErrorBuilder;
      return widgetResult;
    } catch (e) {
      ErrorWidget.builder = originalErrorBuilder;
      return _buildFallback();
    }
  }

  Widget _buildFallback() {
    return Container(
      color: noturnoCard,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, size: 56, color: vulcanicoPrimary),
              const SizedBox(height: 8),
              Text(
                "Customer Target Location:\n${widget.targetPosition.latitude.toStringAsFixed(6)}, ${widget.targetPosition.longitude.toStringAsFixed(6)}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: vulcanicoPrimary,
                ),
                icon: const Icon(Icons.directions),
                label: const Text("Open Directions in Google Maps"),
                onPressed: widget.onMapTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
