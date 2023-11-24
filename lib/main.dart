import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      title: 'e-WB Notifications',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Ganti halaman beranda menjadi HomeScreen
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tambahkan kode logika splash screen di sini
    // Contoh: Future.delayed dan Navigator untuk berpindah ke halaman berikutnya
    Future.delayed(
      const Duration(seconds: 2),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      },
    );

    return Scaffold(
      body: Container(
        child: Center(
          child: Image.asset(
            'assets/images/ic_launcher.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> devices = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fetchData();
    // Tambahkan listener untuk menangani notifikasi yang diterima
    OneSignal.shared.setNotificationOpenedHandler((openedResult) {
      fetchData();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    });
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse(
          'https://wartelsus.mitrakitajaya.com/edc/edclistmobile?_dc=1700711222726&datefilter=false&branchfilter=false&filter_BranchID=10&userid=28&userlvl=0&page=false&start=0&limit=1000'),
    );

    if (response.statusCode == 200) {
      // Parse JSON response
      final jsonResponse = json.decode(response.body);

      // Check if 'results' is present in the response and not null
      if (jsonResponse != null && jsonResponse.containsKey('results')) {
        final data =
            (jsonResponse['results'] as List?) ?? <Map<String, dynamic>>[];

        print('test $data');

        if (mounted) {
          setState(() {
            devices = data.cast<Map<String, dynamic>>();
          });
        }

        if (data.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak Ada Data'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak Ada Data'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> updateProperty(String imei) async {
    final response = await http.post(
      Uri.parse('https://wartelsus.mitrakitajaya.com/edc/updateProperti'),
      body: {
        'phoneimei': imei,
        'recordId': 'Approved',
        'value': '1',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['success'] == false) {
        print(jsonResponse);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message']),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print(jsonResponse);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Device Berhasil di Approved'),
            duration: Duration(seconds: 2),
          ),
        );

        // Me-reload data setelah menyetujui
        fetchData();
      }

      print('Property updated successfully.');
    } else {
      print('Failed to update property.');
    }
  }

  Future<void> _refresh() async {
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Permission List e-WB'),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            bool isDisabled = device['USERNAME'] == null ||
                device['BRANCHNAME'] == null ||
                device['SERVER_IP_ADDRESS'] == null ||
                device['APPROVED'] == 0;

            return Padding(
              padding: EdgeInsets.all(5),
              child: Card(
                child: InkWell(
                  onTap: isDisabled
                      ? null
                      : () {
                          updateProperty(device['IMEI']);
                          // Handle the radio button tap here
                        },
                  splashColor: Colors.blue, // Warna ketika disentuh
                  highlightColor: Colors.red, // Warna ketika ditekan
                  child: ListTile(
                    title: Text(device['USERNAME'] ?? 'No Username'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Branch Name: ${device['BRANCHNAME'] ?? 'No Branch'}'),
                        Text(
                            'Server IP: ${device['SERVER_IP_ADDRESS'] ?? 'No IP'}'),
                        Text('IMEI: ${device['IMEI'] ?? 'No Imei'}'),
                        Text('Notes: ${device['NOTES'] ?? 'No Notes'}'),
                      ],
                    ),
                    trailing: isDisabled
                        ? null
                        : ElevatedButton(
                            onPressed: () {
                              updateProperty(device['IMEI']);
                              // Handle the radio button tap here
                            },
                            child: Text('Approve'),
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildDataRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(value?.toString() ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}
