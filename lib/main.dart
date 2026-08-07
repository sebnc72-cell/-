import 'package:flutter/material.dart';
import 'database_helper.dart'; // Підключаємо наш файл бази даних

void main() {
  // Гарантуємо, що Flutter готовий до роботи з системними каналами (потрібно для бази даних)
  WidgetsFlutterBinding.ensureInitialized();
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
  // Тепер це список мап (словників), оскільки база даних повертає дані саме у такому форматі
  List<Map<String, dynamic>> parts = [];

  @override
  void initState() {
    super.initState();
    _refreshParts(); // Завантажуємо збережені запчастини при запуску додатка
  }

  // Функція для отримання даних з бази та оновлення екрана
  void _refreshParts() async {
    final data = await DatabaseHelper.instance.fetchParts();
    setState(() {
      parts = data;
    });
  }

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
                  // Витягуємо назву деталі з бази за ключем 'name'
                  title: Text(parts[index]['name']),
                  leading: const Icon(Icons.build),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Перехід на екран додавання та очікування результату
          final value = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPartPage()),
          );

          // Якщо ми повернулися і принесли текст - зберігаємо його в БД і оновлюємо список
          if (value != null && value.toString().trim().isNotEmpty) {
            await DatabaseHelper.instance.insertPart(value.toString());
            _refreshParts(); // Оновлюємо екран, щоб побачити новий запис
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// === КЛАС ДЛЯ ЕКРАНА ДОДАВАННЯ ===
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
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Повертаємо введений текст назад на головний екран
                Navigator.pop(context, _controller.text);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Зберегти', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
