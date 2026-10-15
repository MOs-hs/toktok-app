import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  static const Color noturnoBg = Color(0xFF001621);
  static const Color noturnoCard = Color(0xFF0A2230);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  @override
  Widget build(BuildContext context) {
    final pendingOrders = AppData.myOrders
        .where(
          (o) =>
              o.status != OrderStatus.delivered &&
              o.status != OrderStatus.cancelled,
        )
        .toList();
    final oldOrders = AppData.myOrders
        .where(
          (o) =>
              o.status == OrderStatus.delivered ||
              o.status == OrderStatus.cancelled,
        )
        .toList();

    return Scaffold(
      backgroundColor: noturnoBg,
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: noturnoCard,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pending Orders (On my way)",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            if (pendingOrders.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  "No active orders.",
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              )
            else
              ...pendingOrders.map((order) => _buildOrderCard(order)),
            const SizedBox(height: 20),
            const Text(
              "Old Orders",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            if (oldOrders.isEmpty)
              const Text(
                "No past orders.",
                style: TextStyle(color: Color(0xFF94A3B8)),
              )
            else
              ...oldOrders.map((order) => _buildOrderCard(order)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: noturnoCard,
        borderRadius: BorderRadius.circular(14),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "Status: ${_getStatusText(order.status)}",
              style: const TextStyle(
                color: vulcanicoPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Date: ${DateFormat('dd MMM yyyy, HH:mm').format(order.timestamp)}",
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ),
        trailing: Text(
          "\$${order.price.toStringAsFixed(2)}",
          style: const TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return "Waiting for driver";
      case OrderStatus.accepted:
        return "Driver coming to market";
      case OrderStatus.packing:
        return "Market packing your order";
      case OrderStatus.pickedUp:
        return "We are coming...";
      case OrderStatus.delivered:
        return "Delivered";
      case OrderStatus.cancelled:
        return "Cancelled";
    }
  }
}
