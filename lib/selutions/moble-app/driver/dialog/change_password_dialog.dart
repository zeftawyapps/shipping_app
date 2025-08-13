import 'package:flutter/material.dart';
import 'package:shipping_app/logic/bloc/Auth_bloc.dart';
import 'package:shipping_app/logic/bloc/users_bloc.dart';
import 'package:shipping_app/logic/models/models.dart';
import 'package:JoDija_tamplites/util/widgits/data_source_bloc_widgets/data_source_bloc_listner.dart';

class DriverChangePasswordDialog extends StatefulWidget {
  final Users driver;
  final VoidCallback? onPasswordChanged;

  const DriverChangePasswordDialog({
    super.key,
    required this.driver,
    this.onPasswordChanged,
  });

  @override
  State<DriverChangePasswordDialog> createState() => _DriverChangePasswordDialogState();
}

class _DriverChangePasswordDialogState extends State<DriverChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  AuthBloc authBloc = AuthBloc();
  UsersBloc usersBloc = UsersBloc(); 
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Call the AuthBloc changePassword method
    authBloc.changePassword(
      user: widget.driver,
      oldpass: _currentPasswordController.text,
      newpass: _newPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.lock_reset, color: Colors.green),
          SizedBox(width: 8),
          Text('تغيير كلمة المرور - السائق'),
        ],
      ),
      content: DataSourceBlocListener<Users>(
        bloc: usersBloc.userBloc,
        loading: () {
          setState(() {
            _isLoading = true;
          });
        },
        success: (updatedUser) {
          setState(() {
            _isLoading = false;
          });
          
          if (mounted && updatedUser != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث بيانات السائق بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Call the callback if provided
            if (widget.onPasswordChanged != null) {
              widget.onPasswordChanged!();
            }
            
            // Return the updated user data and close the dialog
            Navigator.of(context).pop(updatedUser);
          }
        },
        failure: (error, callback) {
          setState(() {
            _isLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل في تحديث بيانات السائق: ${error.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: DataSourceBlocListener<Users>(
          bloc: authBloc.userBloc,
          loading: () {
            setState(() {
              _isLoading = true;
            });
          },
          success: (user) {
            setState(() {
              _isLoading = false;
            });
            
            if (mounted && user != null) {
              // Update the user's isFirstTimeLogin to false
              final updatedUser = user.copyWith(isFirstTimeLogin: false);
              
              // Update the user in the users bloc
              usersBloc.editUser(updatedUser);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تغيير كلمة المرور بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          failure: (error, callback) {
            setState(() {
              _isLoading = false;
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('فشل في تغيير كلمة المرور: ${error.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notice for first-time login (Driver specific)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.green[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'لأمان حسابك كسائق، يرجى تغيير كلمة المرور الافتراضية إلى كلمة مرور قوية وشخصية.',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Current password field
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrentPassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الحالية *',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrentPassword 
                              ? Icons.visibility 
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور الحالية';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // New password field
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الجديدة *',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword 
                              ? Icons.visibility 
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      helperText: 'يجب أن تحتوي على 8 أحرف على الأقل',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور الجديدة';
                      }
                      if (value.length < 8) {
                        return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                      }
                      if (value == _currentPasswordController.text) {
                        return 'كلمة المرور الجديدة يجب أن تكون مختلفة عن الحالية';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور الجديدة *',
                      prefixIcon: const Icon(Icons.lock_clock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword 
                              ? Icons.visibility 
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى تأكيد كلمة المرور الجديدة';
                      }
                      if (value != _newPasswordController.text) {
                        return 'كلمتا المرور غير متطابقتين';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password strength tips (Driver specific)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نصائح لكلمة مرور قوية للسائقين:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• استخدم 8 أحرف على الأقل\n'
                          '• امزج بين الأحرف الكبيرة والصغيرة\n'
                          '• أضف أرقام ورموز خاصة\n'
                          '• تجنب الكلمات الشائعة\n'
                          '• لا تشارك كلمة المرور مع أحد',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('تغيير كلمة المرور'),
        ),
      ],
    );
  }
}
