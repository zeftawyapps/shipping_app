import 'package:JoDija_tamplites/util/widgits/data_source_bloc_widgets/data_source_bloc_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shipping_app/logic/bloc/users_bloc.dart';

import '../../../logic/models/models.dart';
import '../../../logic/provider/app_state_manager.dart';
import '../dialogs/add_edit_user_dialog.dart';
import '../dialogs/delete_user_dialog.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({Key? key}) : super(key: key);

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  UserRole? _selectedRole;
  String _searchQuery = '';
   late  UsersBloc bloc ;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {


    bloc = UsersBloc();
    bloc.loadUsers();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataSourceBlocBuilder(
loading: (){return   Center(
        child: CircularProgressIndicator(),
      );} ,
      bloc:  bloc.listUsersBloc ,
      failure: (c ,d ){return Center(
        child: Text(
          'حدث خطأ أثناء تحميل البيانات: $c',
          style: TextStyle(color: Colors.red),
        ),
      ) ; } ,

      success: (data ) {
        return Consumer<AppStateManager>(
          builder: (context, appState, child) {
            final filteredUsers = appState.getFilteredUsers(
              role: _selectedRole,
              searchQuery: _searchQuery.isEmpty ? null : _searchQuery, remoteUsers:  data
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
                        onPressed: () => AddEditUserDialog.show(context, appState)
                        .then((value) {

                           bloc.loadUsers() ;
                        })
                        ,
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
                                    DataCell(Text(_formatDate(user.createdAt!))),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed:
                                                () => AddEditUserDialog.show(
                                                  context,
                                                  appState,
                                                  user: user,
                                                ).then((value) {
                                                  bloc.loadUsers() ;
                                                }),
                                            tooltip: 'تعديل',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed:
                                                () => DeleteUserDialog.show(
                                                  context,
                                                  appState,
                                                  user,

                                                ).then((value) {
                                                  bloc.loadUsers() ;
                                                }),
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
}
