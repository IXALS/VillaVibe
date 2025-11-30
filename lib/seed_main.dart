import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:villavibe/core/data/seeding_service.dart';
import 'package:villavibe/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SeedApp());
}

class SeedApp extends StatelessWidget {
  const SeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Seeding Tool')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Click the button below to update Firestore data'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  print('Starting seed...');
                  final seeder = SeedingService();
                  await seeder.seedProperties();
                  print('Seeding complete!');
                },
                child: const Text('Seed Properties'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
