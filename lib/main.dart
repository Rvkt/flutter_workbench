import 'package:flutter/material.dart';
import 'features/native/screens/native_device_info.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workbench',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.black), useMaterial3: true),
      home: const NativeDeviceInfoScreen(title: 'Native Device & App Info'),
    );
  }
}
