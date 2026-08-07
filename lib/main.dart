import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
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
  List<Map<String, dynamic>> parts = [];

  @override
  void initState() {
    super.initState();
    _refreshParts();
  }

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
                final part = parts[index];
                // Перевіряємо, чи стоїть позначка для авто (1 = так, 0 = ні)
                final bool isZafira = part['isForZafira'] == 1;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(part['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Артикул: ${part['article'] == "" ? "Не вказано" : part['article']}\nКількість: ${part['quantity']}',
                    ),
                    leading: Icon(
                      isZafira ? Icons.directions_car : Icons.build,
                      color: isZafira ? Colors.blue : Colors.grey,
                      size: 32,
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Очікуємо словник (Map) з даними
          final value = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPartPage()),
          );

          if (value != null && value is Map<String, dynamic>) {
            await DatabaseHelper.instance.insertPart(value);
            _refreshParts();
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _articleController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  bool _isForZafira = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Додати запчастину')),
      // Додали SingleChildScrollView, щоб клавіатура не перекривала поля
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Назва запчастини (обов\'язково)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _articleController,
              decoration: const InputDecoration(
                labelText: 'Артикул / Код',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Кількість',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              title: const Text('Підходить для Opel Zafira B'),
              value: _isForZafira,
              onChanged: (bool? value) {
                setState(() {
                  _isForZafira = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Перевірка, щоб назва не була порожньою
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Введіть назву запчастини!')),
                  );
                  return;
                }
                
                // Пакуємо всі дані в один словник
                final newPart = {
                  'name': _nameController.text.trim(),
                  'article': _articleController.text.trim(),
                  'quantity': int.tryParse(_quantityController.text.trim()) ?? 1,
                  'isForZafira': _isForZafira ? 1 : 0,
                };
                
                Navigator.pop(context, newPart);
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
