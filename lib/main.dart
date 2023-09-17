import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  OneSignal.shared.setAppId("ddf01a2d-4995-4ae5-8e35-9221a73b40af");
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print("accept : $accepted");
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Ganti halaman beranda menjadi HomeScreen
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Tambahkan listener untuk menangani notifikasi yang diterima
    OneSignal.shared.setNotificationOpenedHandler((openedResult) {
      // Arahkan ke halaman ApprovalList saat notifikasi diklik
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApprovalList(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('List View'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Player ID:'),
          ],
        ),
      ),
    );
  }
}

class ApprovalList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Isi dengan daftar item yang ingin Anda tampilkan
    List<String> items = [
      'Item Perangkat Masuk 1',
      'Item Item Perangkat Masuk 2',
      'Item Item Perangkat Masuk 3',
      // Tambahkan item lain jika diperlukan
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Persetujuan'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            onTap: () {
              // Arahkan ke halaman DetailApproval saat item diklik
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailApproval(item: items[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailApproval extends StatelessWidget {
  final String item;

  DetailApproval({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Persetujuan'),
      ),
      body: Center(
        child: Text(item), // Tampilkan detail item di sini
      ),
    );
  }
}
