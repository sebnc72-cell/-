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
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
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
  List<Map<String, dynamic>> allParts = [];
  List<Map<String, dynamic>> filteredParts = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() async {
    final rawData = await DatabaseHelper.instance.fetchParts();
    // Безпечна копія списку для уникнення помилок сортування
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(rawData);
    
    // Сортування за маркою
    data.sort((a, b) {
      final brandA = (a['brand'] ?? 'Універсальна').toString();
      final brandB = (b['brand'] ?? 'Універсальна').toString();
      return brandA.compareTo(brandB);
    });

    if (mounted) {
      setState(() {
        allParts = data;
        _applySearch();
      });
    }
  }

  void _applySearch() {
    if (searchQuery.trim().isEmpty) {
      filteredParts = List.from(allParts);
    } else {
      final query = searchQuery.toLowerCase().trim();
      filteredParts = allParts.where((p) {
        final name = (p['name'] ?? '').toString().toLowerCase();
        final article = (p['article'] ?? '').toString().toLowerCase();
        final brand = (p['brand'] ?? '').toString().toLowerCase();
        final model = (p['carModel'] ?? '').toString().toLowerCase();
        return name.contains(query) ||
            article.contains(query) ||
            brand.contains(query) ||
            model.contains(query);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Склад запчастин'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Пошук (назва, арт, марка, модель)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                setState(() {
                  searchQuery = v;
                  _applySearch();
                });
              },
            ),
          ),
          Expanded(
            child: filteredParts.isEmpty
                ? const Center(
                    child: Text(
                      'Нічого не знайдено',
                      style: TextStyle(color: Colors.white60, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredParts.length,
                    itemBuilder: (context, i) {
                      final p = filteredParts[i];
                      final brand = (p['brand'] ?? 'Універсальна').toString();
                      final carModel = (p['carModel'] ?? '').toString();
                      final bool isUniversal = brand == 'Універсальна' || brand.isEmpty;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: Icon(
                            isUniversal ? Icons.build : Icons.directions_car,
                            color: isUniversal ? Colors.grey : Colors.blueAccent,
                            size: 32,
                          ),
                          title: Text(
                            (p['name'] ?? '').toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Авто: ${brand.isEmpty ? 'Універсальна' : brand} $carModel\nАрт: ${p['article'] ?? '—'} | К-сть: ${p['quantity'] ?? 0}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (c) => AddPartPage(part: p)),
                            );
                            if (result == true) _refresh();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const AddPartPage()),
          );
          if (result == true) _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddPartPage extends StatefulWidget {
  final Map<String, dynamic>? part;
  const AddPartPage({super.key, this.part});

  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  final _nameController = TextEditingController();
  final _articleController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _modelController = TextEditingController();
  final _brandController = TextEditingController();

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
  void initState() {
    super.initState();
    if (widget.part != null) {
      _nameController.text = (widget.part!['name'] ?? '').toString();
      _articleController.text = (widget.part!['article'] ?? '').toString();
      _quantityController.text = (widget.part!['quantity'] ?? 1).toString();
      _modelController.text = (widget.part!['carModel'] ?? '').toString();
      _brandController.text = (widget.part!['brand'] ?? 'Універсальна').toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _articleController.dispose();
    _quantityController.dispose();
    _modelController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.part == null ? 'Додати запчастину' : 'Редагувати запчастину'),
      ),
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
            const SizedBox(height: 12),
            TextField(
              controller: _articleController,
              decoration: const InputDecoration(
                labelText: 'Артикул / Код',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Кількість',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Чистий та надійний Autocomplete
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _brandController.text),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return _brands;
                }
                return _brands.where((String brand) {
                  return brand.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                _brandController.text = selection;
              },
              fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Марка авто / техніки',
                    hintText: 'Введіть марку або виберіть зі списку',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) {
                    _brandController.text = val;
                  },
                );
              },
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Модель (наприклад, Zafira B, Sprinter 316)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Введіть назву запчастини!')),
                  );
                  return;
                }

                final brandText = _brandController.text.trim();
                final data = <String, dynamic>{
                  'name': _nameController.text.trim(),
                  'article': _articleController.text.trim(),
                  'quantity': int.tryParse(_quantityController.text.trim()) ?? 1,
                  'brand': brandText.isEmpty ? 'Універсальна' : brandText,
                  'carModel': _modelController.text.trim(),
                };

                if (widget.part == null) {
                  await DatabaseHelper.instance.insertPart(data);
                } else {
                  data['id'] = widget.part!['id'];
                  await DatabaseHelper.instance.updatePart(data);
                }

                if (mounted) Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(widget.part == null ? 'Зберегти' : 'Оновити', style: const TextStyle(fontSize: 16)),
            ),
            if (widget.part != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await DatabaseHelper.instance.deletePart(widget.part!['id']);
                  if (mounted) Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Видалити', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
