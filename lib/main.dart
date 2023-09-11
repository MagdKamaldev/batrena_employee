import 'package:batrena_employee/form.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainWidget());
}
const SERVER_IP = "http://165.22.31.49:3006/api";
class MainWidget extends StatelessWidget {
  const MainWidget({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batrena Employee',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const FormScreen(),
    );
  }
}