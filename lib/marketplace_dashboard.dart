import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'models.dart';

class MarketplaceDashboard extends StatefulWidget {
  const MarketplaceDashboard({super.key});

  @override
  State<MarketplaceDashboard> createState() => _MarketplaceDashboardState();
}

class _MarketplaceDashboardState extends State<MarketplaceDashboard> {
  final String myMarketId = 'm1';
  final ImagePicker _picker = ImagePicker();

  static const Color noturnoBg = Color(0xFF001621);
  static const Color noturnoCard = Color(0xFF0A2230);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  @override
  Widget build(BuildContext context) {
    final myProducts = AppData.products
        .where((p) => p.marketplaceId == myMarketId)
        .toList();

    final activeOrders = AppData.myOrders
        .where(
          (o) =>
              o.marketplaceId == myMarketId &&
              (o.status == OrderStatus.accepted ||
                  o.status == OrderStatus.packing),
        )
        .toList();

    final deliveredOrders = AppData.myOrders
        .where(
          (o) =>
              o.marketplaceId == myMarketId &&
              o.status == OrderStatus.delivered,
        )
        .toList();

    double dailyIncome = 0;
    double monthlyIncome = 0;
    DateTime now = DateTime.now();

    for (var order in deliveredOrders) {
      if (order.timestamp.day == now.day &&
          order.timestamp.month == now.month &&
          order.timestamp.year == now.year) {
        dailyIncome += order.price;
      }
      if (order.timestamp.month == now.month &&
          order.timestamp.year == now.year) {
        monthlyIncome += order.price;
      }
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: noturnoBg,
        appBar: AppBar(
          title: const Text(
            "Marketplace Dashboard",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: noturnoCard,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: vulcanicoPrimary,
            indicatorWeight: 3,
            labelColor: vulcanicoPrimary,
            unselectedLabelColor: Color(0xFF94A3B8),
            tabs: [
              Tab(icon: Icon(Icons.inventory_2), text: "Products"),
              Tab(icon: Icon(Icons.receipt_long), text: "Orders"),
              Tab(icon: Icon(Icons.local_offer), text: "Discounts"),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildIncomeCard(dailyIncome, monthlyIncome),
            Expanded(
              child: TabBarView(
                children: [
                  _buildProductsGrid(myProducts),
                  _buildOrdersList(activeOrders),
                  _buildDiscountsTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: vulcanicoPrimary,
          onPressed: _showAddProductDialog,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildIncomeCard(double daily, double monthly) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: noturnoCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: vulcanicoPrimary.withAlpha(100)),
        boxShadow: [
          BoxShadow(color: vulcanicoPrimary.withAlpha(30), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _incomeItem("Daily Income", daily),
          Container(width: 1, height: 40, color: const Color(0xFF1E3A4B)),
          _incomeItem("Monthly Income", monthly),
        ],
      ),
    );
  }

  Widget _incomeItem(String label, double amount) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.greenAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          decoration: BoxDecoration(
            color: noturnoCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E3A4B)),
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child:
                      kIsWeb ||
                          product.imageUrl.startsWith('http') ||
                          product.imageUrl.startsWith('blob:')
                      ? Image.network(
                          product.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: vulcanicoPrimary,
                              ),
                        )
                      : Image.file(
                          File(product.imageUrl),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${product.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          "No orders to pack.",
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
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
              order.status == OrderStatus.accepted
                  ? "Driver is coming..."
                  : "Packing in progress",
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
            trailing: order.status == OrderStatus.accepted
                ? const Icon(Icons.timer, color: Colors.amber)
                : const Icon(Icons.inventory, color: vulcanicoPrimary),
            onTap: () {
              if (order.status == OrderStatus.accepted) {
                _updateOrderStatus(order, OrderStatus.packing);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildDiscountsTab() {
    final myDiscounts = AppData.discounts
        .where((d) => d.marketplaceId == myMarketId)
        .toList();

    return Scaffold(
      backgroundColor: noturnoBg,
      body: myDiscounts.isEmpty
          ? const Center(
              child: Text(
                "No active discounts. Create one below!",
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myDiscounts.length,
              itemBuilder: (context, index) {
                final discount = myDiscounts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: noturnoCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: discount.isActive
                          ? vulcanicoPrimary
                          : const Color(0xFF1E3A4B),
                    ),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      discount.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      "${discount.percentage}% Off Storewide",
                      style: const TextStyle(color: Colors.greenAccent),
                    ),
                    value: discount.isActive,
                    activeColor: vulcanicoPrimary,
                    onChanged: (val) {
                      setState(() {
                        discount.isActive = val;
                      });
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: vulcanicoPrimary,
        onPressed: _showAddDiscountDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Discount",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showAddDiscountDialog() {
    final titleController = TextEditingController();
    final percentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: noturnoCard,
        title: const Text(
          "Create New Discount",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Discount Title (e.g., Happy Hour)",
                labelStyle: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: percentController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Percentage Off (e.g., 20)",
                labelStyle: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: vulcanicoPrimary),
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  percentController.text.isNotEmpty) {
                setState(() {
                  AppData.discounts.add(
                    Discount(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      marketplaceId: myMarketId,
                      title: titleController.text,
                      percentage:
                          double.tryParse(percentController.text) ?? 0.0,
                      isActive: true,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(Order order, OrderStatus newStatus) {
    setState(() {
      int index = AppData.myOrders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        AppData.myOrders[index] = Order(
          id: order.id,
          customerId: order.customerId,
          marketplaceId: order.marketplaceId,
          agentId: order.agentId,
          productName: order.productName,
          price: order.price,
          remarks: order.remarks,
          location: order.location,
          status: newStatus,
          timestamp: order.timestamp,
        );
      }
    });
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    String? pickedImagePath;
    double? pickedImageMB;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: noturnoCard,
          title: const Text(
            "Add New Product",
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    // Pick and automatically compress large image to 800x800, 80% JPEG quality
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      int lengthBytes = await image.length();
                      double sizeMB = lengthBytes / (1024 * 1024);
                      setDialogState(() {
                        pickedImagePath = image.path;
                        pickedImageMB = sizeMB;
                      });
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green[800],
                          content: Text(
                            "Photo auto-compressed to ${sizeMB.toStringAsFixed(2)} MB for fast loading!",
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: noturnoBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: vulcanicoPrimary.withAlpha(100),
                      ),
                    ),
                    child: pickedImagePath == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: vulcanicoPrimary,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Tap to pick photo (Auto-Compressed)",
                                style: TextStyle(color: Color(0xFF94A3B8)),
                              ),
                            ],
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    kIsWeb ||
                                        pickedImagePath!.startsWith('http') ||
                                        pickedImagePath!.startsWith('blob:')
                                    ? Image.network(
                                        pickedImagePath!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(pickedImagePath!),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              if (pickedImageMB != null)
                                Positioned(
                                  bottom: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(180),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "Auto-Compressed (${pickedImageMB!.toStringAsFixed(2)} MB)",
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Product Name",
                    labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
                TextField(
                  controller: priceController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Price",
                    labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Description",
                    labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: vulcanicoPrimary,
              ),
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  setState(() {
                    AppData.products.add(
                      Product(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        price: double.tryParse(priceController.text) ?? 0.0,
                        marketplaceId: myMarketId,
                        imageUrl:
                            pickedImagePath ?? "https://picsum.photos/200",
                      ),
                    );
                  });
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}
