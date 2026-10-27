import 'package:flutter/material.dart';
import 'package:frontend_dilaundry/config/app_constants.dart';
import 'package:frontend_dilaundry/config/app_error.dart';
import 'package:frontend_dilaundry/config/nav.dart';
import 'package:frontend_dilaundry/datasources/laundry_datasource.dart';
import 'package:frontend_dilaundry/models/laundry_model.dart';
import 'package:frontend_dilaundry/models/user_model.dart';
import 'package:frontend_dilaundry/pages/order_detail_page.dart';
import 'package:frontend_dilaundry/widgets/empty_state.dart';
import 'package:frontend_dilaundry/widgets/laundry_card.dart';

class MyOrdersPage extends StatefulWidget {
  final UserModel user;
  const MyOrdersPage({super.key, required this.user});

  @override
  State<MyOrdersPage> createState() => MyOrdersPageState();
}

class MyOrdersPageState extends State<MyOrdersPage> {
  late Future<List<LaundryModel>> _ordersFuture;
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _ordersFuture = LaundryDatasource.readByUser(widget.user.id);
  }

  void reload() {
    setState(() {
      _ordersFuture = LaundryDatasource.readByUser(widget.user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        actions: [
          IconButton(
            onPressed: reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: AppConstants.laundryStatusCategory.length,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final status = AppConstants.laundryStatusCategory[index];
                final selected = status == _statusFilter;
                return ChoiceChip(
                  label: Text(status),
                  selected: selected,
                  onSelected: (_) => setState(() => _statusFilter = status),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                reload();
                await _ordersFuture;
              },
              child: FutureBuilder<List<LaundryModel>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return ListView(
                      children: [
                        const SizedBox(height: 80),
                        EmptyState(message: appErrorMessage(snapshot.error!)),
                      ],
                    );
                  }
                  final orders = snapshot.data ?? [];
                  final filtered = _statusFilter == 'All'
                      ? orders
                      : orders
                            .where((order) => order.status == _statusFilter)
                            .toList();
                  if (filtered.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 80),
                        EmptyState(
                          message: orders.isEmpty
                              ? 'Belum ada pesanan. Pesan laundry pertamamu dari beranda.'
                              : 'Tidak ada pesanan berstatus $_statusFilter.',
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      return LaundryCard(
                        laundry: order,
                        onTap: () {
                          Nav.push(
                            context,
                            OrderDetailPage(laundry: order),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
