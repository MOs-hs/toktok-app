import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'firebase_service.dart';
import 'models.dart';

class OrderNowScreen extends StatefulWidget {
  final Marketplace marketplace;

  const OrderNowScreen({super.key, required this.marketplace});

  @override
  State<OrderNowScreen> createState() => _OrderNowScreenState();
}

class _OrderNowScreenState extends State<OrderNowScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  static const Color noturnoBg = Color(0xFF001621);
  static const Color noturnoCard = Color(0xFF0A2230);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  GoogleMapController? _mapController;
  LatLng _selectedLatLng = const LatLng(
    33.8938,
    35.5018,
  ); // Default coordinates

  Product? _selectedProduct;
  bool _isLoadingLocation = false;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _locationController.text =
        "${_selectedLatLng.latitude.toStringAsFixed(6)}, ${_selectedLatLng.longitude.toStringAsFixed(6)}";
  }

  double _getDiscountedPrice(Product product) {
    double price = product.price;
    final activeDiscounts = AppData.discounts.where(
      (d) => d.marketplaceId == widget.marketplace.id && d.isActive,
    );
    for (var discount in activeDiscounts) {
      price -= price * (discount.percentage / 100);
    }
    return price;
  }

  void _updateMapLocation(LatLng position) {
    setState(() {
      _selectedLatLng = position;
      _locationController.text =
          "${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final newLatLng = LatLng(position.latitude, position.longitude);
      _updateMapLocation(newLatLng);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newLatLng, 15));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _placeOrder() async {
    User? user;
    try {
      if (Firebase.apps.isNotEmpty) {
        user = FirebaseAuth.instance.currentUser;
      }
    } catch (e) {
      debugPrint("Firebase Auth Error: $e");
    }

    if (user == null) {
      _showLoginDialog();
      return;
    }

    if (_selectedProduct == null || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a product and provide location"),
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    final finalPrice = _getDiscountedPrice(_selectedProduct!);

    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: user.uid,
      marketplaceId: widget.marketplace.id,
      productName: _selectedProduct!.name,
      price: finalPrice,
      remarks: _remarksController.text,
      location: _locationController.text,
      status: OrderStatus.placed,
      timestamp: DateTime.now(),
    );

    try {
      await _firebaseService.placeOrder(newOrder);
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to place order: $e")));
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: noturnoCard,
        title: const Text(
          "Login Required",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "You must be logged in to place an order.",
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: vulcanicoPrimary),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: noturnoCard,
        title: const Text(
          "Order Placed!",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Your order has been placed. Waiting for a driver to accept...",
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: vulcanicoPrimary),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marketplaceProducts = AppData.products
        .where((p) => p.marketplaceId == widget.marketplace.id)
        .toList();

    return Scaffold(
      backgroundColor: noturnoBg,
      appBar: AppBar(
        title: Text("Order from ${widget.marketplace.name}"),
        backgroundColor: noturnoCard,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Product",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                ...marketplaceProducts.map(
                  (product) {
                    final originalPrice = product.price;
                    final discountedPrice = _getDiscountedPrice(product);
                    final hasDiscount = discountedPrice < originalPrice;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: noturnoCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedProduct == product
                              ? vulcanicoPrimary
                              : const Color(0xFF1E3A4B),
                          width: _selectedProduct == product ? 2 : 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _selectedProduct = product),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Radio<Product>(
                                  value: product,
                                  groupValue: _selectedProduct,
                                  onChanged: (value) =>
                                      setState(() => _selectedProduct = value),
                                  activeColor: vulcanicoPrimary,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    color: noturnoBg,
                                    child: kIsWeb ||
                                            product.imageUrl.startsWith('http') ||
                                            product.imageUrl.startsWith('blob:')
                                        ? Image.network(
                                            product.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.fastfood,
                                                      color: vulcanicoPrimary,
                                                      size: 28,
                                                    ),
                                          )
                                        : Image.file(
                                            File(product.imageUrl),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.fastfood,
                                                      color: vulcanicoPrimary,
                                                      size: 28,
                                                    ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (hasDiscount)
                                        Container(
                                          margin: const EdgeInsets.only(top: 2),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: vulcanicoPrimary.withAlpha(40),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            "PROMO APPLIED",
                                            style: TextStyle(
                                              color: vulcanicoPrimary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (hasDiscount)
                                      Text(
                                        "\$${originalPrice.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    Text(
                                      "\$${discountedPrice.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Remarks",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _remarksController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Special instructions",
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: noturnoCard,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E3A4B)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: vulcanicoPrimary,
                        width: 2,
                      ),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Delivery Location",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _isLoadingLocation
                          ? null
                          : _getCurrentLocation,
                      icon: _isLoadingLocation
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: vulcanicoPrimary,
                              ),
                            )
                          : const Icon(
                              Icons.my_location,
                              size: 18,
                              color: vulcanicoPrimary,
                            ),
                      label: const Text(
                        "Use Current",
                        style: TextStyle(
                          color: vulcanicoPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: vulcanicoPrimary.withAlpha(100)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SafeGoogleMap(
                      initialPosition: _selectedLatLng,
                      onMapCreated: (controller) => _mapController = controller,
                      onTap: _updateMapLocation,
                      markers: {
                        Marker(
                          markerId: const MarkerId(
                            'selected_delivery_location',
                          ),
                          position: _selectedLatLng,
                          draggable: true,
                          onDragEnd: _updateMapLocation,
                          infoWindow: const InfoWindow(
                            title: 'Delivery Pin',
                            snippet: 'Tap map to move pin',
                          ),
                        ),
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Coordinates or Address",
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: noturnoCard,
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: vulcanicoPrimary,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E3A4B)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: vulcanicoPrimary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (text) {
                    try {
                      final parts = text.split(',');
                      if (parts.length == 2) {
                        final lat = double.parse(parts[0].trim());
                        final lng = double.parse(parts[1].trim());
                        final newPos = LatLng(lat, lng);
                        setState(() {
                          _selectedLatLng = newPos;
                        });
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(newPos),
                        );
                      }
                    } catch (_) {}
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vulcanicoPrimary,
                      foregroundColor: Colors.white,
                      elevation: 6,
                    ),
                    onPressed: _isPlacingOrder ? null : _placeOrder,
                    child: const Text(
                      "PLACE ORDER",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isPlacingOrder)
            const Center(
              child: CircularProgressIndicator(color: vulcanicoPrimary),
            ),
        ],
      ),
    );
  }
}

class SafeGoogleMap extends StatefulWidget {
  final LatLng initialPosition;
  final ValueChanged<GoogleMapController>? onMapCreated;
  final ValueChanged<LatLng>? onTap;
  final Set<Marker> markers;

  const SafeGoogleMap({
    super.key,
    required this.initialPosition,
    this.onMapCreated,
    this.onTap,
    this.markers = const {},
  });

  @override
  State<SafeGoogleMap> createState() => _SafeGoogleMapState();
}

class _SafeGoogleMapState extends State<SafeGoogleMap> {
  bool _hasError = false;

  static const Color noturnoCard = Color(0xFF0A2230);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildFallbackView();
    }

    final originalErrorBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) {
      ErrorWidget.builder = originalErrorBuilder;
      return _buildFallbackView();
    };

    try {
      final widgetResult = GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialPosition,
          zoom: 14,
        ),
        onMapCreated: widget.onMapCreated,
        onTap: widget.onTap,
        markers: widget.markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
      );
      ErrorWidget.builder = originalErrorBuilder;
      return widgetResult;
    } catch (e) {
      ErrorWidget.builder = originalErrorBuilder;
      return _buildFallbackView();
    }
  }

  Widget _buildFallbackView() {
    return Container(
      color: noturnoCard,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 48, color: vulcanicoPrimary),
              const SizedBox(height: 8),
              Text(
                "Delivery Location Pinned:\n${widget.initialPosition.latitude.toStringAsFixed(6)}, ${widget.initialPosition.longitude.toStringAsFixed(6)}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Tap 'Use Current' or edit coordinates below",
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
