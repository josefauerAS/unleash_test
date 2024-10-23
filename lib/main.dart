// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:unleash_proxy_client_flutter/unleash_proxy_client_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> toggles = [];
  String errorMessage = '';
  late UnleashClient unleash;

  @override
  void initState() {
    super.initState();
    unleash = UnleashClient(
      url: Uri.parse(
          'https://Use the frontend proxy api from the UI here /api/frontend'),
      clientKey: 'You can copy the client dev key from the UI into here',
      appName:
          'unleash_test_app', // This name can be anything you want, it will be displayed in the Unleash UI
      // This makes only sense for the Demo. It refreshes toggles every 10 seconds
      refreshInterval: 10,
    );

    void updateToggle(_) {
      final togglesUnleash = unleash.toggles;
      setState(() {
        toggles = togglesUnleash.keys.toList();
      });
    }

    unleash.on('ready', (_) {
      print('Unleash is ready');
      updateToggle('');
    });
    unleash.on('error', (error) {
      print(error);
      print('Unleash Error');
      setState(() {
        errorMessage = error.toString();
      });
    });
    unleash.on('update', (_) {
      print('Toggle updagted');
      updateToggle('');
    });
    unleash.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (errorMessage.isNotEmpty) Text(errorMessage),
            Column(
              children: _buildToggles(),
            )
          ],
        ),
      ),
    );
  }

  List<SwitchListTile> _buildToggles() {
    List<SwitchListTile> togglesList = [];
    // This shows inactive toggles
    // for (var toggleName in [
    //   'demo_flag',
    //   'additional_test_flag',
    //   'general_test_flag',
    //   'this_is_no_toggle',
    // ]) {

    // This removes inactive toggles
    for (var toggleName in toggles) {
      final value = unleash.isEnabled(toggleName);
      togglesList.add(SwitchListTile(
        value: value,
        onChanged: (_) {},
        title: Text(toggleName),
      ));
    }
    return togglesList;
  }
}
