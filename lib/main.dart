import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'database_helper.dart';
import 'dart:convert';

// Початкові категорії за замовчуванням
List<String> _categoriesList = [
  'Загальне', 'Двигун', 'Підвіска та ходова', 'Гальмівна система',
  'Фільтри та розхідники', 'Електрика', 'Трансмісія та КПП',
  'Мастила та рідини', 'Кузов та оптика', 'Інструменти та обладнання'
];

// Повний словник марок і моделей техніки
Map<String, List<String>> _modelsByBrand = {
  'Alfa Romeo': ['145', '146', '147', '155', '156', '159', '164', '166', 'Giulietta', 'Giulia', 'Stelvio', 'MiTo', 'GT', 'Tonale'],
  'Audi': ['80', '90', '100', '200', 'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'Q2', 'Q3', 'Q4', 'Q5', 'Q7', 'Q8', 'TT', 'R8', 'RS3', 'RS4', 'RS6'],
  'BMW': ['E30', 'E32', 'E34', 'E36', 'E38', 'E39', 'E46', 'E60', 'E63', 'E65', 'E81', 'E82', 'E83', 'E84', 'E87', 'E90', 'E91', 'E92', 'E93', 'F10', 'F11', 'F15', 'F20', 'F25', 'F30', 'F31', 'G01', 'G05', 'G20', 'G30', 'G07', 'X1', 'X2', 'X3', 'X4', 'X5', 'X6', 'X7'],
  'Case IH': ['Puma', 'Magnum', 'Maxxum', 'Optum', 'Steiger', 'Farmall', 'Quantum', 'Vestrum'],
  'Caterpillar': ['312', '315', '320', '323', '325', '330', '422', '428', '432', '434', 'D5', 'D6', 'D7', 'D8', '950', '966'],
  'Chevrolet': ['Aveo', 'Lacetti', 'Niva', 'Cruze', 'Epica', 'Tacuma', 'Captiva', 'Volt', 'Spark', 'Malibu', 'Orlando', 'Tahoe'],
  'Chrysler': ['Voyager', 'Grand Voyager', 'PT Cruiser', '300C', 'Sebring', 'Pacifica', 'Crossfire'],
  'Citroën': ['Berlingo', 'Jumper', 'Jumpy', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C8', 'Xsara', 'C-Elysee', 'Nemo', 'Saxo', 'Xantia', 'ZX'],
  'CLAAS': ['Lexion', 'Mega', 'Tucano', 'Axion', 'Arion', 'Atos', 'Dominator', 'Medion'],
  'Dacia': ['Logan', 'Duster', 'Sandero', 'Dokker', 'Lodgy', 'Spring', 'Solenza'],
  'DAF': ['XF 95', 'XF 105', 'XF 106', 'CF 65', 'CF 75', 'CF 85', 'LF 45', 'LF 55', 'XG', 'XG+'],
  'Dodge': ['Caliber', 'Journey', 'RAM 1500', 'RAM 2500', 'Nitro', 'Charger', 'Challenger', 'Dart', 'Grand Caravan'],
  'Fiat': ['Doblo', 'Ducato', 'Fiorino', 'Scudo', 'Punto', 'Tipo', 'Bravo', 'Linea', 'Freemont', 'Uno', 'Stilo', 'Multipla', 'Palio', 'Croma'],
  'Ford': ['Transit', 'Tourneo', 'Focus', 'Mondeo', 'Fiesta', 'Connect', 'Kuga', 'Fusion', 'Cargo', 'Edge', 'Explorer', 'Escort', 'Sierra', 'Scorpio', 'Ka', 'C-Max', 'S-Max', 'Ranger'],
  'GAZ (ГАЗ)': ['3302 (Газель)', '3221 (Соболь)', '2705', '53', '66', '3307', 'Волга 3110', 'Волга 31105', 'Валдай', 'Next'],
  'Honda': ['Civic', 'Accord', 'CR-V', 'HR-V', 'Jazz', 'Pilot', 'Legend', 'Prelude', 'Logo', 'FR-V'],
  'Hyundai': ['Accent', 'Elantra', 'Sonata', 'Tucson', 'Santa Fe', 'H-1', 'i10', 'i20', 'i30', 'i40', 'Matrix', 'Terracan', 'Galloper', 'Getz', 'Coupe'],
  'IVECO': ['Daily', 'Stralis', 'Eurocargo', 'Trakker', 'S-Way', 'EuroStar', 'EuroTech'],
  'JCB': ['3CX', '4CX', 'Fastrac', 'Teletruk', '531-70', '535-95', '8018', 'JS200'],
  'Jeep': ['Grand Cherokee', 'Cherokee', 'Renegade', 'Wrangler', 'Compass', 'Patriot', 'Commander'],
  'John Deere': ['6000 series', '7000 series', '8000 series', '9000 series', 'S-Series', '5E', '6M', '7R', '8R'],
  'KAMAZ (КАМАЗ)': ['5320', '65115', '5490', '4310', '5511', '6520', '5410', '53212'],
  'Kia': ['Ceed', 'Sportage', 'Sorento', 'Rio', 'Cerato', 'Magentis', 'Soul', 'Optima', 'Carnival', 'Picanto', 'Venga', 'Carens', 'Stinger'],
  'Lada / ВАЗ': ['2101', '2102', '2103', '2104', '2105', '2106', '2107', '2108', '2109', '21099', '2110', '2111', '2112', 'Priora', 'Kalina', 'Granta', 'Niva 4x4', 'Vesta', 'Largus'],
  'Land Rover': ['Defender', 'Discovery 1', 'Discovery 2', 'Discovery 3', 'Discovery 4', 'Discovery 5', 'Range Rover', 'Freelander', 'Velar', 'Evoque'],
  'Lexus': ['RX 300', 'RX 330', 'RX 350', 'LX 470', 'LX 570', 'GS 300', 'IS 200', 'IS 250', 'NX 200', 'ES 300', 'ES 350', 'LS 430'],
  'MAN': ['TGA', 'TGS', 'TGX', 'F2000', 'LE', 'TGM', 'TGL', 'Commander'],
  'MAZ (МАЗ)': ['5440', '6430', '5551', '4370 (Зубренок)', '103', '5432', '5516'],
  'Mazda': ['2', '3', '5', '6', 'Demio', 'Premacy', 'BT-50', 'CX-3', 'CX-5', 'CX-7', 'CX-9', 'Tribute', '323', '626', 'MPV'],
  'Mercedes-Benz': ['Sprinter', 'Vito', 'Viano', 'Atego', 'Actros', 'W124', 'W210', 'W202', 'W203', 'W211', 'W220', 'W212', 'GL', 'ML', 'A-Class', 'C-Class', 'E-Class', 'S-Class', 'G-Class', 'CLA', 'CLS', 'GLA', 'GLE', 'GLC'],
  'Mitsubishi': ['L200', 'Pajero', 'Pajero Sport', 'Outlander', 'Colt', 'Lancer', 'Galant', 'ASX', 'Grandis', 'Carisma', 'Space Star', 'Eclipse Cross'],
  'MTZ (МТЗ)': ['80', '82', '82.1', '892', '1025', '1221', '1523', '3022', '920', '952', '1021'],
  'New Holland': ['T7', 'T8', 'T9', 'CR', 'CX', 'T5', 'T6', 'TC'],
  'Nissan': ['Navara', 'Patrol', 'Qashqai', 'X-Trail', 'Primastar', 'Interstar', 'Almera', 'Maxima', 'Note', 'Juke', 'Leaf', 'Tiida', 'Micra', 'Pathfinder', 'Terrano', 'Primera'],
  'Opel': ['Zafira A', 'Zafira B', 'Zafira C', 'Astra F', 'Astra G', 'Astra H', 'Astra J', 'Vectra A', 'Vectra B', 'Vectra C', 'Insignia', 'Combo', 'Vivaro', 'Movano', 'Omega A', 'Omega B', 'Corsa B', 'Corsa C', 'Corsa D', 'Meriva A', 'Meriva B', 'Agila', 'Frontera'],
  'Peugeot': ['Partner', 'Boxer', 'Expert', '308', '406', '407', '207', '3008', '508', '206', '107', '208', '408', '5008'],
  'Renault': ['Kangoo', 'Master', 'Trafic', 'Megane', 'Logan', 'Scenic', 'Premium', 'Magnum', 'Duster', 'Symbol', 'Fluence', 'Koleos', 'Laguna', 'Espace', 'Clio', 'Modus'],
  'Scania': ['R-series', 'G-series', 'P-series', 'Streamline', 'Next Gen', 'S-series', '114', '124'],
  'Skoda': ['Octavia A4', 'Octavia A5', 'Octavia A7', 'Fabia', 'Superb', 'Rapid', 'Yeti', 'Kodiaq', 'Karoq', 'Roomster', 'Felicia', 'Citigo'],
  'Subaru': ['Forester', 'Outback', 'Impreza', 'Legacy', 'Tribeca', 'XV', 'Crosstrek', 'B9', 'Justy'],
  'Suzuki': ['Grand Vitara', 'Vitara', 'SX4', 'Jimny', 'Swift', 'Baleno', 'Ignis', 'Liana'],
  'Toyota': ['Land Cruiser 80', 'Land Cruiser 100', 'Land Cruiser 200', 'Land Cruiser 300', 'Prado 90', 'Prado 120', 'Prado 150', 'Hilux', 'Corolla', 'Camry', 'Hiace', 'Avensis', 'RAV4', 'Yaris', 'Auris', 'Prius', 'Celica', 'Carina'],
  'Volkswagen': ['Transporter T4', 'Transporter T5', 'Transporter T6', 'Caddy', 'Crafter', 'Golf 2', 'Golf 3', 'Golf 4', 'Golf 5', 'Golf 6', 'Golf 7', 'Passat B3', 'Passat B4', 'Passat B5', 'Passat B6', 'Passat B7', 'Passat B8', 'LT', 'Touareg', 'Tiguan', 'Polo', 'Jetta', 'Bora', 'Sharan', 'Touran'],
  'Volvo': ['FH12', 'FH16', 'FM', 'XC60', 'XC90', 'S60', 'S80', 'V70', 'S40', 'V40', 'XC70'],
  'XTZ (ХТЗ)': ['T-150K', 'T-150', 'XZ-1613', '243К', '17221'],
  'ZAZ (ЗАЗ)': ['Sens', 'Slavuta', 'Tavria', 'Forza', 'Vida', '968', '1102', '1103']
};

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
    List decoded = jsonDecode(savedCategories);
    _categoriesList = decoded.map((e) => e.toString()).toList();
  }

  final savedBrands = prefs.getString('custom_brands');
  if (savedBrands != null) {
    Map decoded = jsonDecode(savedBrands);
    _modelsByBrand = decoded.map((key, value) => MapEntry(key.toString(), (value as List).map((e) => e.toString()).toList()));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void updateAppSettings() async {
    await _loadCustomDictionaries();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: currentThemeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: HomePage(onSettingsChanged: updateAppSettings),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback onSettingsChanged;
  const HomePage({super.key, required this.onSettingsChanged});

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
    data.sort((a, b) => (a['brand'] ?? '').toString().compareTo((b['brand'] ?? '').toString()));
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
          (p['carModel'] ?? '').toString().toLowerCase().contains(q) ||
          (p['carYear'] ?? '').toString().toLowerCase().contains(q) ||
          (p['category'] ?? '').toString().toLowerCase().contains(q)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalInventoryCost = 0;
    for (var p in allParts) {
      final qty = (p['quantity'] as num?)?.toDouble() ?? 0;
      final price = (p['price'] as num?)?.toDouble() ?? 0;
      totalInventoryCost += qty * price;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Склад запчастин'),
        actions: [
          if (showTotalSum)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'Сума: ${totalInventoryCost.toStringAsFixed(0)} грн',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 15),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.warehouse, size: 48, color: Colors.white),
                  SizedBox(height: 10),
                  Text('Гараж / Склад', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Профіль'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfilePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Резервне копіювання & Excel'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (c) => const BackupPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Налаштування'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (c) => SettingsPage(onChanged: () {
                      widget.onSettingsChanged();
                      setState(() {});
                    }),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Пошук (назва, арт, марка, модель, рік, категорія)', 
                prefixIcon: Icon(Icons.search), 
                border: OutlineInputBorder()
              ),
              onChanged: (v) { setState(() { searchQuery = v; _applySearch(); }); },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredParts.length,
              itemBuilder: (context, i) {
                final p = filteredParts[i];
                final brand = p['brand'] ?? '';
                final carModel = p['carModel'] ?? '';
                final carYear = p['carYear'] ?? '';
                final category = p['category'] ?? 'Загальне';
                final qty = p['quantity'] ?? 1;
                final minQty = p['minQuantity'] ?? 0;
                final price = (p['price'] as num?)?.toDouble() ?? 0.0;
                final isLowStock = qty <= minQty;

                final carDetails = [brand, carModel, carYear].where((e) => e.isNotEmpty).join(' ');

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: isLowStock ? Colors.redAccent : Colors.transparent, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.directions_car, 
                      color: isLowStock ? Colors.redAccent : Colors.blueAccent
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                        if (isLowStock)
                          const Chip(
                            backgroundColor: Colors.red,
                            label: Text('Мало!', style: TextStyle(color: Colors.white, fontSize: 10)),
                            padding: EdgeInsets.zero,
                          )
                      ],
                    ),
                    subtitle: Text(
                      'Категорія: $category\nАвто: $carDetails\nАрт: ${p['article']} | К-сть: $qty шт. | Ціна: $price грн',
                    ),
                    isThreeLine: true,
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
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (c) => const AddPartPage()));
          if (result == true) _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Сторінка редагування моделей конкретної марки
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
        title: Text('Додати модель для ${widget.brand}'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Назва моделі')),
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
      appBar: AppBar(title: Text('Моделі: ${widget.brand}')),
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
    _tabController.addListener(() {
      setState(() {});
    });
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
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Назва категорії')),
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
        title: const Text('Додати марку/техніку'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Назва бренду')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Скасувати')),
          TextButton(onPressed: () => Navigator.pop(c, ctrl.text.trim()), child: const Text('Додати')),
        ],
      ),
    );
    if (res != null && res.isNotEmpty) {
      setState(() {
        if (!_modelsByBrand.containsKey(res)) {
          _modelsByBrand[res] = [];
        }
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
          tabs: const [
            Tab(text: 'Категорії'),
            Tab(text: 'Марки техніки'),
          ],
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
                    setState(() {
                      _categoriesList.removeAt(index);
                    });
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
                subtitle: Text('Моделей: ${_modelsByBrand[brand]?.length ?? 0} (натисніть для редагування моделей)'),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => BrandModelsPage(brand: brand)),
                  );
                  setState(() {});
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => BrandModelsPage(brand: brand)),
                        );
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        setState(() {
                          _modelsByBrand.remove(brand);
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('custom_brands', jsonEncode(_modelsByBrand));
                      },
                    ),
                  ],
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "Володимир";
  String status = "Господарський склад / Гараж";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('userName') ?? "Володимир";
      status = prefs.getString('userStatus') ?? "Господарський склад / Гараж";
    });
  }

  void _editField(String key, String title, String currentValue) async {
    final controller = TextEditingController(text: currentValue);
    final result = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Редагувати $title'),
        content: TextField(controller: controller, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Скасувати')),
          TextButton(onPressed: () => Navigator.pop(c, controller.text), child: const Text('Зберегти')),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, result.trim());
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('Користувач', style: TextStyle(fontSize: 14, color: Colors.grey)),
            subtitle: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.edit),
            onTap: () => _editField('userName', 'Ім\'я', name),
          ),
          const Divider(),
          ListTile(
            title: const Text('Статус', style: TextStyle(fontSize: 14, color: Colors.grey)),
            subtitle: Text(status, style: const TextStyle(fontSize: 18)),
            trailing: const Icon(Icons.edit),
            onTap: () => _editField('userStatus', 'Статус', status),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final VoidCallback onChanged;
  const SettingsPage({super.key, required this.onChanged});

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
            leading: const Icon(Icons.edit_note, color: Colors.blueAccent),
            title: const Text('Редагувати категорії та марки техніки'),
            subtitle: const Text('Додавайте власні категорії та моделі під аграрну чи іншу сферу'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const EditDictionariesPage()));
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Показувати загальну суму у верхньому кутку'),
            subtitle: const Text('Відображати загальну вартість всіх деталей на складі'),
            value: showTotalSum,
            onChanged: (bool value) async {
              setState(() { showTotalSum = value; });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('showTotalSum', value);
              widget.onChanged();
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Темна тема'),
            subtitle: const Text('Увімкнути темне оформлення інтерфейсу'),
            value: currentThemeMode == ThemeMode.dark,
            onChanged: (bool value) {
              setState(() {
                currentThemeMode = value ? ThemeMode.dark : ThemeMode.light;
              });
              widget.onChanged();
            },
          ),
        ],
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
        await Share.shareXFiles([XFile(path)], text: 'Резервна копія складу запчастин');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Файл бази даних не знайдено!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка експорту: $e')));
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Базу успішно відновлено! Перезапустіть додаток.'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка імпорту: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportToExcel(BuildContext context) async {
    try {
      final parts = await DatabaseHelper.instance.fetchParts();
      StringBuffer csvContent = StringBuffer();
      csvContent.writeln('Назва,Категорія,Артикул,Кількість,Мін.залишок,Ціна(грн),Марка,Модель,Рік');

      for (var p in parts) {
        csvContent.writeln(
          '"${p['name']}","${p['category']}","${p['article']}","${p['quantity']}","${p['minQuantity']}","${p['price']}","${p['brand']}","${p['carModel']}","${p['carYear']}"'
        );
      }

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/sklad_zapchastyn.csv';
      final file = File(path);
      await file.writeAsString(csvContent.toString());

      await Share.shareXFiles([XFile(path)], text: 'Звіт складу у форматі Excel (CSV)');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка вивантаження в Excel: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Резервне копіювання та Звіти')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Резервна копія бази (для оновлення додатку):',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Зберегти / Поділитися базою даних'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () => _exportDatabase(context),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.download, color: Colors.amberAccent),
              label: const Text('Відновити з файлу (Імпорт бази)'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () => _importDatabase(context),
            ),
            const SizedBox(height: 30),
            const Text(
              'Експорт у таблицю Excel:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.table_chart, color: Colors.greenAccent),
              label: const Text('Експортувати список в Excel (CSV)'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () => _exportToExcel(context),
            ),
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
  late final TextEditingController _nameCtrl;
  late final TextEditingController _art;
  late final TextEditingController _qty;
  late final TextEditingController _minQty;
  late final TextEditingController _price;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _categoryCtrl; // Додано контролер для категорії
  
  List<String> _existingPartNames = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.part?['name'] ?? '');
    _art = TextEditingController(text: widget.part?['article'] ?? '');
    
    // Якщо створюємо нову запчастину, ставимо порожні поля або '1', щоб не видаляти нуль вручну
    final qtyVal = widget.part != null ? (widget.part?['quantity'] ?? 1).toString() : '1';
    final minQtyVal = widget.part != null ? (widget.part?['minQuantity'] ?? 0).toString() : '0';
    final priceVal = widget.part != null ? (widget.part?['price'] ?? 0).toString() : '';

    _qty = TextEditingController(text: qtyVal);
    _minQty = TextEditingController(text: minQtyVal);
    _price = TextEditingController(text: priceVal);
    
    _brandCtrl = TextEditingController(text: widget.part?['brand'] ?? '');
    _modelCtrl = TextEditingController(text: widget.part?['carModel'] ?? '');
    _yearCtrl = TextEditingController(text: widget.part?['carYear'] ?? '');
    _categoryCtrl = TextEditingController(text: widget.part?['category'] ?? (_categoriesList.isNotEmpty ? _categoriesList.first : 'Загальне'));

    _loadExistingPartNames();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _art.dispose();
    _qty.dispose();
    _minQty.dispose();
    _price.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
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
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _nameCtrl.text),
              optionsBuilder: (TextEditingValue v) {
                if (v.text.isEmpty) return _existingPartNames;
                return _existingPartNames.where((n) => n.toLowerCase().contains(v.text.toLowerCase()));
              },
              onSelected: (String s) {
                _nameCtrl.text = s;
              },
              fieldViewBuilder: (BuildContext context, TextEditingController fieldController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                if (fieldController.text != _nameCtrl.text && fieldController.text.isEmpty) {
                  fieldController.text = _nameCtrl.text;
                }
                return TextField(
                  controller: fieldController,
                  focusNode: fieldFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Назва запчастини (пам\'ятає історію)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.history),
                  ),
                  onChanged: (v) {
                    _nameCtrl.text = v;
                  },
                );
              },
            ),
            const SizedBox(height: 12),

            // Вільно редагована категорія (Autocomplete з підтримкою власних варіантів)
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _categoryCtrl.text),
              optionsBuilder: (TextEditingValue v) {
                if (v.text.isEmpty) return _categoriesList;
                return _categoriesList.where((cat) => cat.toLowerCase().contains(v.text.toLowerCase()));
              },
              onSelected: (String s) {
                _categoryCtrl.text = s;
              },
              fieldViewBuilder: (BuildContext context, TextEditingController fieldController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                if (fieldController.text != _categoryCtrl.text && fieldController.text.isEmpty) {
                  fieldController.text = _categoryCtrl.text;
                }
                return TextField(
                  controller: fieldController,
                  focusNode: fieldFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Категорія (виберіть або впишіть свою)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.category),
                  ),
                  onChanged: (v) {
                    _categoryCtrl.text = v;
                  },
                );
              },
            ),
            const SizedBox(height: 12),

            TextField(controller: _art, decoration: const InputDecoration(labelText: 'Артикул / Код', border: OutlineInputBorder())),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qty, 
                    keyboardType: TextInputType.number, 
                    decoration: const InputDecoration(labelText: 'Кількість', border: OutlineInputBorder()),
                    onTap: () {
                      if (_qty.text == '1' && widget.part == null) _qty.selection = TextSelection(baseOffset: 0, extentOffset: _qty.text.length);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _minQty, 
                    keyboardType: TextInputType.number, 
                    decoration: const InputDecoration(labelText: 'Мін. залишок', border: OutlineInputBorder()),
                    onTap: () {
                      if (_minQty.text == '0' && widget.part == null) _minQty.selection = TextSelection(baseOffset: 0, extentOffset: _minQty.text.length);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _price, 
              keyboardType: TextInputType.number, 
              decoration: const InputDecoration(labelText: 'Ціна за одиницю (грн)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _brandCtrl.text),
              optionsBuilder: (TextEditingValue v) {
                if (v.text.isEmpty) return brandsList;
                return brandsList.where((b) => b.toLowerCase().contains(v.text.toLowerCase()));
              },
              onSelected: (String s) {
                setState(() {
                  _brandCtrl.text = s;
                  _modelCtrl.text = '';
                });
              },
              fieldViewBuilder: (BuildContext context, TextEditingController fieldController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: fieldController,
                  focusNode: fieldFocusNode,
                  decoration: const InputDecoration(labelText: 'Марка авто / техніки', border: OutlineInputBorder(), suffixIcon: Icon(Icons.search)),
                  onChanged: (v) {
                    _brandCtrl.text = v;
                  },
                );
              },
            ),
            const SizedBox(height: 12),

            Autocomplete<String>(
              initialValue: TextEditingValue(text: _modelCtrl.text),
              optionsBuilder: (TextEditingValue v) {
                final allowedModels = _modelsByBrand[_brandCtrl.text] ?? ['Загальна'];
                if (v.text.isEmpty) return allowedModels;
                return allowedModels.where((m) => m.toLowerCase().contains(v.text.toLowerCase()));
              },
              onSelected: (String s) {
                _modelCtrl.text = s;
              },
              fieldViewBuilder: (BuildContext context, TextEditingController fieldController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: fieldController,
                  focusNode: fieldFocusNode,
                  decoration: const InputDecoration(labelText: 'Модель (відповідно до марки)', border: OutlineInputBorder(), suffixIcon: Icon(Icons.search)),
                  onChanged: (v) {
                    _modelCtrl.text = v;
                  },
                );
              },
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _yearCtrl,
              decoration: const InputDecoration(
                labelText: 'Рік випуску / Покоління (напр. 2008 або B6)', 
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
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
                  'category': _categoryCtrl.text.trim().isNotEmpty ? _categoryCtrl.text.trim() : 'Загальне',
                  'article': _art.text.trim(),
                  'quantity': int.tryParse(_qty.text.trim()) ?? 1,
                  'minQuantity': int.tryParse(_minQty.text.trim()) ?? 0,
                  'price': double.tryParse(_price.text.trim()) ?? 0.0,
                  'brand': _brandCtrl.text.trim(),
                  'carModel': _modelCtrl.text.trim(),
                  'carYear': _yearCtrl.text.trim(),
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
