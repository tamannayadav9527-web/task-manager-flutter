import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ignore: non_constant_identifier_names
  final provider = TaskProvider();
  await provider.loadAllData(); //  LOAD SAVED TASKS + DRAFT

  runApp(
    ChangeNotifierProvider(
      create: (_) =>provider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}