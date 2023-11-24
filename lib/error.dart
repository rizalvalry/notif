import 'package:flutter/material.dart';

class ErrorWidget extends StatelessWidget {
  const ErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Ganti halaman beranda menjadi HomeScreen
      home: Container(
        child: Center(
          child: Text('Oops'),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
