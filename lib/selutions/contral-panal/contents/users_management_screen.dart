import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../logic/models/models.dart';
import '../../../logic/provider/app_state_manager.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({Key? key}) : super(key: key);

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  UserRole? _selectedRole;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateManager>(
      builder: (context, appState, child) {
        final filteredUsers = appState.getFilteredUsers(
          role: _selectedRole,
          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        );

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط الأدوات
              Row(
                children: [
                  // زر إضافة مستخدم جديد
                  ElevatedButton.icon(
                    onPressed: () => _showAddUserDialog(context, appState),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة مستخدم'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // فلتر الأدوار
                  DropdownButton<UserRole?>(
                    value: _selectedRole,
                    hint: const Text('جميع الأدوار'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('جميع الأدوار'),
                      ),
                      ...UserRole.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(_getRoleDisplayName(role)),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                  ),
                  const SizedBox(width: 16),

                  // مربع البحث
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                            'البحث بالاسم أو البريد الإلكتروني أو رقم الهاتف...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // عداد النتائج
              Text(
                'عدد المستخدمين: ${filteredUsers.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              // جدول المستخدمين
              Expanded(
                child: Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('الاسم')),
                        DataColumn(label: Text('البريد الإلكتروني')),
                        DataColumn(label: Text('رقم الهاتف')),
                        DataColumn(label: Text('الدور')),
                        DataColumn(label: Text('الحالة')),
                        DataColumn(label: Text('تاريخ الإنشاء')),
                        DataColumn(label: Text('الإجراءات')),
                      ],
                      rows:
                          filteredUsers.map((user) {
                            return DataRow(
                              cells: [
                                DataCell(Text(user.name)),
                                DataCell(Text(user.email)),
                                DataCell(Text(user.phone)),
                                DataCell(Text(_getRoleDisplayName(user.role))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          user.isActive
                                              ? Colors.green.shade100
                                              : Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      user.isActive ? 'نشط' : 'غير نشط',
                                      style: TextStyle(
                                        color:
                                            user.isActive
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(_formatDate(user.createdAt))),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed:
                                            () => _showEditUserDialog(
                                              context,
                                              appState,
                                              user,
                                            ),
                                        tooltip: 'تعديل',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed:
                                            () => _showDeleteUserDialog(
                                              context,
                                              appState,
                                              user,
                                            ),
                                        tooltip: 'حذف',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddUserDialog(BuildContext context, AppStateManager appState) {
    _showUserDialog(context, appState, null);
  }

  void _showEditUserDialog(
    BuildContext context,
    AppStateManager appState,
    User user,
  ) {
    _showUserDialog(context, appState, user);
  }

  void _showUserDialog(
    BuildContext context,
    AppStateManager appState,
    User? user,
  ) {
    final isEditing = user != null;
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final passwordController = TextEditingController();
    UserRole selectedRole = user?.role ?? UserRole.driver;
    bool isActive = user?.isActive ?? true;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
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
                            labelText:
                                isEditing
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
                          items:
                              UserRole.values.map((role) {
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
                      onPressed: () {
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
                          id:
                              user?.id ??
                              'user_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          passwordHash:
                              passwordController.text.isNotEmpty
                                  ? 'hashed_${passwordController.text}'
                                  : user?.passwordHash ?? '',
                          role: selectedRole,
                          createdAt: user?.createdAt ?? DateTime.now(),
                          isActive: isActive,
                        );

                        if (isEditing) {
                          appState.updateUser(newUser);
                        } else {
                          appState.addUser(newUser);
                        }

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing
                                  ? 'تم تحديث المستخدم بنجاح'
                                  : 'تم إضافة المستخدم بنجاح',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Text(isEditing ? 'تحديث' : 'إضافة'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteUserDialog(
    BuildContext context,
    AppStateManager appState,
    User user,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                onPressed: () {
                  appState.deleteUser(user.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف المستخدم بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('حذف'),
              ),
            ],
          ),
    );
  }
}
