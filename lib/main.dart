import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Прибирає стрічку "DEBUG" у куті
      title: 'Облік запчастин',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Поки що це просто порожній список. Згодом ми підключимо сюди базу даних.
  List<String> parts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мої запчастини'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: parts.isEmpty
          ? const Center(
              child: Text(
                'Список порожній.\nДодайте першу деталь!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: parts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(parts[index]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Тут ми згодом додамо перехід на екран додавання нової деталі
          print("Натиснуто кнопку додавання");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
