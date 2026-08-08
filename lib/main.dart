import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'database_helper.dart';
import 'dart:convert';

// Готові галузеві шаблони
final Map<String, Map<String, dynamic>> industryTemplates = {
  '🚗 Автомобільний склад': {
    'categories': ['Загальне', 'Двигун', 'Підвіска та ходова', 'Гальмівна система', 'Фільтри та розхідники', 'Електрика', 'Трансмісія та КПП', 'Мастила та рідини', 'Кузов та оптика', 'Інструменти та обладнання'],
    'brands': {'Audi': ['80', '90', '100', 'A3', 'A4', 'A6', 'Q7'], 'BMW': ['E30', 'E34', 'E36', 'E39', 'E46', 'E60', 'F10', 'X5'], 'Ford': ['Transit', 'Focus', 'Mondeo', 'Fiesta', 'Kuga'], 'Mercedes-Benz': ['Sprinter', 'Vito', 'W124', 'W210', 'Actros'], 'Opel': ['Zafira A', 'Zafira B', 'Astra G', 'Astra H', 'Vectra B', 'Vectra C', 'Vivaro'], 'Volkswagen': ['Transporter T4', 'Transporter T5', 'Golf 4', 'Golf 5', 'Passat B5', 'Passat B6', 'Tiguan']}
  },
  '🚜 Агро / Сільгосптехніка': {
    'categories': ['Загальне', 'Двигун і паливна', 'Гідравліка', 'Трансмісія та КПП', 'На навіску та раму', 'Електрообладнання', 'Шини та диски', 'Фільтри та ремені', 'Мастила та спецрідини', 'Підшипники та метизи'],
    'brands': {'MTZ (МТЗ)': ['80', '82', '82.1', '892', '1025', '1221', '1523', '3022'], 'John Deere': ['6000 series', '7000 series', '8000 series', '9000 series', '6M', '7R', '8R'], 'Case IH': ['Puma', 'Magnum', 'Maxxum', 'Optum', 'Steiger'], 'Caterpillar': ['320', '428', 'D6', 'D7', '950'], 'CLAAS': ['Lexion', 'Mega', 'Tucano', 'Axion'], 'New Holland': ['T7', 'T8', 'T9', 'CR', 'CX'], 'XTZ (ХТЗ)': ['T-150K', 'T-150', '17221']}
  },
  '🌱 Добрива, насіння та ЗЗР': {
    'categories': ['Насіння', 'Добрива мінеральні', 'Мікродобрива', 'Гербіциди', 'Фунгіциди', 'Інсектициди', 'Протруйники', 'Тара та упаковка', 'Зберігання', 'ЗІЗ'],
    'brands': {'Піонер (Pioneer)': ['Кукурудза', 'Соняшник', 'Ріпак'], 'Сингента (Syngenta)': ['Гербіциди', 'Фунгіциди', 'Інсектициди'], 'Мінеральні добрива': ['Аміачна селітра', 'Карбамид', 'КАС-32', 'NPK'], 'Укравіт': ['Захист', 'Добрива']}
  }
};

List<String> _categoriesList = List.from(industryTemplates.values.first['categories']);
Map<String, List<String>> _modelsByBrand = Map.from(industryTemplates.values.first['brands']);

bool showTotalSum = true;
ThemeMode currentThemeMode = ThemeMode.dark;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadCustomDictionaries();
  runApp(const MyApp());
}

