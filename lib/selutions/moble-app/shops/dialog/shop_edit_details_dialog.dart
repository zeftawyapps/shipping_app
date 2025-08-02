import 'package:JoDija_tamplites/util/widgits/data_source_bloc_widgets/data_source_bloc_listner.dart';
import 'package:flutter/material.dart';
import 'package:shipping_app/logic/bloc/shopes_bloc.dart';
import '../../../../logic/models/models.dart';

class ShopProfileDialog extends StatefulWidget {
  final Shop shop;

  const ShopProfileDialog({
    Key? key,
    required this.shop,
  }) : super(key: key);

  static Future<Shop?> show(
    BuildContext context,
    Shop shop,
  ) {
    return showDialog<Shop>(
      context: context,
      builder: (context) => ShopProfileDialog(
        shop: shop,
      ),
    );
  }

  @override
  State<ShopProfileDialog> createState() => _ShopProfileDialogState();
}

class _ShopProfileDialogState extends State<ShopProfileDialog> {
late   ShopesBloc shopesBloc  ;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameController;
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    shopesBloc = ShopesBloc();
    _shopNameController = TextEditingController(text: widget.shop.shopName ?? '');
    _userNameController = TextEditingController(text: widget.shop.userName);
    _emailController = TextEditingController(text: widget.shop.email);
    _phoneController = TextEditingController(text: widget.shop.phone ?? '');
    _addressController = TextEditingController(text: widget.shop.address ?? '');
    _latitudeController = TextEditingController(
      text: widget.shop.location?.latitude.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.shop.location?.longitude.toString() ?? '',
    );
    _isActive = widget.shop.isActive;
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedShop = Shop(
        shopId: widget.shop.shopId,
        shopName: _shopNameController.text.trim(),
        userName: _userNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        // location: (_latitudeController.text.isNotEmpty && _longitudeController.text.isNotEmpty)
        //     ? Location(
        //         latitude: double.tryParse(_latitudeController.text) ?? 0.0,
        //         longitude: double.tryParse(_longitudeController.text) ?? 0.0,
        //       )
        //     : null,
        createdAt: widget.shop.createdAt,
        isActive: _isActive,
      );
    shopesBloc.editShops(updatedShop) ;   
      // Navigator.of(context).pop(updatedShop);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Align(
        alignment: Alignment.center,
        child: const Text('تعديل بيانات المحل' , style:TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ) ,),
      ),
      content: SizedBox(
        width: 550,
        child: DataSourceBlocListener(
          bloc: shopesBloc.shopesBloc,
          success: (data) {
            if (data is Shop) {

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم حفظ التغييرات بنجاح')),
              );
              Navigator.of(context).pop(data);
            }
          },
          failure: (error , callback) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطأ: ${error.message}')),
            );
          } ,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Shop Name Field
                  TextFormField(
                    controller: _shopNameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المحل',
                      labelStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال اسم المحل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // User Name Field
                  TextFormField(
                    controller: _userNameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المالك',
                      labelStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال اسم المالك';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      labelStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      if (!value.contains('@')) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف (اختياري)',
                      labelStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Address Field
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان (اختياري)',
                      labelStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Location Fields
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: TextFormField(
                  //         controller: _latitudeController,
                  //         decoration: const InputDecoration(
                  //           labelText: 'خط العرض (اختياري)',
                  //           border: OutlineInputBorder(),
                  //         ),
                  //         keyboardType: TextInputType.numberWithOptions(decimal: true),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 16),
                  //     Expanded(
                  //       child: TextFormField(
                  //         controller: _longitudeController,
                  //         decoration: const InputDecoration(
                  //           labelText: 'خط الطول (اختياري)',
                  //           border: OutlineInputBorder(),
                  //         ),
                  //         keyboardType: TextInputType.numberWithOptions(decimal: true),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 16),

                  // Active Status Switch
                  Row(
                    children: [
                      const Text('حالة المحل: '),
                      const Spacer(),
                      Text(_isActive ? 'نشط' : 'غير نشط'),
                      Switch(
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
          ),
          child: const Text('حفظ التغييرات'),
        ),
      ],
    );
  }
}
