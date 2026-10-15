import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'models.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final List<Map<String, dynamic>> fallbackAgents = [
    {
      "name": "Ahmed Ali",
      "rating": 4.8,
      "trips": 120,
      "whishPhone": "+96170112233",
      "isBlacklisted": false,
    },
    {
      "name": "John Doe",
      "rating": 2.5,
      "trips": 45,
      "whishPhone": "+96171445566",
      "isBlacklisted": false,
    },
    {
      "name": "Samir Khan",
      "rating": 4.5,
      "trips": 89,
      "whishPhone": "+96176778899",
      "isBlacklisted": false,
    },
  ];

  final List<Map<String, String>> blacklisted = [
    {"name": "Bad Driver 1", "reason": "Consistent late deliveries"},
    {"name": "Unreliable Agent", "reason": "Customer complaints"},
  ];

  final _categoryNameController = TextEditingController();
  IconData _selectedIcon = Icons.category;

  static const Color noturnoBg = Color(0xFF001621);
  static const Color noturnoCard = Color(0xFF0A2230);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: noturnoBg,
        appBar: AppBar(
          backgroundColor: noturnoCard,
          title: const Text(
            "TokTok Admin Panel",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: vulcanicoPrimary,
            indicatorWeight: 3,
            labelColor: vulcanicoPrimary,
            unselectedLabelColor: Color(0xFF94A3B8),
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.people_outline), text: "Manage Drivers"),
              Tab(icon: Icon(Icons.block_flipped), text: "Blacklist"),
              Tab(icon: Icon(Icons.add_box_outlined), text: "Add Category"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildManageAgents(),
            _buildBlacklist(),
            _buildAddCategory(),
          ],
        ),
      ),
    );
  }

  Widget _buildManageAgents() {
    if (Firebase.apps.isEmpty) {
      return _buildAgentsList(fallbackAgents);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'agent')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildAgentsList(fallbackAgents);
        }

        final liveAgents = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            "name": data['fullName'] ?? "Driver",
            "rating": 5.0,
            "trips": 0,
            "phone": data['phone'] ?? "",
            "whishPhone": data['whishPhone'] ?? data['phone'] ?? "N/A",
            "email": data['email'] ?? "",
            "isBlacklisted": false,
          };
        }).toList();

        return _buildAgentsList(liveAgents);
      },
    );
  }

  Widget _buildAgentsList(List<Map<String, dynamic>> agentList) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agentList.length,
      itemBuilder: (context, index) {
        final agent = agentList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: noturnoCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E3A4B)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: vulcanicoPrimary.withAlpha(30),
              child: const Icon(Icons.person, color: vulcanicoPrimary),
            ),
            title: Text(
              agent['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      "${agent['rating']} (${agent['trips']} trips)",
                      style: const TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                if (agent['whishPhone'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        size: 14,
                        color: Colors.greenAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Whish Payout: ${agent['whishPhone']}",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: vulcanicoPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _confirmBlacklist(agent['name']),
              child: const Text("Blacklist"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlacklist() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: blacklisted.length,
      itemBuilder: (context, index) {
        final item = blacklisted[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: noturnoCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: vulcanicoPrimary.withAlpha(120)),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.warning_amber_rounded,
              color: vulcanicoPrimary,
            ),
            title: Text(
              item['name']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: vulcanicoPrimary,
              ),
            ),
            subtitle: Text(
              "Reason: ${item['reason']}",
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
            trailing: TextButton(
              onPressed: () {},
              child: const Text(
                "Restore",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddCategory() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Create a New Category",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _categoryNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Category Name",
              labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: noturnoCard,
              prefixIcon: const Icon(Icons.label, color: vulcanicoPrimary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1E3A4B)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: vulcanicoPrimary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Select Icon:",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _iconPicker(Icons.restaurant),
              _iconPicker(Icons.local_grocery_store),
              _iconPicker(Icons.local_pharmacy),
              _iconPicker(Icons.devices),
              _iconPicker(Icons.directions_car),
              _iconPicker(Icons.fastfood),
              _iconPicker(Icons.shopping_bag),
              _iconPicker(Icons.pets),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: vulcanicoPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
              onPressed: () {
                if (_categoryNameController.text.isNotEmpty) {
                  setState(() {
                    AppData.categories.add(
                      Category(
                        id: (AppData.categories.length + 1).toString(),
                        title: _categoryNameController.text,
                        icon: _selectedIcon,
                      ),
                    );
                    _categoryNameController.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Category added successfully!"),
                    ),
                  );
                }
              },
              child: const Text(
                "Add Category",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconPicker(IconData icon) {
    bool isSelected = _selectedIcon == icon;
    return GestureDetector(
      onTap: () => setState(() => _selectedIcon = icon),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? vulcanicoPrimary : noturnoCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? vulcanicoPrimary : const Color(0xFF1E3A4B),
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  void _confirmBlacklist(String agentName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: noturnoCard,
        title: const Text(
          "Blacklist Driver?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to blacklist $agentName? They will no longer be able to accept orders.",
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: vulcanicoPrimary),
            onPressed: () {
              setState(() {
                blacklisted.add({
                  "name": agentName,
                  "reason": "Admin Manual Blacklist",
                });
              });
              Navigator.pop(context);
            },
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
