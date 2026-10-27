import 'package:flutter/material.dart';
import 'package:frontend_dilaundry/config/app_error.dart';
import 'package:frontend_dilaundry/config/app_format.dart';
import 'package:frontend_dilaundry/config/app_response.dart';
import 'package:frontend_dilaundry/config/app_session.dart';
import 'package:frontend_dilaundry/config/failure.dart';
import 'package:frontend_dilaundry/config/nav.dart';
import 'package:frontend_dilaundry/datasources/laundry_datasource.dart';
import 'package:frontend_dilaundry/models/promo_model.dart';
import 'package:frontend_dilaundry/models/shop_model.dart';
import 'package:frontend_dilaundry/pages/my_orders_page.dart';
import 'package:intl/intl.dart';

class CreateOrderPage extends StatefulWidget {
  final ShopModel shop;
  final List<PromoModel> promos;
  const CreateOrderPage({super.key, required this.shop, required this.promos});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  int _packageIndex = 0;
  final _weightController = TextEditingController(text: '1');
  bool _withPickup = false;
  bool _withDelivery = false;
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  final _pickupAddressController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _withPickup = widget.shop.pickup;
    _withDelivery = widget.shop.delivery;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _pickupAddressController.dispose();
    _deliveryAddressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _weight {
    final normalized = _weightController.text.replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  double get _pricePerKg {
    if (_packageIndex == 0) return widget.shop.price;
    return widget.promos[_packageIndex - 1].newPrice;
  }

  double get _total => _pricePerKg * _weight;

  String? get _scheduleText {
    if (_pickupDate == null) return null;
    final dateText = DateFormat('d MMMM yyyy').format(_pickupDate!);
    if (_pickupTime == null) return dateText;
    final timeText =
        '${_pickupTime!.hour.toString().padLeft(2, '0')}.${_pickupTime!.minute.toString().padLeft(2, '0')}';
    return '$dateText pukul $timeText';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _pickupDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickupTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _pickupTime = picked);
  }

  Future<void> _submit() async {
    if (_weight <= 0) {
      setState(() => _errorText = 'Berat harus lebih dari 0 kg.');
      return;
    }
    if (_withPickup && _pickupAddressController.text.trim().isEmpty) {
      setState(
        () => _errorText = 'Alamat penjemputan wajib diisi bila memakai penjemputan.',
      );
      return;
    }
    if (_withDelivery && _deliveryAddressController.text.trim().isEmpty) {
      setState(
        () => _errorText = 'Alamat pengantaran wajib diisi bila memakai pengantaran.',
      );
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final notes = <String>[];
    if (_scheduleText != null) notes.add('Jadwal jemput: ${_scheduleText!}');
    if (_packageIndex > 0) {
      notes.add('Paket: ${widget.promos[_packageIndex - 1].description}');
    }
    final noteText = _noteController.text.trim();
    if (noteText.isNotEmpty) notes.add(noteText);

    try {
      final laundry = await LaundryDatasource.create(
        shopId: widget.shop.id,
        weight: _weight,
        withPickup: _withPickup,
        withDelivery: _withDelivery,
        pickupAddress: _pickupAddressController.text.trim(),
        deliveryAddress: _deliveryAddressController.text.trim(),
        total: _total,
        description: notes.join('. '),
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Pesanan Dibuat'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pesananmu sudah masuk antrean toko. Simpan kode klaim ini '
                  'untuk mengambil atau mengklaim pesanan.',
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    laundry.claimCode,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Lihat Pesanan Saya'),
              ),
            ],
          );
        },
      );
      if (!mounted) return;
      final user = await AppSession.getUser();
      if (!mounted) return;
      if (user == null) {
        Navigator.pop(context);
        return;
      }
      Nav.push(context, MyOrdersPage(user: user));
    } on InvalidInputFailure catch (failure) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppResponse.invalidInput(context, failure.message ?? '');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = appErrorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Pesanan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.shop.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          Text(
            '${widget.shop.location}, ${widget.shop.city}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pilih Paket',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          RadioGroup<int>(
            groupValue: _packageIndex,
            onChanged: (value) => setState(() => _packageIndex = value ?? 0),
            child: Column(
              children: [
                RadioListTile<int>(
                  value: 0,
                  title: const Text('Reguler'),
                  subtitle: Text(
                    '${AppFormat.longPrice(widget.shop.price)} per kg',
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                ...List.generate(widget.promos.length, (index) {
                  final promo = widget.promos[index];
                  return RadioListTile<int>(
                    value: index + 1,
                    title: Text(promo.description),
                    subtitle: Text(
                      '${AppFormat.longPrice(promo.newPrice)} per kg, harga '
                      'normal ${AppFormat.longPrice(promo.oldPrice)}',
                    ),
                    contentPadding: EdgeInsets.zero,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Berat Cucian',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  final next = (_weight - 0.5).clamp(0.5, 999).toDouble();
                  setState(
                    () => _weightController.text = _formatWeight(next),
                  );
                },
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    suffixText: 'kg',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              IconButton(
                onPressed: () {
                  final next = _weight + 0.5;
                  setState(
                    () => _weightController.text = _formatWeight(next),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _withPickup,
            onChanged: widget.shop.pickup
                ? (value) => setState(() => _withPickup = value)
                : null,
            title: const Text('Dijemput ke alamat saya'),
            subtitle: Text(
              widget.shop.pickup
                  ? 'Kurir toko akan menjemput cucian'
                  : 'Toko ini tidak menyediakan penjemputan',
            ),
            contentPadding: EdgeInsets.zero,
          ),
          if (_withPickup) ...[
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                _pickupDate == null
                    ? 'Pilih Tanggal Jemput'
                    : 'Tanggal jemput: ${DateFormat('d MMMM yyyy').format(_pickupDate!)}',
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(Icons.schedule_outlined),
              label: Text(
                _pickupTime == null
                    ? 'Pilih Jam Jemput'
                    : 'Jam jemput: ${_pickupTime!.format(context)}',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _pickupAddressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Alamat Penjemputan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SwitchListTile(
            value: _withDelivery,
            onChanged: widget.shop.delivery
                ? (value) => setState(() => _withDelivery = value)
                : null,
            title: const Text('Diantar setelah selesai'),
            subtitle: Text(
              widget.shop.delivery
                  ? 'Cucian diantar kembali ke alamatmu'
                  : 'Toko ini tidak menyediakan pengantaran',
            ),
            contentPadding: EdgeInsets.zero,
          ),
          if (_withDelivery) ...[
            TextField(
              controller: _deliveryAddressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Alamat Pengantaran',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
          ],
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Catatan Isi Cucian',
              hintText: 'Contoh: 2 kemeja, 3 celana, 1 selimut',
              border: OutlineInputBorder(),
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            color: Colors.green.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Expanded(child: Text('Perkiraan Total')),
                  Text(
                    AppFormat.longPrice(_total),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Kirim Pesanan'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Total akhir dapat berubah mengikuti timbangan sebenarnya di toko.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatWeight(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}
