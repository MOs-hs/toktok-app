import 'package:flutter/material.dart';

import 'category_card.dart';
import 'marketplace_list_screen.dart';
import 'models.dart';
import 'my_orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isArabic = false;

  static const Color noturnoBg = Color(0xFF001621);
  static const Color noturnoCard = Color(0xFF0A2230);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: noturnoBg,
        appBar: AppBar(
          backgroundColor: noturnoCard,
          title: Row(
            children: [
              const Icon(
                Icons.delivery_dining,
                color: vulcanicoPrimary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                isArabic ? "توك توك" : "TokTok",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: vulcanicoPrimary.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: vulcanicoPrimary.withAlpha(100)),
              ),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    isArabic = !isArabic;
                  });
                },
                child: Text(
                  isArabic ? "English" : "عربي",
                  style: const TextStyle(
                    color: vulcanicoPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: noturnoCard,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A2230), Color(0xFF001621)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.delivery_dining,
                      color: vulcanicoPrimary,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isArabic ? "قائمة توك توك" : "TokTok Menu",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.login, color: vulcanicoPrimary),
                title: Text(
                  isArabic ? "تسجيل الدخول" : "Login",
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pushNamed(context, '/login'),
              ),
              ListTile(
                leading: const Icon(
                  Icons.shopping_bag,
                  color: vulcanicoPrimary,
                ),
                title: Text(
                  isArabic ? "طلباتي" : "Orders",
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyOrdersScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: vulcanicoPrimary),
                title: Text(
                  isArabic ? "خيارات" : "Options",
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
        body: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: AppData.categories.map((category) {
            return CategoryCard(
              title: isArabic ? _translate(category.title) : category.title,
              icon: category.icon,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MarketplaceListScreen(category: category),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _translate(String title) {
    switch (title) {
      case 'Restaurants':
        return 'مطاعم';
      case 'Supermarkets':
        return 'سوبر ماركت';
      case 'Pharmacies':
        return 'صيدليات';
      case 'Electronics':
        return 'إلكترونيات';
      default:
        return title;
    }
  }
}
