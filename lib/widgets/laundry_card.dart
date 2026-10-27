import 'package:flutter/material.dart';
import 'package:frontend_dilaundry/config/app_format.dart';
import 'package:frontend_dilaundry/models/laundry_model.dart';
import 'package:frontend_dilaundry/widgets/status_chip.dart';

class LaundryCard extends StatelessWidget {
  final LaundryModel laundry;
  final VoidCallback? onTap;
  const LaundryCard({super.key, required this.laundry, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      laundry.shop.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusChip(status: laundry.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                AppFormat.fullDate(laundry.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.scale_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text('${laundry.weight} kg'),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.code,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(laundry.claimCode),
                  const Spacer(),
                  Text(
                    AppFormat.longPrice(laundry.total),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
