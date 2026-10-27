import 'package:flutter/material.dart';
import 'package:frontend_dilaundry/config/app_error.dart';
import 'package:frontend_dilaundry/config/nav.dart';
import 'package:frontend_dilaundry/datasources/promo_datasource.dart';
import 'package:frontend_dilaundry/datasources/shop_datasource.dart';
import 'package:frontend_dilaundry/models/promo_model.dart';
import 'package:frontend_dilaundry/models/shop_model.dart';
import 'package:frontend_dilaundry/models/user_model.dart';
import 'package:frontend_dilaundry/pages/recommendation_page.dart';
import 'package:frontend_dilaundry/pages/shop_detail_page.dart';
import 'package:frontend_dilaundry/widgets/empty_state.dart';
import 'package:frontend_dilaundry/widgets/promo_card.dart';
import 'package:frontend_dilaundry/widgets/section_title.dart';
import 'package:frontend_dilaundry/widgets/shop_card.dart';

class HomePage extends StatefulWidget {
  final UserModel user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  late Future<List<PromoModel>> _promoFuture;
  late Future<List<ShopModel>> _recommendationFuture;
  late Future<List<ShopModel>> _shopFuture;
  Future<List<ShopModel>>? _searchFuture;
  List<PromoModel> _allPromos = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    _promoFuture = PromoDatasource.readLimit();
    _recommendationFuture = ShopDatasource.readRecommendation();
    _shopFuture = ShopDatasource.readAll();
    PromoDatasource.readAll().then((promos) {
      if (mounted) setState(() => _allPromos = promos);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _runSearch() {
    final city = _searchController.text.trim();
    if (city.isEmpty) {
      setState(() => _searchFuture = null);
      return;
    }
    setState(() => _searchFuture = ShopDatasource.searchByCity(city));
  }

  void _openShop(ShopModel shop) {
    final promos = _allPromos.where((p) => p.shopId == shop.id).toList();
    Nav.push(context, ShopDetailPage(shop: shop, promos: promos));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selamat datang', style: TextStyle(fontSize: 12)),
            Text(
              widget.user.username,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_loadAll);
          await Future.wait([_promoFuture, _shopFuture]);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildSearchBar(),
            if (_searchFuture != null) _buildSearchResult(),
            const SectionTitle(title: 'Promo Terbaru'),
            _buildPromoSection(),
            SectionTitle(
              title: 'Rekomendasi Untukmu',
              onSeeAll: () {
                Nav.push(context, const RecommendationPage());
              },
            ),
            _buildRecommendationSection(),
            const SectionTitle(title: 'Semua Toko Laundry'),
            _buildShopSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _runSearch(),
      decoration: InputDecoration(
        hintText: 'Cari toko berdasarkan kota, misalnya Bandung',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchFuture != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchFuture = null);
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _runSearch,
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildSearchResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Hasil Pencarian Kota'),
        FutureBuilder<List<ShopModel>>(
          future: _searchFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return EmptyState(message: appErrorMessage(snapshot.error!));
            }
            final shops = snapshot.data ?? [];
            if (shops.isEmpty) {
              return const EmptyState(
                message: 'Tidak ada toko di kota itu. Coba kota lain.',
              );
            }
            return Column(
              children: shops
                  .map(
                    (shop) => ShopCard(
                      shop: shop,
                      onTap: () => _openShop(shop),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPromoSection() {
    return SizedBox(
      height: 215,
      child: FutureBuilder<List<PromoModel>>(
        future: _promoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return EmptyState(message: appErrorMessage(snapshot.error!));
          }
          final promos = snapshot.data ?? [];
          if (promos.isEmpty) {
            return const EmptyState(message: 'Belum ada promo saat ini.');
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: promos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 4),
            itemBuilder: (context, index) {
              final promo = promos[index];
              return PromoCard(
                promo: promo,
                onTap: () => _openShop(promo.shop),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecommendationSection() {
    return FutureBuilder<List<ShopModel>>(
      future: _recommendationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return EmptyState(message: appErrorMessage(snapshot.error!));
        }
        final shops = snapshot.data ?? [];
        if (shops.isEmpty) {
          return const EmptyState(message: 'Belum ada rekomendasi toko.');
        }
        return Column(
          children: shops
              .take(3)
              .map(
                (shop) => ShopCard(shop: shop, onTap: () => _openShop(shop)),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildShopSection() {
    return FutureBuilder<List<ShopModel>>(
      future: _shopFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return EmptyState(message: appErrorMessage(snapshot.error!));
        }
        final shops = snapshot.data ?? [];
        if (shops.isEmpty) {
          return const EmptyState(message: 'Belum ada toko laundry.');
        }
        return Column(
          children: shops
              .map(
                (shop) => ShopCard(shop: shop, onTap: () => _openShop(shop)),
              )
              .toList(),
        );
      },
    );
  }
}
