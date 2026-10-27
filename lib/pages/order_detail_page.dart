import 'package:flutter/material.dart';
import 'package:frontend_dilaundry/config/app_format.dart';
import 'package:frontend_dilaundry/models/laundry_model.dart';
import 'package:frontend_dilaundry/widgets/status_chip.dart';

class OrderDetailPage extends StatelessWidget {
  final LaundryModel laundry;
  const OrderDetailPage({super.key, required this.laundry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Kode Klaim',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    laundry.claimCode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatusChip(status: laundry.status),
                  const SizedBox(height: 8),
                  Text(
                    'Dibuat pada ${AppFormat.fullDate(laundry.createdAt)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rincian Pesanan',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(label: 'Toko', value: laundry.shop.name),
                  _DetailRow(
                    label: 'Kota',
                    value: '${laundry.shop.location}, ${laundry.shop.city}',
                  ),
                  _DetailRow(label: 'Berat', value: '${laundry.weight} kg'),
                  _DetailRow(
                    label: 'Penjemputan',
                    value: laundry.withPickup ? 'Ya' : 'Tidak',
                  ),
                  if (laundry.pickupAddress.isNotEmpty)
                    _DetailRow(
                      label: 'Alamat jemput',
                      value: laundry.pickupAddress,
                    ),
                  _DetailRow(
                    label: 'Pengantaran',
                    value: laundry.withDelivery ? 'Ya' : 'Tidak',
                  ),
                  if (laundry.deliveryAddress.isNotEmpty)
                    _DetailRow(
                      label: 'Alamat antar',
                      value: laundry.deliveryAddress,
                    ),
                  if (laundry.description.isNotEmpty)
                    _DetailRow(label: 'Catatan', value: laundry.description),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total Bayar',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        AppFormat.longPrice(laundry.total),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
