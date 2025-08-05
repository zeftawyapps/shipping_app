import 'package:JoDija_tamplites/util/widgits/data_source_bloc_widgets/data_source_bloc_listner.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shipping_app/logic/bloc/shopes_bloc.dart';
import '../../../../logic/models/models.dart';
import '../../../../widgets/location_picker_dialog.dart';

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


// متغيرات الموقع (محاكاة)
double? _selectedLatitude;
double? _selectedLongitude;
String _selectedLocationText = '';


void _selectLocation() {
  // محاكاة اختيار الموقع من الخريطة
  showDialog(
    context: context,
    builder: (BuildContext context) {

      return LocationPickerDialog(
        title: 'اختيار الموقع',


      );
    },
  ).then((value) {
    if (value != null && value is LatLng) {
      setState(() {
        _selectedLatitude = value.latitude;
        _selectedLongitude = value.longitude;
        _selectedLocationText =
        'الموقع المحدد: ${_selectedLatitude!.toStringAsFixed(
            4)}, ${_selectedLongitude!.toStringAsFixed(4)}';
      });
    }

  });
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
      if (_selectedLatitude == null || _selectedLongitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار الموقع على الخريطة')),
        );
        _selectLocation();
        return;
      }



      final updatedShop = Shop(
        shopId: widget.shop.shopId,
        shopName: _shopNameController.text.trim(),
        userName: _userNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        location: Location(
                latitude:  _selectedLatitude! ,
                longitude:  _selectedLongitude!,
              )
            ,
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


                  // موقع الاستلام
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'موقع الاستلام',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          InkWell(
                            onTap: _selectLocation,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedLocationText.isEmpty
                                          ? 'اضغط لاختيار الموقع على الخريطة'
                                          : _selectedLocationText,
                                      style: TextStyle(
                                        color: _selectedLocationText.isEmpty
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


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
