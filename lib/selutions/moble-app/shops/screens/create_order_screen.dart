import 'package:JoDija_tamplites/util/widgits/data_source_bloc_widgets/data_source_bloc_listner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shipping_app/logic/bloc/order_bloc.dart';
import '../../../../logic/models/models.dart';
import '../../../../widgets/location_picker_dialog.dart';

class CreateOrderScreen extends StatefulWidget {
  final Shop shop;

  const CreateOrderScreen({super.key, required this.shop});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _orderDetailsController = TextEditingController();
  final _orderPriceController = TextEditingController();
  
  // متغيرات الموقع (محاكاة)
  double? _selectedLatitude;
  double? _selectedLongitude;
  String _selectedLocationText = '';
  
  // قائمة العناصر
  List<OrderItemInput> _orderItems = [];
  
  bool _isLoading = false;
  OrdersBloc  bloc = OrdersBloc();

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _customerAddressController.dispose();
    _orderDetailsController.dispose();
    _orderPriceController.dispose();
    super.dispose();
  }

  void _addOrderItem() {
    setState(() {
      _orderItems.add(OrderItemInput());
    });
  }

  void _removeOrderItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
  }

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

  double _calculateTotalPrice() {
    double total = 0;
    for (var item in _orderItems) {
      if (item.quantity > 0 && item.unitPrice > 0) {
        total += item.quantity * item.unitPrice;
      }
    }
    return total;
  }

  void _createOrder() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLatitude == null || _selectedLongitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار موقع الاستلام'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_orderItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى إضافة عنصر واحد على الأقل للطلب'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // محاكاة تأخير الشبكة
      await Future.delayed(const Duration(seconds: 2));

      // إنشاء الطلب الجديد
      final newOrder = Order(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        shopId: widget.shop.shopId,
        senderDetails: ContactDetails(
          name: widget.shop.shopName!,
          phone: widget.shop.phone!,
          email: widget.shop.email,
          address: widget.shop.address,
          latitude: widget.shop.location!.latitude,
          longitude: widget.shop.location!.longitude,
        ),
        recipientDetails: ContactDetails(
          name: _customerNameController.text.trim(),
          phone: _customerPhoneController.text.trim(),
          email: _customerEmailController.text.trim().isEmpty
              ? null
              : _customerEmailController.text.trim(),
          address: _customerAddressController.text.trim(),
          latitude: _selectedLatitude!,
          longitude: _selectedLongitude!,
        ),
        items: _orderItems.map((item) => OrderItem(
          name: item.name,
          description: item.description,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          weight: item.weight,
        )).toList(),
        totalOrderPrice: _calculateTotalPrice(),
        status: OrderStatus.pending_acceptance,
        createdAt: DateTime.now(),
        acceptedAt: null,
        pickedUpAt: null,
        deliveredAt: null,
        cancelledAt: null,
        cancellationReason: null,
      );

      bloc.insertOrder(newOrder);
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _customerNameController.clear();
    _customerPhoneController.clear();
    _customerEmailController.clear();
    _customerAddressController.clear();
    _orderDetailsController.clear();
    _orderPriceController.clear();
    setState(() {
      _selectedLatitude = null;
      _selectedLongitude = null;
      _selectedLocationText = '';
      _orderItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DataSourceBlocListener(
        bloc: bloc.orderBloc,
        success:  (data ) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء الطلب بنجاح وإرساله للسائقين'),
              backgroundColor: Colors.green,
            ),
          );
          _resetForm();
        },
        failure: (error , c ) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات العميل
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'معلومات العميل المستلم',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _customerNameController,
                          decoration: const InputDecoration(
                            labelText: 'اسم العميل *',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال اسم العميل';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _customerPhoneController,
                          decoration: const InputDecoration(
                            labelText: 'رقم الهاتف *',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال رقم الهاتف';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _customerEmailController,
                          decoration: const InputDecoration(
                            labelText: 'البريد الإلكتروني (اختياري)',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty && !value.contains('@')) {
                              return 'يرجى إدخال بريد إلكتروني صحيح';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _customerAddressController,
                          decoration: const InputDecoration(
                            labelText: 'العنوان التفصيلي *',
                            prefixIcon: Icon(Icons.location_city),
                            border: OutlineInputBorder(),
                            hintText: 'مثال: الرياض، المملكة العربية السعودية - حي النخيل، شارع الملك فهد، مبنى رقم 123',
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال العنوان التفصيلي';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

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

                const SizedBox(height: 16),

                // عناصر الطلب
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'محتويات الطلب',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _addOrderItem,
                              icon: const Icon(Icons.add),
                              label: const Text('إضافة عنصر'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (_orderItems.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'لم يتم إضافة أي عناصر بعد',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _orderItems.length,
                            itemBuilder: (context, index) {
                              final item = _orderItems[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'العنصر ${index + 1}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () => _removeOrderItem(index),
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'اسم المنتج',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          item.name = value;
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              decoration: const InputDecoration(
                                                labelText: 'الكمية',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                              ],
                                              onChanged: (value) {
                                                item.quantity = int.tryParse(value) ?? 0;
                                                setState(() {}); // لإعادة حساب الإجمالي
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextFormField(
                                              decoration: const InputDecoration(
                                                labelText: 'السعر للوحدة',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                                              onChanged: (value) {
                                                item.unitPrice = double.tryParse(value) ?? 0;
                                                setState(() {}); // لإعادة حساب الإجمالي
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (item.quantity > 0 && item.unitPrice > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                'الإجمالي: ${(item.quantity * item.unitPrice).toStringAsFixed(2)} جنيه',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                        if (_orderItems.isNotEmpty) ...[
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'إجمالي الطلب: ${_calculateTotalPrice().toStringAsFixed(2)} جنيه',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // زر الحفظ والإرسال
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createOrder,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(_isLoading ? 'جاري الإرسال...' : 'حفظ وإرسال الطلب'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrderItemInput {
  String name = '';
  String description = '';
  int quantity = 0;
  double unitPrice = 0;
  double weight = 0.5;
}
