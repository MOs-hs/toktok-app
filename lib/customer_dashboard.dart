import 'package:flutter/material.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  static const Color noturnoBg = Color(0xFF001621);
  static const Color noturnoCard = Color(0xFF0A2230);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: noturnoBg,
      appBar: AppBar(
        backgroundColor: noturnoCard,
        title: const Text(
          "TokTok Customer",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: vulcanicoPrimary.withAlpha(30),
                    border: Border.all(color: vulcanicoPrimary.withAlpha(120)),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: vulcanicoPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Welcome back, Mo!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "TokTok VIP Customer",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("Recent Orders"),
            _buildOrderItem(
              "Supermarket",
              "In Progress",
              Icons.local_grocery_store,
            ),
            _buildOrderItem("Pizza Palace", "Delivered", Icons.restaurant),
            const SizedBox(height: 24),
            _buildSectionHeader("Recommended for You"),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildPromoCard("Daily Vegetables", Colors.greenAccent),
                  _buildPromoCard("Fresh Bread", Colors.orangeAccent),
                  _buildPromoCard("Pharmacy", Colors.cyanAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOrderItem(String store, String status, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: noturnoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A4B)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: vulcanicoPrimary.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: vulcanicoPrimary),
        ),
        title: Text(
          store,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          status,
          style: TextStyle(
            color: status == "In Progress"
                ? vulcanicoPrimary
                : Colors.greenAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _buildPromoCard(String title, Color accentColor) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: noturnoCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withAlpha(100)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
