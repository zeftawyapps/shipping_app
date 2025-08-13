import 'package:flutter/material.dart';
import 'package:shipping_app/app-configs.dart';
import 'package:shipping_app/enums.dart';
import '../../../logic/data/sample_data.dart';
import '../../../logic/models/models.dart';
import '../../../logic/bloc/Auth_bloc.dart';
import 'package:JoDija_tamplites/util/widgits/data_source_bloc_widgets/data_source_bloc_listner.dart';
import 'driver_rally_point_screen.dart';
import 'dialog/change_password_dialog.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthBloc authBloc = AuthBloc();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showFirstTimePasswordDialog(Users driver) async {
    final result = await showDialog<Users?>(
      context: context,
      barrierDismissible: false, // Prevent dismissing for first-time users
      builder: (context) => DriverChangePasswordDialog(
        driver: driver,
        onPasswordChanged: () {
          // Mark driver as no longer first-time
          // This would typically update the user in the database
          // For now, we'll just navigate to the home screen
        },
      ),
    );

    if (result != null) {
      // Password was changed successfully, navigate to home with updated user
      _navigateToDriverHome(result);
    } else {
      // User cancelled or failed to change password, stay on login screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب تغيير كلمة المرور للمتابعة'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _navigateToDriverHome(Users driver) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DriverRallyPointScreen(driver: driver),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
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
            
            if (user != null && user.role == UserRole.driver) {
              // Check if this is first-time login
              if (user.isFirstTimeLogin) {
                _showFirstTimePasswordDialog(user);
              } else {
                // Navigate to driver rally point screen directly
                _navigateToDriverHome(user);
              }
            } else {
              // Show error message for non-driver users
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('هذا الحساب غير مخصص للسائقين'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          failure: (error, callback) {
            setState(() {
              _isLoading = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ في تسجيل الدخول: ${error.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // شعار التطبيق
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // عنوان التطبيق
                  Text(
                    'تطبيق السائق',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سجل دخولك لبدء استقبال الطلبات',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // حقل البريد الإلكتروني
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      hintText: 'example@domain.com',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      if (!value.contains('@')) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // حقل كلمة المرور
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      if (value.length < 6) {
                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // زر تسجيل الدخول
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'تسجيل الدخول',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // بيانات تجريبية للاختبار

                  AppConfigration.envType == EnvType.prototype ?

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بيانات تجريبية للاختبار:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'البريد الإلكتروني: mohamed.driver@example.com',
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                        Text(
                          'كلمة المرور: hashed_password_driver_1',
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ],
                    ),
                  ):Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      if (AppConfigration.envType == EnvType.prototype) {
        // في بيئة الاختبار، نستخدم بيانات تجريبية
        await _loginProtoType();
      } else {
        // في بيئة الإنتاج، نستخدم AuthBloc
        Map<String, dynamic> map = {
          authBloc.emailKey: _emailController.text.trim(),
          authBloc.passKey: _passwordController.text,
        };
        authBloc.signeIn(map: map);
      }
    }
  }
  Future<void> _loginProtoType() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // محاكاة تأخير الشبكة
      await Future.delayed(const Duration(seconds: 1));

      // في بيئة الاختبار، نستخدم بيانات تجريبية

      final user = SampleDataProvider.authenticateUser(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null && user.role == UserRole.driver) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DriverRallyPointScreen(driver: user),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('بيانات تسجيل الدخول غير صحيحة أو لست سائقاً'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

  }


}
