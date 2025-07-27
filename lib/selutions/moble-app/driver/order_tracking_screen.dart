import 'package:flutter/material.dart';
import '../../../logic/models/models.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;
  final Users driver;

  const OrderTrackingScreen({
    super.key,
    required this.order,
    required this.driver,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late Order currentOrder;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    currentOrder = widget.order;
  }

  Future<void> _updateOrderStatus(OrderStatus newStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // محاكاة تحديث الطلب
      setState(() {
        currentOrder = Order(
          id: currentOrder.id,
          shopId: currentOrder.shopId,
          driverId: currentOrder.driverId,
          senderDetails: currentOrder.senderDetails,
          recipientDetails: currentOrder.recipientDetails,
          items: currentOrder.items,
          totalOrderPrice: currentOrder.totalOrderPrice,
          status: newStatus,
          createdAt: currentOrder.createdAt,
          acceptedAt: newStatus == OrderStatus.accepted ? DateTime.now() : currentOrder.acceptedAt,
          pickedUpAt: newStatus == OrderStatus.picked_up ? DateTime.now() : currentOrder.pickedUpAt,
          deliveredAt: newStatus == OrderStatus.delivered ? DateTime.now() : currentOrder.deliveredAt,
          cancelledAt: currentOrder.cancelledAt,
          cancellationReason: currentOrder.cancellationReason,
        );
      });

      String message;
      switch (newStatus) {
        case OrderStatus.picked_up:
          message = 'تم تأكيد استلام الطلب من المحل';
          break;
        case OrderStatus.on_the_way:
          message = 'تم تأكيد أنك في الطريق للعميل';
          break;
        case OrderStatus.delivered:
          message = 'تم تأكيد توصيل الطلب بنجاح';
          break;
        default:
          message = 'تم تحديث حالة الطلب';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );

      if (newStatus == OrderStatus.delivered) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getOrderStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending_acceptance:
        return 'في انتظار القبول';
      case OrderStatus.accepted:
        return 'تم القبول';
      case OrderStatus.picked_up:
        return 'تم الاستلام';
      case OrderStatus.on_the_way:
        return 'في الطريق';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending_acceptance:
        return Colors.orange[600]!;
      case OrderStatus.accepted:
        return Colors.blue[600]!;
      case OrderStatus.picked_up:
        return Colors.indigo[600]!;
      case OrderStatus.on_the_way:
        return Colors.cyan[600]!;
      case OrderStatus.delivered:
        return Colors.green[600]!;
      case OrderStatus.cancelled:
        return Colors.red[600]!;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending_acceptance:
        return Icons.hourglass_empty;
      case OrderStatus.accepted:
        return Icons.check_circle;
      case OrderStatus.picked_up:
        return Icons.shopping_bag;
      case OrderStatus.on_the_way:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle_outline;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('تتبع الطلب #${currentOrder.id.substring(currentOrder.id.length.clamp(0, 3))}'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // حالة الطلب
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(currentOrder.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getStatusIcon(currentOrder.status), color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            _getOrderStatusDisplayName(currentOrder.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // تفاصيل الطلب
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تفاصيل الطلب',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text('من: ${currentOrder.senderDetails.name}'),
                      Text('هاتف المرسل: ${currentOrder.senderDetails.phone}'),
                      const SizedBox(height: 8),
                      Text('إلى: ${currentOrder.recipientDetails.name}'),
                      Text('هاتف المستلم: ${currentOrder.recipientDetails.phone}'),
                      const SizedBox(height: 16),
                      Text(
                        'إجمالي الطلب: ${currentOrder.totalOrderPrice.toStringAsFixed(2)} جنيه',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // أزرار التحكم
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    List<Widget> buttons = [];

    switch (currentOrder.status) {
      case OrderStatus.accepted:
        buttons.add(
          ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _updateOrderStatus(OrderStatus.picked_up),
            icon: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.shopping_bag),
            label: const Text('تأكيد الاستلام من المحل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        );
        break;

      case OrderStatus.picked_up:
        buttons.add(
          ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _updateOrderStatus(OrderStatus.on_the_way),
            icon: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.local_shipping),
            label: const Text('في الطريق للعميل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        );
        break;

      case OrderStatus.on_the_way:
        buttons.add(
          ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _updateOrderStatus(OrderStatus.delivered),
            icon: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.check_circle),
            label: const Text('تأكيد التوصيل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        );
        break;

      case OrderStatus.delivered:
        buttons.add(
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'تم توصيل الطلب بنجاح',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
        break;

      default:
        buttons.add(
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'لا توجد إجراءات متاحة في هذه الحالة',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        );
    }

    return Column(children: buttons);
  }
}
