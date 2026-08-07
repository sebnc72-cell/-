import 'package:flutter/material.dart';
import 'database_helper.dart';

// Розширений словник марок та суворих моделей
final Map<String, List<String>> _modelsByBrand = {
  'Універсальна': ['Всі моделі', 'Різне', 'Мастила та рідини', 'Розхідники'],
  'Alfa Romeo': ['147', '156', '159', 'Giulietta', 'Stelvio', 'MiTo'],
  'Audi': ['A3', 'A4', 'A5', 'A6', 'A8', 'Q3', 'Q5', 'Q7', '80', '100'],
  'BMW': ['E34', 'E36', 'E38', 'E39', 'E46', 'E60', 'E90', 'X3', 'X5', 'F10', 'G30'],
  'Case IH': ['Puma', 'Magnum', 'Maxxum', 'Optum', 'Steiger'],
  'Caterpillar': ['320', '428', 'D6', 'Cat 950', 'Cat 312'],
  'Chevrolet': ['Aveo', 'Lacetti', 'Niva', 'Cruze', 'Epica', 'Tacuma'],
  'Chrysler': ['Voyager', 'Grand Voyager', 'PT Cruiser', '300C'],
  'Citroën': ['Berlingo', 'Jumper', 'C4', 'Xsara', 'C-Elysee', 'C5'],
  'CLAAS': ['Lexion', 'Mega', 'Tucano', 'Axion', 'Arion'],
  'Dacia': ['Logan', 'Duster', 'Sandero', 'Dokker'],
  'DAF': ['XF 95', 'XF 105', 'XF 106', 'CF 85', 'LF'],
  'Dodge': ['Caliber', 'Journey', 'RAM', 'Nitro'],
  'Fiat': ['Doblo', 'Ducato', 'Fiorino', 'Scudo', 'Punto', 'Tipo', 'Bravo'],
  'Ford': ['Transit', 'Focus', 'Mondeo', 'Fiesta', 'Connect', 'Kuga', 'Fusion', 'Cargo'],
  'Foton': ['Auman', 'Ollin', 'View'],
  'GAZ (ГАЗ)': ['3302 (Газель)', '3221 (Соболь)', '53', '66', 'Волга 3110', 'Волга 31105'],
  'GMC': ['Sierra', 'Yukon', 'Acadia'],
  'Great Wall': ['Haval H3', 'Haval H5', 'Safe', 'Wingle'],
  'Honda': ['Civic', 'Accord', 'CR-V', 'HR-V', 'Jazz'],
  'Hyundai': ['Accent', 'Elantra', 'Sonata', 'Tucson', 'Santa Fe', 'H-1'],
  'Infiniti': ['FX35', 'FX45', 'EX35', 'QX56'],
  'Isuzu': ['D-Max', 'NPR', 'NQR', 'Trooper'],
  'IVECO': ['Daily', 'Stralis', 'Eurocargo', 'Trakker'],
  'JCB': ['3CX', '4CX', 'Fastrac', 'Teletruk'],
  'Jeep': ['Grand Cherokee', 'Cherokee', 'Renegade', 'Wrangler'],
  'John Deere': ['6000 series', '7000 series', '8000 series', '9000 series', 'S-Series'],
  'KAMAZ (КАМАЗ)': ['5320', '65115', '5490', '4310', '5511'],
  'Kia': ['Ceed', 'Sportage', 'Sorento', 'Rio', 'Cerato', 'Magentis'],
  'KRAZ (КрАЗ)': ['255', '260', '6510', '6322'],
  'Lada / ВАЗ': ['2101-2107', '2108-21099', 'Priora', 'Kalina', 'Granta', 'Niva 4x4', 'Vesta'],
  'Lancia': ['Delta', 'Thesis', 'Lybra'],
  'Land Rover': ['Defender', 'Discovery 3', 'Discovery 4', 'Range Rover', 'Freelander'],
  'Lexus': ['RX 330', 'RX 350', 'LX 470', 'LX 570', 'GS 300', 'IS 250'],
  'MAN': ['TGA', 'TGS', 'TGX', 'F2000', 'LE'],
  'MAZ (МАЗ)': ['5440', '6430', '5551', '4370 (Зубренок)'],
  'Mazda': ['3', '6', 'Demio', 'Premacy', 'BT-50', 'CX-5', 'CX-7'],
  'Mercedes-Benz': ['Sprinter', 'Vito', 'Viano', 'Atego', 'Actros', 'W124', 'W210', 'W202', 'W203', 'W211', 'W220', 'GL', 'ML'],
  'MINI': ['Cooper', 'Countryman', 'Clubman'],
  'Mitsubishi': ['L200', 'Pajero', 'Outlander', 'Colt', 'Lancer', 'Galant'],
  'MTZ (МТЗ)': ['80', '82.1', '892', '1025', '1221', '1523', '3022'],
  'New Holland': ['T7', 'T8', 'T9', 'CR', 'CX'],
  'Nissan': ['Navara', 'Patrol', 'Qashqai', 'X-Trail', 'Primastar', 'Interstar', 'Almera', 'Maxima'],
  'Opel': ['Zafira A', 'Zafira B', 'Zafira C', 'Astra F', 'Astra G', 'Astra H', 'Astra J', 'Vectra A', 'Vectra B', 'Vectra C', 'Insignia', 'Combo', 'Vivaro', 'Movano', 'Omega B'],
  'Peugeot': ['Partner', 'Boxer', 'Expert', '308', '406', '407', '207', '3008'],
  'Porsche': ['Cayenne', 'Panamera', 'Macan'],
  'Renault': ['Kangoo', 'Master', 'Trafic', 'Megane', 'Logan', 'Scenic', 'Premium', 'Magnum', 'Duster', 'Symbol'],
  'Scania': ['R-series', 'G-series', 'P-series', 'Streamline', 'Next Gen'],
  'SEAT': ['Leon', 'Ibiza', 'Altea', 'Toledo'],
  'Skoda': ['Octavia A5', 'Octavia A7', 'Fabia', 'Superb', 'Rapid', 'Yeti', 'Kodiaq'],
  'Smart': ['Fortwo', 'Forfour'],
  'SsangYong': ['Kyron', 'Actyon', 'Rexton', 'Korando'],
  'Subaru': ['Forester', 'Outback', 'Impreza', 'Legacy', 'Tribeca', 'XV'],
  'Suzuki': ['Grand Vitara', 'Vitara', 'SX4', 'Jimny', 'Swift'],
  'Tatra': ['815', '613'],
  'Toyota': ['Land Cruiser 100', 'Land Cruiser 200', 'Prado 120', 'Prado 150', 'Hilux', 'Corolla', 'Camry', 'Hiace', 'Avensis', 'RAV4'],
  'UMZ (ЮМЗ)': ['6', '6АК', '6КМ'],
  'Volkswagen': ['Transporter T4', 'Transporter T5', 'Transporter T6', 'Caddy', 'Crafter', 'Golf 4', 'Golf 5', 'Golf 7', 'Passat B5', 'Passat B6', 'Passat B7', 'LT', 'Touareg'],
  'Volvo': ['FH12', 'FH16', 'FM', 'XC60', 'XC90', 'S60', 'S80'],
  'XTZ (ХТЗ)': ['T-150K', 'T-150', 'XZ-1613'],
  'YTO': ['X704', 'X804', 'X904', '1304'],
  'ZAZ (ЗАЗ)': ['Sens', 'Slavuta', 'Tavria', 'Forza', 'Vida']
};

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const HomePage(),
    theme: ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueAccent,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
  ));
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
  final _nameCtrl = TextEditingController();
  final _art = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();

  List<String> _existingPartNames = [];

  @override
  void initState() {
    super.initState();
    _loadExistingPartNames();
    if (widget.part != null) {
      _nameCtrl.text = widget.part!['name'] ?? '';
      _art.text = widget.part!['article'] ?? '';
      _qty.text = (widget.part!['quantity'] ?? 1).toString();
      _brandCtrl.text = widget.part!['brand'] ?? 'Універсальна';
      _modelCtrl.text = widget.part!['carModel'] ?? '';
    } else {
      _brandCtrl.text = 'Універсальна';
    }
  }

  void _loadExistingPartNames() async {
    final parts = await DatabaseHelper.instance.fetchParts();
    final names = parts.map((p) => p['name'].toString()).toSet().toList();
    if (mounted) {
      setState(() {
        _existingPartNames = names;
      });
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
            // Автодоповнення назви на основі вже наявних на складі деталей
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _nameCtrl.text),
              optionsBuilder: (v) {
                if (v.text.isEmpty) return _existingPartNames;
                return _existingPartNames.where((n) => n.toLowerCase().contains(v.text.toLowerCase()));
              },
              onSelected: (s) => _nameCtrl.text = s,
              fieldViewBuilder: (c, ctrl, fn, onS) {
                if (ctrl.text.isEmpty && _nameCtrl.text.isNotEmpty) ctrl.text = _nameCtrl.text;
                return TextField(
                  controller: ctrl,
                  focusNode: fn,
                  decoration: const InputDecoration(
                    labelText: 'Назва запчастини (підказує існуючі)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.history),
                  ),
                  onChanged: (v) => _nameCtrl.text = v,
                );
              },
            ),
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

            // Вибір моделі
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
                if (_nameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введіть назву запчастини!')));
                  return;
                }
                final data = {
                  'name': _nameCtrl.text.trim(),
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
