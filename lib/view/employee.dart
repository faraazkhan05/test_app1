import 'package:flutter/material.dart';
 import '../controller/database.dart';
import '../model/user_model.dart';
import 'package:get/get.dart';

class EmployeePage extends StatefulWidget {
  @override
  _EmployeePageState createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final controller = Get.put(DBHelper);

  late Future<List<Employee>> employees;

  String? _employeeName;
  String? _employeePhone;

  bool isUpdate = false;
  int? employeeIdForUpdate;
  DBHelper? dbHelper;

  final _employeeNameController = TextEditingController();
  final _employeePhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    refreshemployeeList();
  }

  refreshemployeeList() {
    setState(() {
      employees = dbHelper!.getEmployee();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite'),
        actions: <Widget>[
          TextButton(
            child: Text(
              (isUpdate ? 'UPDATE' : 'ADD'),
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () {
              if (isUpdate) {
                if (_formStateKey.currentState!.validate()) {
                  _formStateKey.currentState!.save();
                  dbHelper!
                      .Update(Employee(
                          employeeIdForUpdate, _employeeName, _employeePhone))
                      .then((data) {
                    setState(() {
                      isUpdate = false;
                    });
                  });
                }
              } else {
                if (_formStateKey.currentState!.validate()) {
                  _formStateKey.currentState!.save();
                  dbHelper!.add(Employee(0, _employeeName, _employeePhone));
                }
              }
              _employeeNameController.text = '';
              _employeePhoneController.text = '';
              refreshemployeeList();
            },
          ),
          TextButton(
            child: Text(
              (isUpdate ? 'CANCEL' : 'CLEAR'),
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () {
              _employeeNameController.text = '';
              _employeePhoneController.text = '';
              setState(() {
                isUpdate = false;
                employeeIdForUpdate = 0;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Form(
            autovalidateMode: AutovalidateMode.always,
            key: _formStateKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: TextFormField(
                    onSaved: (value) {
                      _employeeName = value!;
                    },
                    keyboardType: TextInputType.name,
                    controller: _employeeNameController,
                    decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2,
                                style: BorderStyle.solid)),
                        // hintText: "employee Name",
                        labelText: "Name",
                        fillColor: Colors.white,
                        labelStyle: TextStyle(
                          color: Colors.blue,
                        )),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: TextFormField(
                    onSaved: (value) {
                      _employeePhone = value!;
                    },
                    controller: _employeePhoneController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2,
                                style: BorderStyle.solid)),
                        // hintText: "employee Name",
                        labelText: "Phone",
                        fillColor: Colors.white,
                        labelStyle: TextStyle(
                          color: Colors.blue,
                        )),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 5.0,
          ),
          Expanded(
            child: FutureBuilder(
              future: employees,
              builder: (context, AsyncSnapshot<List<Employee>> snapshot) {
                if (snapshot.hasData) {
                  return generateList(snapshot.data);
                }
                if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Text('No Employee Found');
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView generateList(List<Employee>? employees) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text('Name'),
            ),
            DataColumn(
              label: Text('Phome'),
            ),
            DataColumn(
              label: Text(''),
            )
          ],
          rows: employees!
              .map(
                (employee) => DataRow(
                  cells: [
                    DataCell(
                      Text(employee.name!),
                      onTap: () {
                        setState(() {
                          isUpdate = true;
                          employeeIdForUpdate = employee.id;
                        });
                        _employeeNameController.text = employee.name!;
                        _employeePhoneController.text = employee.phone!;
                      },
                    ),
                    DataCell(
                      Text(employee.phone!),
                      onTap: () {
                        setState(() {
                          isUpdate = true;
                          employeeIdForUpdate = employee.id!;
                        });
                        _employeeNameController.text = employee.name!;
                        _employeePhoneController.text = employee.phone!;
                      },
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          dbHelper!.delete(employee.id!);
                          refreshemployeeList();
                        },
                      ),
                    )
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
