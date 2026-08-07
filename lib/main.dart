import 'package:flutter/material.dart';
import 'database_helper.dart';

// Повний словник марок та суворих моделей до них
final Map<String, List<String>> _modelsByBrand = {
  'Універсальна': ['Всі моделі', 'Різне'],
  'Alfa Romeo': ['147', '156', '159', 'Giulietta', 'Stelvio'],
  'Audi': ['A4', 'A6', 'Q5', 'Q7', '80', '100'],
  'BMW': ['E34', 'E36', 'E38', 'E39', 'E46', 'E60', 'X5'],
  'Case IH': ['Puma', 'Magnum', 'Maxxum', 'Optum'],
  'Caterpillar': ['320', '428', 'D6', 'Cat 950'],
  'Chevrolet': ['Aveo', 'Lacetti', 'Niva', 'Cruze'],
  'Citroën': ['Berlingo', 'Jumper', 'C4', 'Xsara'],
  'Dacia': ['Logan', 'Duster', 'Sandero'],
  'DAF': ['XF 95', 'XF 105', 'XF 106', 'CF'],
  'Fiat': ['Doblo', 'Ducato', 'Fiorino', 'Scudo', 'Punto'],
  'Ford': ['Transit', 'Focus', 'Mondeo', 'Fiesta', 'Connect'],
  'GAZ (ГАЗ)': ['3302 (Газель)', '53', '66', 'Волга'],
  'IVECO': ['Daily', 'Stralis', 'Eurocargo'],
  'JCB': ['3CX', '4CX', 'Fastrac'],
  'Jeep': ['Grand Cherokee', 'Cherokee', 'Renegade'],
  'John Deere': ['6000 series', '7000 series', '8000 series', '9000 series'],
  'KAMAZ (КАМАЗ)': ['5320', '65115', '5490'],
  'Kia': ['Ceed', 'Sportage', 'Sorento', 'Rio'],
  'KRAZ (КрАЗ)': ['255', '260', '6510'],
  'Lada / ВАЗ': ['2101-2107', '2108-21099', 'Priora', 'Kalina', 'Granta', 'Niva'],
  'Land Rover': ['Defender', 'Discovery', 'Range Rover'],
  'MAN': ['TGA', 'TGS', 'TGX', 'F2000'],
  'MAZ (МАЗ)': ['5440', '6430', '5551'],
  'Mazda': ['3', '6', 'Demio', 'Premacy', 'Bt-50'],
  'Mercedes-Benz': ['Sprinter', 'Vito', 'Viano', 'Atego', 'Actros', 'W124', 'W210', 'W202'],
  'Mitsubishi': ['L200', 'Pajero', 'Outlander', 'Colt'],
  'MTZ (МТЗ)': ['80', '82.1', '892', '1025', '1221', '1523'],
  'Nissan': ['Navara', 'Patrol', 'Qashqai', 'X-Trail', 'Primastar'],
  'Opel': ['Zafira A', 'Zafira B', 'Zafira C', 'Astra F', 'Astra G', 'Astra H', 'Vectra A', 'Vectra B', 'Vectra C', 'Insignia', 'Combo', 'Vivaro', 'Movano'],
  'Peugeot': ['Partner', 'Boxer', 'Expert', '308', '406'],
  'Renault': ['Kangoo', 'Master', 'Trafic', 'Megane', 'Logan', 'Scenic', 'Premium'],
  'Scania': ['R-series', 'G-series', 'P-series', 'Streamline'],
  'Skoda': ['Octavia', 'Fabia', 'Superb', 'Rapid'],
  'Toyota': ['Land Cruiser', 'Hilux', 'Corolla', 'Camry', 'Hiace'],
  'Volkswagen': ['Transporter T4', 'Transporter T5', 'Transporter T6', 'Caddy', 'Crafter', 'Golf', 'Passat', 'LT'],
  'Volvo': ['FH12', 'FH16', 'FM', 'XC60', 'XC90'],
  'ZAZ (ЗАЗ)': ['Sens', 'Slavuta', 'Tavria', 'Forza']
};

