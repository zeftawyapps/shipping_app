import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../logic/models/models.dart';

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
  final _orderDetailsController = TextEditingController();
  final _orderPriceController = TextEditingController();
  
  // متغيرات الموقع (محاكاة)
  double? _selectedLatitude;
  double? _selectedLongitude;
  String _selectedLocationText = '';
  
  // قائمة العناصر
  List<OrderItemInput> _orderItems = [];
  
  bool _isLoading = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
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
        return AlertDialog(
          title: const Text('اختيار الموقع'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('محاكاة اختيار الموقع من الخريطة'),
              const SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'خريطة Google Maps\n(محاكاة)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                // محاكاة اختيار موقع عشوائي
                setState(() {
                  _selectedLatitude = 30.7900 + (DateTime.now().millisecond % 100) / 10000;
                  _selectedLongitude = 31.0050 + (DateTime.now().millisecond % 100) / 10000;
                  _selectedLocationText = 'الموقع المحدد: ${_selectedLatitude!.toStringAsFixed(4)}, ${_selectedLongitude!.toStringAsFixed(4)}';
                });
                Navigator.of(context).pop();
              },
              child: const Text('تأكيد الموقع'),
            ),
          ],
        );
      },
    );
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
      /* 
      final newOrder = Order(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        shopId: widget.shop.id,
        driverId: null,
        senderDetails: ContactDetails(
          name: widget.shop.name,
          phone: widget.shop.phone,
          location: widget.shop.location,
        ),
        recipientDetails: ContactDetails(
          name: _customerNameController.text.trim(),
          phone: _customerPhoneController.text.trim(),
          email: _customerEmailController.text.trim().isEmpty 
              ? null 
              : _customerEmailController.text.trim(),
          location: Location(
            latitude: _selectedLatitude!,
            longitude: _selectedLongitude!,
          ),
        ),
        items: _orderItems.map((item) => OrderItem(
          productId: 'prod_${DateTime.now().millisecondsSinceEpoch}_${_orderItems.indexOf(item)}',
          name: item.name,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
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
      */

      // حفظ الطلب (هنا يجب استخدام قاعدة البيانات الحقيقية)
      // SampleDataProvider.addOrder(newOrder);
      
      setState(() {
        _isLoading = false;
      });

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الطلب بنجاح وإرساله للسائقين'),
          backgroundColor: Colors.green,
        ),
      );

      // إعادة تعيين النموذج
      _resetForm();
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _customerNameController.clear();
    _customerPhoneController.clear();
    _customerEmailController.clear();
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
      body: Form(
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
    );
  }
}

class OrderItemInput {
  String name = '';
  int quantity = 0;
  double unitPrice = 0;
}
