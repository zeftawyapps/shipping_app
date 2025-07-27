import 'package:JoDija_tamplites/util/widgits/bloc_provider.dart';
import 'package:JoDija_tamplites/util/widgits/data_source_bloc_widgets/data_source_bloc_listner.dart';
import 'package:flutter/material.dart';
import 'package:shipping_app/logic/bloc/users_bloc.dart';
import '../../../logic/models/models.dart';
import '../../../logic/provider/app_state_manager.dart';

class AddEditUserDialog extends StatefulWidget {
  final Users? user;
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
    Users? user,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AddEditUserDialog(
        user: user,
        appState: appState,
      ),
    ) ;
  }
}

class _AddEditUserDialogState extends State<AddEditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String email;
  late String phone;
  String password = '';
  late UserRole selectedRole;
  late bool isActive;
  bool isLoading = false;

  bool get isEditing => widget.user != null;
  late UsersBloc bloc;

  @override
  void initState() {
    super.initState();
    name = widget.user?.name ?? '';
    email = widget.user?.email ?? '';
    phone = widget.user?.phone ?? '';
    selectedRole = widget.user?.role ?? UserRole.driver;
    isActive = widget.user?.isActive ?? true;
    bloc = UsersBloc();
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final newUser = Users(
      name: name,
      email: email,
      phone: phone,
      passwordHash: password.isNotEmpty
          ? '${password}'
          : widget.user?.passwordHash ?? '',
      role: selectedRole,
      createdAt: widget.user?.createdAt ?? DateTime.now(),
      isActive: isActive,
    );

    if (isEditing) {
     bloc. editUser(
        widget.user!.copyWith(
          name: newUser.name,
          email: newUser.email,
          phone: newUser.phone,
          passwordHash: newUser.passwordHash,
          role: newUser.role,
          isActive: newUser.isActive,
        ),
      );

      // widget.appState.addUser(newUser);
    } else {
      bloc.addUser(newUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isEditing ? 'تعديل المستخدم' : 'إضافة مستخدم جديد',
      ),
      content: SizedBox(
        width: 400,
        child: DataSourceBlocListener<Users>(
          bloc: bloc.userBloc,
          loading: () {
            setState(() {
              this.isLoading = true ;
            });
          },
          success: (data) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isEditing ? 'تم تحديث المستخدم بنجاح' : 'تم إضافة المستخدم بنجاح',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Future.delayed(Duration(milliseconds: 500));
            Navigator.of(context).pop();
          },
          failure: (error, dynamic Function() callback) {},
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(
                      labelText: 'الاسم',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال الاسم' : null,
                    onSaved: (value) => name = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: email,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }

                      final _emailRegExp = RegExp(
                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
                      );
                      // final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}');
                      if (!_emailRegExp.hasMatch(value)) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                    onSaved: (value) => email = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
                    onSaved: (value) => phone = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: isEditing ? 'كلمة المرور الجديدة (اختياري)' : 'كلمة المرور',
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) => !isEditing && (value == null || value.isEmpty)
                        ? 'يرجى إدخال كلمة المرور'
                        : null,
                    onSaved: (value) => password = value ?? '',
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
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child:
          isLoading ? const CircularProgressIndicator() :
          Text(isEditing ? 'تحديث' : 'إضافة'),
        ),
      ],
    );
  }
}