void main() {
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
    final rawData = await DatabaseHelper.instance.fetchParts();
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(rawData);
    data.sort((a, b) => (a['brand'] ?? 'Універсальна').toString().compareTo((b['brand'] ?? 'Універсальна').toString()));
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
      final q = searchQuery.toLowerCase().trim();
      filteredParts = allParts.where((p) =>
          (p['name'] ?? '').toString().toLowerCase().contains(q) ||
          (p['article'] ?? '').toString().toLowerCase().contains(q) ||
          (p['brand'] ?? '').toString().toLowerCase().contains(q) ||
          (p['carModel'] ?? '').toString().toLowerCase().contains(q)).toList();
    }
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
              decoration: const InputDecoration(labelText: 'Пошук (назва, арт, марка, модель)', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
              onChanged: (v) { setState(() { searchQuery = v; _applySearch(); }); },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredParts.length,
              itemBuilder: (context, i) {
                final p = filteredParts[i];
                final brand = p['brand'] ?? 'Універсальна';
                final isUni = brand == 'Універсальна';
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Icon(isUni ? Icons.build : Icons.directions_car, color: isUni ? Colors.grey : Colors.blueAccent),
                    title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Авто: $brand ${p['carModel']}\nАрт: ${p['article']} | К-сть: ${p['quantity']}'),
                    onTap: () async {
                      if (await Navigator.push(context, MaterialPageRoute(builder: (c) => AddPartPage(part: p))) == true) _refresh();
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
          if (await Navigator.push(context, MaterialPageRoute(builder: (c) => const AddPartPage())) == true) _refresh();
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
  final _name = TextEditingController();
  final _art = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.part != null) {
      _name.text = widget.part!['name'] ?? '';
      _art.text = widget.part!['article'] ?? '';
      _qty.text = (widget.part!['quantity'] ?? 1).toString();
      _brandCtrl.text = widget.part!['brand'] ?? 'Універсальна';
      _modelCtrl.text = widget.part!['carModel'] ?? '';
    } else {
      _brandCtrl.text = 'Універсальна';
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandsList = _modelsByBrand.keys.toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.part == null ? 'Додати запчастину' : 'Редагувати')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Назва запчастини', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _art, decoration: const InputDecoration(labelText: 'Артикул / Код', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Кількість', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            
            // Вибір марки
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _brandCtrl.text),
              optionsBuilder: (v) => v.text.isEmpty ? brandsList : brandsList.where((b) => b.toLowerCase().contains(v.text.toLowerCase())),
              onSelected: (s) {
                setState(() {
                  _brandCtrl.text = s;
                  // Очищаємо модель при зміні марки, щоб не плутати моделі різних авто
                  _modelCtrl.text = '';
                });
              },
              fieldViewBuilder: (c, ctrl, fn, onS) {
                if (ctrl.text.isEmpty && _brandCtrl.text.isNotEmpty) ctrl.text = _brandCtrl.text;
                return TextField(
                  controller: ctrl,
                  focusNode: fn,
                  decoration: const InputDecoration(labelText: 'Марка авто / техніки', border: OutlineInputBorder(), suffixIcon: Icon(Icons.search)),
                  onChanged: (v) => _brandCtrl.text = v,
                );
              },
            ),
            const SizedBox(height: 12),

            // Вибір моделі, суворо залежний від обраної марки
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _modelCtrl.text),
              optionsBuilder: (v) {
                final allowedModels = _modelsByBrand[_brandCtrl.text] ?? ['Загальна'];
                if (v.text.isEmpty) return allowedModels;
                return allowedModels.where((m) => m.toLowerCase().contains(v.text.toLowerCase()));
              },
              onSelected: (s) => _modelCtrl.text = s,
              fieldViewBuilder: (c, ctrl, fn, onS) {
                if (ctrl.text.isEmpty && _modelCtrl.text.isNotEmpty) ctrl.text = _modelCtrl.text;
                return TextField(
                  controller: ctrl,
                  focusNode: fn,
                  decoration: const InputDecoration(labelText: 'Модель (відповідно до марки)', border: OutlineInputBorder(), suffixIcon: Icon(Icons.search)),
                  onChanged: (v) => _modelCtrl.text = v,
                );
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_name.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введіть назву запчастини!')));
                  return;
                }
                final data = {
                  'name': _name.text.trim(),
                  'article': _art.text.trim(),
                  'quantity': int.tryParse(_qty.text.trim()) ?? 1,
                  'brand': _brandCtrl.text.trim().isEmpty ? 'Універсальна' : _brandCtrl.text.trim(),
                  'carModel': _modelCtrl.text.trim(),
                };
                if (widget.part == null) {
                  await DatabaseHelper.instance.insertPart(data);
                } else {
                  data['id'] = widget.part!['id'];
                  await DatabaseHelper.instance.updatePart(data);
                }
                if (mounted) Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Зберегти', style: TextStyle(fontSize: 16)),
            ),
            
            if (widget.part != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 50)),
                onPressed: () async {
                  // Підтвердження видалення
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Видалення'),
                      content: const Text('Ви дійсно хочете видалити цей запис зі складу?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Ні')),
                        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Так, видалити', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await DatabaseHelper.instance.deletePart(widget.part!['id']);
                    if (mounted) Navigator.pop(context, true);
                  }
                },
                child: const Text('Видалити', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
