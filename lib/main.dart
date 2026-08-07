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
        title: const Text('Склад запчастин'),
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
                final String carModel = part['carModel'] ?? 'Універсальна';
                final bool isUniversal = carModel == 'Універсальна';
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(part['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Артикул: ${part['article'] == "" ? "Не вказано" : part['article']}\nКількість: ${part['quantity']}\nАвто: $carModel',
                    ),
                    leading: Icon(
                      isUniversal ? Icons.build : Icons.directions_car,
                      color: isUniversal ? Colors.grey : Colors.blue,
                      size: 32,
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
  
  // Початкове значення для випадаючого списку
  String _selectedCar = 'Універсальна';

  // ТУТ МОЖНА ДОДАТИ ВСІ ВАШІ 30+ АВТОМОБІЛІВ
  final List<String> _carModels = [
    'Універсальна',
    'Opel Zafira B',
    'МТЗ',
    'Renault Trafic',
    'Volkswagen Transporter',
    'Mercedes Sprinter',
    // Просто дописуйте назви сюди через кому в одинарних лапках
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Додати запчастину')),
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
            const SizedBox(height: 15),
            
            // Новий віджет: Випадаючий список
            DropdownButtonFormField<String>(
              value: _selectedCar,
              decoration: const InputDecoration(
                labelText: 'Призначення (Авто)',
                border: OutlineInputBorder(),
              ),
              items: _carModels.map((String car) {
                return DropdownMenuItem<String>(
                  value: car,
                  child: Text(car),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCar = newValue!;
                });
              },
            ),

            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Введіть назву запчастини!')),
                  );
                  return;
                }
                
                final newPart = {
                  'name': _nameController.text.trim(),
                  'article': _articleController.text.trim(),
                  'quantity': int.tryParse(_quantityController.text.trim()) ?? 1,
                  'carModel': _selectedCar, // Зберігаємо обране авто
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
