import 'package:flutter/material.dart';
import 'package:frontend_dilaundry/config/app_assets.dart';
import 'package:frontend_dilaundry/config/app_constants.dart';
import 'package:frontend_dilaundry/config/app_format.dart';
import 'package:frontend_dilaundry/config/nav.dart';
import 'package:frontend_dilaundry/models/promo_model.dart';
import 'package:frontend_dilaundry/models/shop_model.dart';
import 'package:frontend_dilaundry/pages/create_order_page.dart';

class ShopDetailPage extends StatelessWidget {
  final ShopModel shop;
  final List<PromoModel> promos;
  const ShopDetailPage({super.key, required this.shop, required this.promos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(shop.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              '${AppConstants.baseImageUrl}${shop.image}',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  AppAssets.placeHolderLaundry,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  shop.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                shop.rate.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text('${shop.location}, ${shop.city}')),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Image.asset(AppAssets.wa, width: 16, height: 16),
              const SizedBox(width: 4),
              Text('WhatsApp ${shop.whatsapp}'),
            ],
          ),
          const SizedBox(height: 14),
          Text(shop.description, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Harga dan Layanan',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.price_change_outlined,
                    label: 'Harga reguler',
                    value: '${AppFormat.longPrice(shop.price)} per kg',
                  ),
                  _InfoRow(
                    icon: Icons.local_shipping_outlined,
                    label: 'Penjemputan',
                    value: shop.pickup ? 'Tersedia' : 'Tidak tersedia',
                  ),
                  _InfoRow(
                    icon: Icons.delivery_dining_outlined,
                    label: 'Pengantaran',
                    value: shop.delivery ? 'Tersedia' : 'Tidak tersedia',
                  ),
                ],
              ),
            ),
          ),
          if (promos.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Paket Promo Toko Ini',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ...promos.map(
              (promo) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.local_offer_outlined),
                  title: Text(promo.description),
                  subtitle: Text(
                    'Dari ${AppFormat.longPrice(promo.oldPrice)} menjadi '
                    '${AppFormat.longPrice(promo.newPrice)} per kg',
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Nav.push(context, CreateOrderPage(shop: shop, promos: promos));
            },
            icon: const Icon(Icons.shopping_basket_outlined),
            label: const Text('Pesan Sekarang'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
