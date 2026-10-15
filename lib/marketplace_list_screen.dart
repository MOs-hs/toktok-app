import 'package:flutter/material.dart';

import 'models.dart';
import 'order_now_screen.dart';

class MarketplaceListScreen extends StatelessWidget {
  final Category category;

  static const Color noturnoBg = Color(0xFF001621);
  static const Color noturnoCard = Color(0xFF0A2230);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  const MarketplaceListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final filteredMarkets = AppData.marketplaces
        .where((m) => m.categoryId == category.id)
        .toList();

    return Scaffold(
      backgroundColor: noturnoBg,
      appBar: AppBar(
        backgroundColor: noturnoCard,
        title: Text(
          category.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: filteredMarkets.isEmpty
          ? const Center(
              child: Text(
                "No marketplaces found in this category.",
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredMarkets.length,
              itemBuilder: (context, index) {
                final market = filteredMarkets[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: noturnoCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF1E3A4B),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(80),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderNowScreen(marketplace: market),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: noturnoBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: vulcanicoPrimary.withAlpha(60),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  market.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.store,
                                      size: 40,
                                      color: vulcanicoPrimary,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    market.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "4.5 • Open now",
                                        style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Fast delivery in 20-30 min",
                                    style: const TextStyle(
                                      color: vulcanicoPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
