import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
                  leading: const Icon(Icons.build), // Додав іконку для краси
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Перехід на екран додавання та очікування результату
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPartPage()),
          ).then((value) {
            // Якщо ми повернулися і принесли текст - додаємо його до списку
            if (value != null && value.toString().trim().isNotEmpty) {
              setState(() {
                parts.add(value.toString());
              });
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// === НОВИЙ КЛАС ДЛЯ ЕКРАНА ДОДАВАННЯ ===
class AddPartPage extends StatefulWidget {
  const AddPartPage({super.key});

  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Додати запчастину')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Назва запчастини',
                border: OutlineInputBorder(), // Зробив поле вводу красивішим
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Повертаємо введений текст назад на головний екран
                Navigator.pop(context, _controller.text);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Широка кнопка
              ),
              child: const Text('Зберегти', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
