import 'package:flutter/material.dart';
import 'package:frontend_dilaundry/models/user_model.dart';
import 'package:frontend_dilaundry/pages/claim_page.dart';
import 'package:frontend_dilaundry/pages/home_page.dart';
import 'package:frontend_dilaundry/pages/my_orders_page.dart';
import 'package:frontend_dilaundry/pages/profile_page.dart';

class DashboardPage extends StatefulWidget {
  final UserModel user;
  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _index = 0;
  final _ordersKey = GlobalKey<MyOrdersPageState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(user: widget.user),
          MyOrdersPage(key: _ordersKey, user: widget.user),
          ClaimPage(user: widget.user),
          ProfilePage(user: widget.user),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() => _index = value);
          if (value == 1) _ordersKey.currentState?.reload();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_2_outlined),
            activeIcon: Icon(Icons.qr_code_2),
            label: 'Klaim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
