import 'package:flutter/material.dart';
import '../../../logic/models/models.dart';
import '../../../logic/provider/app_state_manager.dart';

class DeleteUserDialog extends StatelessWidget {
  final User user;
  final AppStateManager appState;

  const DeleteUserDialog({
    Key? key,
    required this.user,
    required this.appState,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context,
    AppStateManager appState,
    User user,
  ) {
    return showDialog(
      context: context,
      builder: (context) => DeleteUserDialog(
        user: user,
        appState: appState,
      ),
    );
  }

  void _handleDelete(BuildContext context) {
    appState.deleteUser(user.id);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف المستخدم بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تأكيد الحذف'),
      content: Text(
        'هل أنت متأكد من رغبتك في حذف المستخدم "${user.name}"؟',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => _handleDelete(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('حذف'),
        ),
      ],
    );
  }
}
