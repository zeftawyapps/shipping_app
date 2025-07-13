import 'package:flutter/material.dart';
import '../../../logic/models/models.dart';

class ShopLocationDialog extends StatelessWidget {
  final Shop shop;

  const ShopLocationDialog({
    Key? key,
    required this.shop,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context,
    Shop shop,
  ) {
    return showDialog(
      context: context,
      builder: (context) => ShopLocationDialog(shop: shop),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('موقع المحل: ${shop.name}'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: Column(
          children: [
            Text('العنوان: ${shop.address}'),
            const SizedBox(height: 8),
            Text(
              'خط العرض: ${shop.location.latitude.toStringAsFixed(6)}',
            ),
            Text(
              'خط الطول: ${shop.location.longitude.toStringAsFixed(6)}',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'خريطة Google Maps\n(سيتم تفعيلها لاحقاً)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}
