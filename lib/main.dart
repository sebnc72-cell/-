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
                final p = parts[index];
                final String brand = p['brand'] ?? 'Універсальна';
                final String model = p['carModel'] ?? '';
                final bool isUniversal = brand == 'Універсальна';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Арт: ${p['article'] == "" ? "Не вказано" : p['article']}\nКількість: ${p['quantity']}\nАвто: $brand $model'.trim(),
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

// === КЛАС ДЛЯ ЕКРАНА ДОДАВАННЯ З ПОШУКОМ МАРКИ ===
class AddPartPage extends StatefulWidget {
  const AddPartPage({super.key});

  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _articleController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _modelController = TextEditingController();
  
  String _selectedBrand = 'Універсальна';

  // Повний алфавітний каталог марок (легкові, вантажні, сільгосптехніка)
  final List<String> _brands = [
    'Універсальна',
    'Alfa Romeo', 'Audi', 'BMW', 'Case IH', 'Caterpillar', 'Chevrolet', 'Chrysler',
    'Citroën', 'CLAAS', 'Dacia', 'DAF', 'Dodge', 'FAW', 'Fendt', 'Fiat', 'Ford',
    'Foton', 'GAZ (ГАЗ)', 'GMC', 'Great Wall', 'Honda', 'Hyundai', 'Infiniti',
    'Isuzu', 'IVECO', 'JCB', 'Jeep', 'John Deere', 'KAMAZ (КАМАЗ)', 'Kia',
    'KRAZ (КрАЗ)', 'Lada / ВАЗ', 'Lancia', 'Land Rover', 'Lexus', 'MAN',
    'MAZ (МАЗ)', 'Mazda', 'Mercedes-Benz', 'MINI', 'Mitsubishi', 'MTZ (МТЗ)',
    'New Holland', 'Nissan', 'Opel', 'Peugeot', 'Porsche', 'Renault', 'Scania',
    'SEAT', 'Skoda', 'Smart', 'SsangYong', 'Subaru', 'Suzuki', 'Tatra', 'Toyota',
    'UMZ (ЮМЗ)', 'Volkswagen', 'Volvo', 'XTZ (ХТЗ)', 'YTO', 'ZAZ (ЗАЗ)'
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

            // РОЗШИРЕНЕ ПОЛЕ ВВОДУ З ПОШУКОМ МАРКИ
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _selectedBrand),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return _brands;
                }
                return _brands.where((String brand) {
                  return brand.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                setState(() {
                  _selectedBrand = selection;
                });
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Марка авто / техніки (пошук)',
                    hintText: 'Почніть вводити (напр. Op, Mer, МТЗ)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    _selectedBrand = value;
                  },
                );
              },
            ),

            const SizedBox(height: 15),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Модель (наприклад, Zafira B, Sprinter 316, 82.1)',
                border: OutlineInputBorder(),
              ),
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
                  'brand': _selectedBrand.trim().isEmpty ? 'Універсальна' : _selectedBrand.trim(),
                  'carModel': _modelController.text.trim(),
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
