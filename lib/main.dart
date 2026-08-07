import 'package:flutter/material.dart';
import 'database_helper.dart';

// Словник моделей (додайте сюди ваші моделі за потреби)
final Map<String, List<String>> _modelsByBrand = {
  'Opel': ['Zafira A', 'Zafira B', 'Zafira C', 'Astra', 'Vectra', 'Insignia', 'Combo'],
  'Mercedes-Benz': ['Sprinter', 'Vito', 'Viano', 'Actros', 'Atego', 'C-Class', 'E-Class'],
  'MTZ (МТЗ)': ['80', '82.1', '892', '1025', '1221'],
  'Renault': ['Kangoo', 'Master', 'Traffic', 'Megane', 'Logan'],
  'Volkswagen': ['Transporter', 'Caddy', 'Golf', 'Passat', 'Crafter'],
  'John Deere': ['6R', '7R', '8R', '9R', 'S700'],
  // Можна легко розширити будь-яку марку
};

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: HomePage(), theme: ThemeData(brightness: Brightness.dark, useMaterial3: true)));
}

// --- HOME PAGE (Залишається без змін) ---
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
    setState(() { allParts = data; _applySearch(); });
  }

  void _applySearch() {
    filteredParts = allParts.where((p) => 
      p['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
      p['brand'].toString().toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
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
              decoration: const InputDecoration(labelText: 'Пошук', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
              onChanged: (v) { setState(() { searchQuery = v; _applySearch(); }); },
            ),
          ),
          Expanded(child: ListView.builder(
            itemCount: filteredParts.length,
            itemBuilder: (context, i) {
              final p = filteredParts[i];
              return Card(child: ListTile(
                title: Text(p['name']),
                subtitle: Text('Авто: ${p['brand']} ${p['carModel']} | К-сть: ${p['quantity']}'),
                onTap: () async { if (await Navigator.push(context, MaterialPageRoute(builder: (c) => AddPartPage(part: p))) == true) _refresh(); }
              ));
            }
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async { if (await Navigator.push(context, MaterialPageRoute(builder: (c) => const AddPartPage())) == true) _refresh(); }, child: const Icon(Icons.add)),
    );
  }
}

// --- ADD/EDIT PAGE (З ОНОВЛЕНИМ ПОШУКОМ МОДЕЛЕЙ) ---
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
      _name.text = widget.part!['name'];
      _art.text = widget.part!['article'];
      _qty.text = widget.part!['quantity'].toString();
      _brandCtrl.text = widget.part!['brand'];
      _modelCtrl.text = widget.part!['carModel'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редагування')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Назва', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        // Пошук марки
        Autocomplete<String>(
          optionsBuilder: (v) => v.text.isEmpty ? _modelsByBrand.keys.toList() : _modelsByBrand.keys.where((b) => b.toLowerCase().contains(v.text.toLowerCase())),
          onSelected: (s) => setState(() => _brandCtrl.text = s),
          fieldViewBuilder: (c, ctrl, fn, onS) => TextField(controller: ctrl, focusNode: fn, decoration: const InputDecoration(labelText: 'Марка', border: OutlineInputBorder())),
        ),
        const SizedBox(height: 10),
        // Пошук моделі, який залежить від _brandCtrl.text
        Autocomplete<String>(
          optionsBuilder: (v) {
            final models = _modelsByBrand[_brandCtrl.text] ?? [];
            return v.text.isEmpty ? models : models.where((m) => m.toLowerCase().contains(v.text.toLowerCase()));
          },
          onSelected: (s) => _modelCtrl.text = s,
          fieldViewBuilder: (c, ctrl, fn, onS) => TextField(controller: ctrl, focusNode: fn, decoration: const InputDecoration(labelText: 'Модель (залежить від марки)', border: OutlineInputBorder())),
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () async {
          final data = {'name': _name.text, 'brand': _brandCtrl.text, 'carModel': _modelCtrl.text, 'quantity': int.tryParse(_qty.text) ?? 1, 'article': _art.text};
          if (widget.part == null) await DatabaseHelper.instance.insertPart(data);
          else { data['id'] = widget.part!['id']; await DatabaseHelper.instance.updatePart(data); }
          Navigator.pop(context, true);
        }, child: const Text('Зберегти')),
        
        // Кнопка видалення з підтвердженням
        if (widget.part != null) ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
              title: const Text('Видалити?'),
              content: const Text('Ви впевнені, що хочете видалити цей запис?'),
              actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Ні')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Так'))]
            ));
            if (confirm == true) { await DatabaseHelper.instance.deletePart(widget.part!['id']); Navigator.pop(context, true); }
          },
          child: const Text('Видалити')
        )
      ])),
    );
  }
}
