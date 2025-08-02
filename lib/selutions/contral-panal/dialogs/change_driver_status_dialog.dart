import 'package:flutter/material.dart';
import '../../../logic/models/models.dart';
import '../../../logic/provider/app_state_manager.dart';

class ChangeDriverStatusDialog extends StatefulWidget {
  final Driver driver;
  final Users user;
  final AppStateManager appState;

  const ChangeDriverStatusDialog({
    Key? key,
    required this.driver,
    required this.user,
    required this.appState,
  }) : super(key: key);

  @override
  State<ChangeDriverStatusDialog> createState() => _ChangeDriverStatusDialogState();

  static Future<void> show(
    BuildContext context,
    AppStateManager appState,
    Driver driver,
    Users user,
  ) {
    return showDialog(
      context: context,
      builder: (context) => ChangeDriverStatusDialog(
        driver: driver,
        user: user,
        appState: appState,
      ),
    );
  }
}

class _ChangeDriverStatusDialogState extends State<ChangeDriverStatusDialog> {
  late DriverStatus selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.driver.status;
  }

  String _getStatusDisplayName(DriverStatus status) {
    switch (status) {
      case DriverStatus.available:
        return 'متاح';
      case DriverStatus.busy:
        return 'مشغول';
      case DriverStatus.at_rally_point:
        return 'في نقطة التجمع';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تغيير حالة السائق: ${widget.user.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<DriverStatus>(
            value: selectedStatus,
            decoration: const InputDecoration(
              labelText: 'الحالة الجديدة',
              border: OutlineInputBorder(),
            ),
            items: DriverStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(_getStatusDisplayName(status)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedStatus = value;
                });
              }
            },
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
            widget.appState.updateDriverStatus(widget.driver.id !, selectedStatus);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث حالة السائق بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text('تحديث'),
        ),
      ],
    );
  }
}