Future<void> _loadCustomDictionaries() async {
  final prefs = await SharedPreferences.getInstance();
  showTotalSum = prefs.getBool('showTotalSum') ?? true;
  final savedCategories = prefs.getString('custom_categories');
  if (savedCategories != null) _categoriesList = List<String>.from(jsonDecode(savedCategories));
  final savedBrands = prefs.getString('custom_brands');
  if (savedBrands != null) _modelsByBrand = Map<String, List<String>>.from(jsonDecode(savedBrands).map((k, v) => MapEntry(k.toString(), List<String>.from(v))));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false, themeMode: currentThemeMode, theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blueAccent, brightness: Brightness.light), darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blueAccent, brightness: Brightness.dark), home: const HomePage());
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
    if (mounted) setState(() { allParts = data; _applySearch(); });
  }

  void _applySearch() {
    final q = searchQuery.toLowerCase().trim();
    filteredParts = allParts.where((p) => p.values.any((val) => val.toString().toLowerCase().contains(q))).toList();
  }

  @override
  Widget build(BuildContext context) {
    double total = allParts.fold(0, (sum, p) => sum + ((p['quantity'] as num?)?.toDouble() ?? 0) * ((p['price'] as num?)?.toDouble() ?? 0));
    return Scaffold(
      appBar: AppBar(title: const Text('Мій склад'), actions: [if (showTotalSum) Padding(padding: const EdgeInsets.all(12), child: Center(child: Text('Сума: ${total.toStringAsFixed(0)} грн', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent))))]),
      drawer: Drawer(child: ListView(children: [const DrawerHeader(decoration: BoxDecoration(color: Colors.blueAccent), child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [Icon(Icons.warehouse, size: 48, color: Colors.white), Text('Мій склад', style: TextStyle(color: Colors.white, fontSize: 20))])), ListTile(leading: const Icon(Icons.person), title: const Text('Профіль'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfilePage()))), ListTile(leading: const Icon(Icons.backup), title: const Text('Резервні копії'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const BackupPage()))), ListTile(leading: const Icon(Icons.settings), title: const Text('Налаштування'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsPage())).then((_) => setState(() {})))])),
      body: Column(children: [Padding(padding: const EdgeInsets.all(8), child: TextField(decoration: const InputDecoration(labelText: 'Пошук', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()), onChanged: (v) { searchQuery = v; _applySearch(); setState(() {}); })), Expanded(child: ListView.builder(itemCount: filteredParts.length, itemBuilder: (context, i) { final p = filteredParts[i]; return Card(margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: ListTile(leading: const Icon(Icons.warehouse, color: Colors.blueAccent), title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('Категорія: ${p['category']}\nК-сть: ${p['quantity']} | Ціна: ${p['price']} грн'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AddPartPage(part: p))).then((_) => _refresh()))); }))]),
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AddPartPage())).then((_) => _refresh()), child: const Icon(Icons.add)),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "Користувач", status = "Мій склад";
  @override
  void initState() { super.initState(); _load(); }
  void _load() async { final p = await SharedPreferences.getInstance(); setState(() { name = p.getString('userName') ?? "Користувач"; status = p.getString('userStatus') ?? "Мій склад"; }); }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Профіль')), body: ListView(padding: const EdgeInsets.all(16), children: [ListTile(title: const Text('Користувач'), subtitle: Text(name), onTap: () => _edit('userName', 'Ім\'я', name)), ListTile(title: const Text('Статус'), subtitle: Text(status), onTap: () => _edit('userStatus', 'Статус', status))]));
  void _edit(k, t, v) async { final c = TextEditingController(text: v); final res = await showDialog<String>(context: context, builder: (c2) => AlertDialog(title: Text('Редагувати $t'), content: TextField(controller: c), actions: [TextButton(onPressed: () => Navigator.pop(c2), child: const Text('Ок'))])); if (res != null) { final p = await SharedPreferences.getInstance(); await p.setString(k, c.text); _load(); } }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Налаштування')), body: ListView(children: [ListTile(leading: const Icon(Icons.dashboard_customize), title: const Text('Вибрати шаблон бази'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const TemplateSelectionPage()))), SwitchListTile(title: const Text('Показувати суму'), value: showTotalSum, onChanged: (v) async { showTotalSum = v; await (await SharedPreferences.getInstance()).setBool('showTotalSum', v); setState(() {}); })]));
}

class AddPartPage extends StatefulWidget {
  final Map<String, dynamic>? part;
  const AddPartPage({super.key, this.part});
  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  late final _name = TextEditingController(text: widget.part?['name'] ?? ''), _art = TextEditingController(text: widget.part?['article'] ?? ''), _qty = TextEditingController(text: (widget.part?['quantity'] ?? 1).toString()), _minQty = TextEditingController(text: (widget.part?['minQuantity'] ?? 0).toString()), _price = TextEditingController(text: (widget.part?['price'] ?? '').toString()), _cat = TextEditingController(text: widget.part?['category'] ?? _categoriesList.first);
  
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.part == null ? 'Новий товар' : 'Редагувати')), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [TextField(controller: _name, decoration: const InputDecoration(labelText: 'Назва', border: OutlineInputBorder())), const SizedBox(height: 10), TextField(controller: _cat, decoration: const InputDecoration(labelText: 'Категорія', border: OutlineInputBorder())), const SizedBox(height: 10), TextField(controller: _qty, decoration: const InputDecoration(labelText: 'Кількість', border: OutlineInputBorder()), onTap: () { if (_qty.text == '1' || _qty.text == '0') _qty.clear(); }), const SizedBox(height: 10), TextField(controller: _price, decoration: const InputDecoration(labelText: 'Ціна', border: OutlineInputBorder()), onTap: () { if (_price.text == '0' || _price.text == '0.0') _price.clear(); }), const SizedBox(height: 20), ElevatedButton(onPressed: () async { await (widget.part == null ? DatabaseHelper.instance.insertPart : DatabaseHelper.instance.updatePart)({'id': widget.part?['id'], 'name': _name.text, 'category': _cat.text, 'quantity': int.tryParse(_qty.text) ?? 0, 'price': double.tryParse(_price.text) ?? 0}); if (mounted) Navigator.pop(context); }, child: const Text('Зберегти'))])));
}

class TemplateSelectionPage extends StatelessWidget {
  const TemplateSelectionPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Шаблони')), body: ListView(children: industryTemplates.entries.map((e) => ListTile(title: Text(e.key), onTap: () async { _categoriesList = List.from(e.value['categories']); _modelsByBrand = Map.from(e.value['brands']); final p = await SharedPreferences.getInstance(); await p.setString('custom_categories', jsonEncode(_categoriesList)); await p.setString('custom_brands', jsonEncode(_modelsByBrand)); if (context.mounted) Navigator.pop(context); })).toList()));
}
