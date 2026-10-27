import 'package:flutter/material.dart';
import 'package:frontend_dilaundry/config/app_error.dart';
import 'package:frontend_dilaundry/config/nav.dart';
import 'package:frontend_dilaundry/datasources/promo_datasource.dart';
import 'package:frontend_dilaundry/datasources/shop_datasource.dart';
import 'package:frontend_dilaundry/models/promo_model.dart';
import 'package:frontend_dilaundry/models/shop_model.dart';
import 'package:frontend_dilaundry/pages/shop_detail_page.dart';
import 'package:frontend_dilaundry/widgets/empty_state.dart';
import 'package:frontend_dilaundry/widgets/shop_card.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  late Future<List<ShopModel>> _recommendationFuture;
  List<PromoModel> _allPromos = [];

  @override
  void initState() {
    super.initState();
    _recommendationFuture = ShopDatasource.readRecommendation();
    PromoDatasource.readAll().then((promos) {
      if (mounted) setState(() => _allPromos = promos);
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekomendasi Toko')),
      body: FutureBuilder<List<ShopModel>>(
        future: _recommendationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return EmptyState(message: appErrorMessage(snapshot.error!));
          }
          final shops = snapshot.data ?? [];
          if (shops.isEmpty) {
            return const EmptyState(message: 'Belum ada rekomendasi toko.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shops.length,
            itemBuilder: (context, index) {
              final shop = shops[index];
              final promos = _allPromos
                  .where((promo) => promo.shopId == shop.id)
                  .toList();
              return ShopCard(
                shop: shop,
                onTap: () {
                  Nav.push(
                    context,
                    ShopDetailPage(shop: shop, promos: promos),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
