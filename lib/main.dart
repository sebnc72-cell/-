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
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
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
  void initState() { super.initState(); _refreshParts(); }
  void _refreshParts() async {
    final data = await DatabaseHelper.instance.fetchParts();
    setState(() { parts = data; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Склад запчастин'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: ListView.builder(
        itemCount: parts.length,
        itemBuilder: (context, index) {
          final p = parts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Арт: ${p['article']}\nКількість: ${p['quantity']}\nАвто: ${p['brand']} ${p['carModel']}'),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final value = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPartPage()));
          if (value != null) { await DatabaseHelper.instance.insertPart(value); _refreshParts(); }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddPartPage extends StatefulWidget {
  const AddPartPage({super.key});
  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  final _name = TextEditingController();
  final _art = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _model = TextEditingController();
  String _selectedBrand = 'Універсальна';
  
  final List<String> _brands = ['Універсальна', 'Opel', 'МТЗ', 'Renault', 'VW', 'Mercedes', 'John Deere'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Додати запчастину')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Назва', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _art, decoration: const InputDecoration(labelText: 'Артикул', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Кількість', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedBrand,
              decoration: const InputDecoration(labelText: 'Марка авто', border: OutlineInputBorder()),
              items: _brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (v) => setState(() => _selectedBrand = v!),
            ),
            const SizedBox(height: 10),
            TextField(controller: _model, decoration: const InputDecoration(labelText: 'Модель (опціонально)', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'name': _name.text, 'article': _art.text, 'quantity': int.tryParse(_qty.text) ?? 1,
                  'brand': _selectedBrand, 'carModel': _model.text
                });
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Зберегти'),
            ),
          ],
        ),
      ),
    );
  }
}
