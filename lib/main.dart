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
    'brands': {
      'Audi': ['80', '90', '100', 'A3', 'A4', 'A6', 'Q7'],
      'BMW': ['E30', 'E34', 'E36', 'E39', 'E46', 'E60', 'F10', 'X5'],
      'Ford': ['Transit', 'Focus', 'Mondeo', 'Fiesta', 'Kuga'],
      'Mercedes-Benz': ['Sprinter', 'Vito', 'W124', 'W210', 'Actros'],
      'Opel': ['Zafira A', 'Zafira B', 'Astra G', 'Astra H', 'Vectra B', 'Vectra C', 'Vivaro'],
      'Volkswagen': ['Transporter T4', 'Transporter T5', 'Golf 4', 'Golf 5', 'Passat B5', 'Passat B6', 'Tiguan']
    }
  },
  '🚜 Агро / Сільгосптехніка': {
    'categories': ['Загальне', 'Двигун і паливна', 'Гідравліка', 'Трансмісія та КПП', 'На навіску та раму', 'Електрообладнання', 'Шини та диски', 'Фільтри та ремені', 'Мастила та спецрідини', 'Підшипники та метизи'],
    'brands': {
      'MTZ (МТЗ)': ['80', '82', '82.1', '892', '1025', '1221', '1523', '3022'],
      'John Deere': ['6000 series', '7000 series', '8000 series', '9000 series', '6M', '7R', '8R'],
      'Case IH': ['Puma', 'Magnum', 'Maxxum', 'Optum', 'Steiger'],
      'Caterpillar': ['320', '428', 'D6', 'D7', '950'],
      'CLAAS': ['Lexion', 'Mega', 'Tucano', 'Axion'],
      'New Holland': ['T7', 'T8', 'T9', 'CR', 'CX'],
      'XTZ (ХТЗ)': ['T-150K', 'T-150', '17221']
    }
  },
  '🌱 Добрива, насіння та ЗЗР': {
    'categories': ['Насіння', 'Добрива мінеральні', 'Мікродобрива', 'Гербіциди', 'Фунгіциди', 'Інсектициди', 'Протруйники', 'Тара та упаковка', 'Зберігання', 'ЗІЗ'],
    'brands': {
      'Піонер (Pioneer)': ['Кукурудза', 'Соняшник', 'Ріпак'],
      'Сингента (Syngenta)': ['Гербіциди', 'Фунгіциди', 'Інсектициди'],
      'Мінеральні добрива': ['Аміачна селітра', 'Карбамид', 'КАС-32', 'NPK'],
      'Укравіт': ['Захист', 'Добрива']
    }
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
  if (savedCategories != null) {
    _categoriesList = List<String>.from(jsonDecode(savedCategories));
  }

  final savedBrands = prefs.getString('custom_brands');
  if (savedBrands != null) {
    _modelsByBrand = Map<String, List<String>>.from(
      jsonDecode(savedBrands).map((k, v) => MapEntry(k.toString(), List<String>.from(v)))
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: currentThemeMode,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blueAccent, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blueAccent, brightness: Brightness.dark),
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
    final data = await DatabaseHelper.instance.fetchParts();
    if (mounted) {
      setState(() {
        allParts = data;
        _applySearch();
      });
    }
  }

  void _applySearch() {
    final q = searchQuery.toLowerCase().trim();
    if (q.isEmpty) {
      filteredParts = List.from(allParts);
    } else {
      filteredParts = allParts.where((p) => p.values.any((val) => val.toString().toLowerCase().contains(q))).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = allParts.fold(0, (sum, p) => sum + ((p['quantity'] as num?)?.toDouble() ?? 0) * ((p['price'] as num?)?.toDouble() ?? 0));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мій склад'),
        actions: [
          if (showTotalSum)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Text(
                  'Сума: ${total.toStringAsFixed(0)} грн',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent),
                ),
              ),
            )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warehouse, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text('Мій склад', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Профіль'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfilePage())),
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Резервні копії & Excel'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const BackupPage())),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Налаштування'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsPage())).then((_) => setState(() {})),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Пошук (назва, арт, категорія, бренд)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                searchQuery = v;
                _applySearch();
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredParts.length,
              itemBuilder: (context, i) {
                final p = filteredParts[i];
                final brand = p['brand'] ?? '';
                final model = p['carModel'] ?? '';
                final details = [brand, model].where((e) => e.isNotEmpty).join(' ');

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.warehouse, color: Colors.blueAccent),
                    title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Категорія: ${p['category']}\nОб’єкт: $details | К-сть: ${p['quantity']} | Ціна: ${p['price']} грн'),
                    isThreeLine: true,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AddPartPage(part: p))).then((_) => _refresh()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AddPartPage())).then((_) => _refresh()),
        child: const Icon(Icons.add),
      ),
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
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      name = p.getString('userName') ?? "Користувач";
      status = p.getString('userStatus') ?? "Мій склад";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Користувач', style: TextStyle(color: Colors.grey, fontSize: 13)),
            subtitle: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.edit),
            onTap: () => _edit('userName', 'Ім\'я', name),
          ),
          const Divider(),
          ListTile(
            title: const Text('Статус', style: TextStyle(color: Colors.grey, fontSize: 13)),
            subtitle: Text(status, style: const TextStyle(fontSize: 18)),
            trailing: const Icon(Icons.edit),
            onTap: () => _edit('userStatus', 'Статус', status),
          ),
        ],
      ),
    );
  }

  void _edit(k, t, v) async {
    final c = TextEditingController(text: v);
    final res = await showDialog<String>(
      context: context,
      builder: (c2) => AlertDialog(
        title: Text('Редагувати $t'),
        content: TextField(controller: c, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c2), child: const Text('Скасувати')),
          TextButton(onPressed: () => Navigator.pop(c2, c.text), child: const Text('Зберегти')),
        ],
      ),
    );
    if (res != null && res.trim().isNotEmpty) {
      final p = await SharedPreferences.getInstance();
      await p.setString(k, res.trim());
      _load();
    }
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Налаштування')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dashboard_customize, color: Colors.amberAccent),
            title: const Text('Вибрати галузевий шаблон бази'),
            subtitle: const Text('Авто, Агро або Насіння і ЗЗР'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const TemplateSelectionPage())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit_note, color: Colors.blueAccent),
            title: const Text('Редагувати категорії та бренди вручну'),
            subtitle: const Text('Додавання та видалення елементів'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const EditDictionariesPage())),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Показувати загальну суму'),
            value: showTotalSum,
            onChanged: (v) async {
              showTotalSum = v;
              await (await SharedPreferences.getInstance()).setBool('showTotalSum', v);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

class BrandModelsPage extends StatefulWidget {
  final String brand;
  const BrandModelsPage({super.key, required this.brand});

  @override
  State<BrandModelsPage> createState() => _BrandModelsPageState();
}

class _BrandModelsPageState extends State<BrandModelsPage> {
  void _addModel() async {
    final ctrl = TextEditingController();
    final res = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Додати елемент для ${widget.brand}'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Назва')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Скасувати')),
          TextButton(onPressed: () => Navigator.pop(c, ctrl.text.trim()), child: const Text('Додати')),
        ],
      ),
    );
    if (res != null && res.isNotEmpty) {
      setState(() {
        _modelsByBrand[widget.brand] ??= [];
        if (!_modelsByBrand[widget.brand]!.contains(res)) {
          _modelsByBrand[widget.brand]!.add(res);
        }
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_brands', jsonEncode(_modelsByBrand));
    }
  }

  @override
  Widget build(BuildContext context) {
    final models = _modelsByBrand[widget.brand] ?? [];
    return Scaffold(
      appBar: AppBar(title: Text('Елементи: ${widget.brand}')),
      body: ListView.builder(
        itemCount: models.length,
        itemBuilder: (context, index) {
          final model = models[index];
          return ListTile(
            title: Text(model),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                setState(() {
                  _modelsByBrand[widget.brand]!.removeAt(index);
                });
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('custom_brands', jsonEncode(_modelsByBrand));
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addModel,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditDictionariesPage extends StatefulWidget {
  const EditDictionariesPage({super.key});

  @override
  State<EditDictionariesPage> createState() => _EditDictionariesPageState();
}

class _EditDictionariesPageState extends State<EditDictionariesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addCategory() async {
    final ctrl = TextEditingController();
    final res = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Додати категорію'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Назва')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Скасувати')),
          TextButton(onPressed: () => Navigator.pop(c, ctrl.text.trim()), child: const Text('Додати')),
        ],
      ),
    );
    if (res != null && res.isNotEmpty) {
      setState(() {
        if (!_categoriesList.contains(res)) _categoriesList.add(res);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_categories', jsonEncode(_categoriesList));
    }
  }

  void _addBrand() async {
    final ctrl = TextEditingController();
    final res = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Додати бренд / напрямок'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Назва')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Скасувати')),
          TextButton(onPressed: () => Navigator.pop(c, ctrl.text.trim()), child: const Text('Додати')),
        ],
      ),
    );
    if (res != null && res.isNotEmpty) {
      setState(() {
        if (!_modelsByBrand.containsKey(res)) _modelsByBrand[res] = [];
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_brands', jsonEncode(_modelsByBrand));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Керування словниками'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Категорії'), Tab(text: 'Бренди / Техніка')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            itemCount: _categoriesList.length,
            itemBuilder: (context, index) {
              final cat = _categoriesList[index];
              return ListTile(
                title: Text(cat),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    setState(() { _categoriesList.removeAt(index); });
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('custom_categories', jsonEncode(_categoriesList));
                  },
                ),
              );
            },
          ),
          ListView.builder(
            itemCount: _modelsByBrand.keys.length,
            itemBuilder: (context, index) {
              String brand = _modelsByBrand.keys.elementAt(index);
              return ListTile(
                title: Text(brand),
                subtitle: Text('Елементів: ${_modelsByBrand[brand]?.length ?? 0}'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => BrandModelsPage(brand: brand))).then((_) => setState(() {})),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    setState(() { _modelsByBrand.remove(brand); });
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('custom_brands', jsonEncode(_modelsByBrand));
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _addCategory();
          } else {
            _addBrand();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TemplateSelectionPage extends StatelessWidget {
  const TemplateSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Галузеві шаблони')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: industryTemplates.entries.map((e) {
          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            child: ListTile(
              title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Категорій: ${(e.value['categories'] as List).length}'),
              trailing: ElevatedButton(
                child: const Text('Вибрати'),
                onPressed: () async {
                  _categoriesList = List.from(e.value['categories']);
                  _modelsByBrand = Map.from(e.value['brands']);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('custom_categories', jsonEncode(_categoriesList));
                  await prefs.setString('custom_brands', jsonEncode(_modelsByBrand));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Шаблон застосовано!'), backgroundColor: Colors.green));
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  Future<void> _exportDatabase(BuildContext context) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = '$dbPath/parts_warehouse.db';
      final file = File(path);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(path)], text: 'Резервна копія складу');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Файл бази не знайдено!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка: $e')));
    }
  }

  Future<void> _importDatabase(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        final selectedFile = File(result.files.single.path!);
        final dbPath = await getDatabasesPath();
        final path = '$dbPath/parts_warehouse.db';
        await selectedFile.copy(path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Базу відновлено! Перезапустіть додаток.'), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Резервні копії & Excel')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(icon: const Icon(Icons.share), label: const Text('Поділитися базою даних'), onPressed: () => _exportDatabase(context)),
            const SizedBox(height: 15),
            ElevatedButton.icon(icon: const Icon(Icons.download), label: const Text('Відновити з файлу'), onPressed: () => _importDatabase(context)),
          ],
        ),
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
  late final TextEditingController _name = TextEditingController(text: widget.part?['name'] ?? '');
  late final TextEditingController _art = TextEditingController(text: widget.part?['article'] ?? '');
  late final TextEditingController _qty = TextEditingController(text: widget.part != null ? (widget.part?['quantity'] ?? 1).toString() : '');
  late final TextEditingController _minQty = TextEditingController(text: widget.part != null ? (widget.part?['minQuantity'] ?? 0).toString() : '');
  late final TextEditingController _price = TextEditingController(text: widget.part != null ? (widget.part?['price'] ?? '').toString() : '');
  late final TextEditingController _brand = TextEditingController(text: widget.part?['brand'] ?? '');
  late final TextEditingController _model = TextEditingController(text: widget.part?['carModel'] ?? '');
  late final TextEditingController _year = TextEditingController(text: widget.part?['carYear'] ?? '');
  late final TextEditingController _cat = TextEditingController(text: widget.part?['category'] ?? '');

  @override
  Widget build(BuildContext context) {
    final brandsList = _modelsByBrand.keys.toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.part == null ? 'Новий товар' : 'Редагувати')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Назва товару', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _cat.text),
              optionsBuilder: (TextEditingValue v) {
                if (v.text.isEmpty) return _categoriesList;
                return _categoriesList.where((cat) => cat.toLowerCase().contains(v.text.toLowerCase()));
              },
              onSelected: (String s) { _cat.text = s; },
              fieldViewBuilder: (context, fieldController, fieldFocusNode, onFieldSubmitted) {
                if (fieldController.text != _cat.text && fieldController.text.isEmpty) {
                  fieldController.text = _cat.text;
                }
                return TextField(
                  controller: fieldController,
                  focusNode: fieldFocusNode,
                  decoration: const InputDecoration(labelText: 'Категорія', border: OutlineInputBorder(), suffixIcon: Icon(Icons.category)),
                  onChanged: (v) { _cat.text = v; },
                  onTap: () {
                    if (widget.part == null && fieldController.text.isNotEmpty) {
                      fieldController.clear();
                      _cat.clear();
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(controller: _art, decoration: const InputDecoration(labelText: 'Артикул / Код', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _qty, decoration: const InputDecoration(labelText: 'Кількість', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _minQty, decoration: const InputDecoration(labelText: 'Мін. залишок', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _price, decoration: const InputDecoration(labelText: 'Ціна за одиницю (грн)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _brand.text),
              optionsBuilder: (TextEditingValue v) {
                if (v.text.isEmpty) return brandsList;
                return brandsList.where((b) => b.toLowerCase().contains(v.text.toLowerCase()));
              },
              onSelected: (String s) {
                setState(() {
                  _brand.text = s;
                  _model.text = '';
                });
              },
              fieldViewBuilder: (context, fieldController, fieldFocusNode, onFieldSubmitted) {
                return TextField(
                  controller: fieldController,
                  focusNode: fieldFocusNode,
                  decoration: const InputDecoration(labelText: 'Марка / Виробник', border: OutlineInputBorder()),
                  onChanged: (v) { _brand.text = v; },
                );
              },
            ),
            const SizedBox(height: 12),
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _model.text),
              optionsBuilder: (TextEditingValue v) {
                final allowed = _modelsByBrand[_brand.text] ?? ['Загальна'];
                if (v.text.isEmpty) return allowed;
                return allowed.where((m) => m.toLowerCase().contains(v.text.toLowerCase()));
              },
              onSelected: (String s) { _model.text = s; },
              fieldViewBuilder: (context, fieldController, fieldFocusNode, onFieldSubmitted) {
                return TextField(
                  controller: fieldController,
                  focusNode: fieldFocusNode,
                  decoration: const InputDecoration(labelText: 'Модель / Препарат', border: OutlineInputBorder()),
                  onChanged: (v) { _model.text = v; },
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(controller: _year, decoration: const InputDecoration(labelText: 'Рік / Сезон', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () async {
                final data = {
                  'id': widget.part?['id'],
                  'name': _name.text.trim(),
                  'category': _cat.text.trim().isNotEmpty ? _cat.text.trim() : 'Загальне',
                  'article': _art.text.trim(),
                  'quantity': int.tryParse(_qty.text) ?? 1,
                  'minQuantity': int.tryParse(_minQty.text) ?? 0,
                  'price': double.tryParse(_price.text) ?? 0.0,
                  'brand': _brand.text.trim(),
                  'carModel': _model.text.trim(),
                  'carYear': _year.text.trim(),
                };
                await (widget.part == null ? DatabaseHelper.instance.insertPart(data) : DatabaseHelper.instance.updatePart(data));
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Зберегти', style: TextStyle(fontSize: 16)),
            ),
            if (widget.part != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 50)),
                onPressed: () async {
                  await DatabaseHelper.instance.deletePart(widget.part!['id']);
                  if (mounted) Navigator.pop(context);
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
