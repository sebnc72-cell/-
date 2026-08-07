import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: HomePage(), theme: ThemeData(brightness: Brightness.dark, useMaterial3: true)));
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
  void initState() { super.initState(); _refresh(); }

  void _refresh() async {
    final data = await DatabaseHelper.instance.fetchParts();
    // Сортуємо дані за маркою авто (brand)
    data.sort((a, b) => (a['brand'] ?? 'Універсальна').compareTo(b['brand'] ?? 'Універсальна'));
    setState(() {
      allParts = data;
      _applySearch();
    });
  }

  void _applySearch() {
    setState(() {
      filteredParts = allParts.where((p) =>
          p['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          p['article'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          p['brand'].toString().toLowerCase().contains(searchQuery.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Склад запчастин')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Пошук (назва, арт, марка)', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
              onChanged: (v) { searchQuery = v; _applySearch(); },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredParts.length,
              itemBuilder: (context, i) {
                final p = filteredParts[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Авто: ${p['brand']} ${p['carModel']}\nАрт: ${p['article']} | К-сть: ${p['quantity']}'),
                    onTap: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (c) => AddPartPage(part: p)));
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
        onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (c) => const AddPartPage())); _refresh(); },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// === КЛАС ДОДАВАННЯ (залишаємо без змін) ===
class AddPartPage extends StatefulWidget {
  final Map<String, dynamic>? part;
  const AddPartPage({super.key, this.part});
  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  final _name = TextEditingController();
  final _art = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _model = TextEditingController();
  String _brand = 'Універсальна';
  final List<String> _brands = ['Універсальна', 'Alfa Romeo', 'Audi', 'BMW', 'Case IH', 'Caterpillar', 'Chevrolet', 'Chrysler', 'Citroën', 'CLAAS', 'Dacia', 'DAF', 'Dodge', 'FAW', 'Fendt', 'Fiat', 'Ford', 'Foton', 'GAZ (ГАЗ)', 'GMC', 'Great Wall', 'Honda', 'Hyundai', 'Infiniti', 'Isuzu', 'IVECO', 'JCB', 'Jeep', 'John Deere', 'KAMAZ (КАМАЗ)', 'Kia', 'KRAZ (КрАЗ)', 'Lada / ВАЗ', 'Lancia', 'Land Rover', 'Lexus', 'MAN', 'MAZ (МАЗ)', 'Mazda', 'Mercedes-Benz', 'MINI', 'Mitsubishi', 'MTZ (МТЗ)', 'New Holland', 'Nissan', 'Opel', 'Peugeot', 'Porsche', 'Renault', 'Scania', 'SEAT', 'Skoda', 'Smart', 'SsangYong', 'Subaru', 'Suzuki', 'Tatra', 'Toyota', 'UMZ (ЮМЗ)', 'Volkswagen', 'Volvo', 'XTZ (ХТЗ)', 'YTO', 'ZAZ (ЗАЗ)'];

  @override
  void initState() {
    super.initState();
    if (widget.part != null) {
      _name.text = widget.part!['name'];
      _art.text = widget.part!['article'];
      _qty.text = widget.part!['quantity'].toString();
      _model.text = widget.part!['carModel'];
      _brand = widget.part!['brand'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.part == null ? 'Додати' : 'Редагувати')),
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
            Autocomplete<String>(
              optionsBuilder: (v) => v.text.isEmpty ? _brands : _brands.where((b) => b.toLowerCase().contains(v.text.toLowerCase())),
              onSelected: (s) => setState(() => _brand = s),
              fieldViewBuilder: (c, ctrl, fn, onS) {
                if (ctrl.text.isEmpty && _brand.isNotEmpty) ctrl.text = _brand;
                return TextField(controller: ctrl, focusNode: fn, decoration: const InputDecoration(labelText: 'Марка авто', border: OutlineInputBorder(), suffixIcon: Icon(Icons.search)), onChanged: (v) => _brand = v);
              },
            ),
            const SizedBox(height: 10),
            TextField(controller: _model, decoration: const InputDecoration(labelText: 'Модель', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final data = {'name': _name.text, 'article': _art.text, 'quantity': int.tryParse(_qty.text) ?? 1, 'brand': _brand, 'carModel': _model.text};
                if (widget.part == null) await DatabaseHelper.instance.insertPart(data);
                else { data['id'] = widget.part!['id']; await DatabaseHelper.instance.updatePart(data); }
                if (mounted) Navigator.pop(context, true);
              },
              child: const Text('Зберегти'),
            ),
            if (widget.part != null) ...[
              const SizedBox(height: 10),
              ElevatedButton(onPressed: () async { await DatabaseHelper.instance.deletePart(widget.part!['id']); if (mounted) Navigator.pop(context, true); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), child: const Text('Видалити')),
            ]
          ],
        ),
      ),
    );
  }
}
