import 'package:flutter/material.dart';
import '../../../logic/models/models.dart';
import '../../../logic/provider/app_state_manager.dart';

class AddEditUserDialog extends StatefulWidget {
  final User? user;
  final AppStateManager appState;

  const AddEditUserDialog({
    Key? key,
    this.user,
    required this.appState,
  }) : super(key: key);

  @override
  State<AddEditUserDialog> createState() => _AddEditUserDialogState();

  static Future<void> show(
    BuildContext context,
    AppStateManager appState, {
    User? user,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AddEditUserDialog(
        user: user,
        appState: appState,
      ),
    );
  }
}

class _AddEditUserDialogState extends State<AddEditUserDialog> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController passwordController;
  late UserRole selectedRole;
  late bool isActive;

  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user?.name ?? '');
    emailController = TextEditingController(text: widget.user?.email ?? '');
    phoneController = TextEditingController(text: widget.user?.phone ?? '');
    passwordController = TextEditingController();
    selectedRole = widget.user?.role ?? UserRole.driver;
    isActive = widget.user?.isActive ?? true;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'مدير نظام';
      case UserRole.driver:
        return 'سائق';
      case UserRole.shop_owner:
        return 'صاحب محل';
    }
  }

  void _handleSubmit() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        (!isEditing && passwordController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newUser = User(
      id: widget.user?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      passwordHash: passwordController.text.isNotEmpty
          ? 'hashed_${passwordController.text}'
          : widget.user?.passwordHash ?? '',
      role: selectedRole,
      createdAt: widget.user?.createdAt ?? DateTime.now(),
      isActive: isActive,
    );

    if (isEditing) {
      widget.appState.updateUser(newUser);
    } else {
      widget.appState.addUser(newUser);
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing ? 'تم تحديث المستخدم بنجاح' : 'تم إضافة المستخدم بنجاح',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isEditing ? 'تعديل المستخدم' : 'إضافة مستخدم جديد',
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: isEditing
                    ? 'كلمة المرور الجديدة (اختياري)'
                    : 'كلمة المرور',
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              value: selectedRole,
              decoration: const InputDecoration(
                labelText: 'الدور',
                border: OutlineInputBorder(),
              ),
              items: UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(_getRoleDisplayName(role)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedRole = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('المستخدم نشط'),
              value: isActive,
              onChanged: (value) {
                setState(() {
                  isActive = value ?? true;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text(isEditing ? 'تحديث' : 'إضافة'),
        ),
      ],
    );
  }
}
