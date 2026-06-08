import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

const appCream = Color(0xFFFFF8ED);
const appWarmCream = Color(0xFFFFEED4);
const appCard = Color(0xFFFFFCF7);
const appPeach = Color(0xFFF6D3A4);
const appTan = Color(0xFFD9B88F);
const appTerracotta = Color(0xFFA65F46);
const appOlive = Color(0xFF8C7E5B);
const appEspresso = Color(0xFF2A1814);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (hasSupabaseConfig) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabasePublishableKey,
    );
  }

  runApp(const WardrobeApp());
}

class WardrobeApp extends StatelessWidget {
  const WardrobeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wardrobe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: appTerracotta,
              brightness: Brightness.light,
            ).copyWith(
              primary: appTerracotta,
              onPrimary: Colors.white,
              primaryContainer: appWarmCream,
              onPrimaryContainer: appEspresso,
              secondary: appOlive,
              secondaryContainer: appPeach,
              surface: appCard,
              onSurface: appEspresso,
            ),
        scaffoldBackgroundColor: appCream,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: appCard,
          indicatorColor: appWarmCream,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? appEspresso
                  : appEspresso.withAlpha(150),
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? appTerracotta
                  : appEspresso.withAlpha(150),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: appCard,
          selectedColor: appWarmCream,
          disabledColor: appCard,
          labelStyle: const TextStyle(
            color: appEspresso,
            fontWeight: FontWeight.w700,
          ),
          side: const BorderSide(color: Color(0xFFF0DEC6)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: appTerracotta),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: appTerracotta,
            backgroundColor: appWarmCream,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: appEspresso,
            foregroundColor: appCard,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: appCard,
          prefixIconColor: appTerracotta,
          suffixIconColor: appTerracotta,
          hintStyle: TextStyle(color: appEspresso.withAlpha(120)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFF0DEC6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFF0DEC6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: appTerracotta, width: 1.4),
          ),
        ),
        textTheme: Typography.blackCupertino.apply(
          bodyColor: appEspresso,
          displayColor: appEspresso,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _openWardrobe() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WardrobeShell()),
    );
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!hasSupabaseConfig) {
      setState(() {
        _errorMessage =
            'Add your Supabase URL and publishable key before logging in.';
      });
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Enter your email and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        _openWardrobe();
      }
    } on AuthException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Unable to sign in right now.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).vertical -
                  58,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LoginHeader(),
                const SizedBox(height: 34),
                TextField(
                  controller: _emailController,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'name@example.com',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _signIn(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: appTerracotta,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: appCard,
                          ),
                        )
                      : const Text('Log In'),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Continue with style profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: appEspresso,
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: Color(0xFFF0DEC6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New here?',
                      style: TextStyle(color: appEspresso.withAlpha(150)),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Create account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: appWarmCream,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFF1DFC8)),
          ),
          child: const Icon(Icons.checkroom, color: appTerracotta, size: 38),
        ),
        const SizedBox(height: 28),
        Text(
          'Welcome back',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to plan outfits, review your wardrobe, and get dressed for the day.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: appEspresso.withAlpha(165),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class WardrobeShell extends StatefulWidget {
  const WardrobeShell({super.key});

  @override
  State<WardrobeShell> createState() => _WardrobeShellState();
}

class _WardrobeShellState extends State<WardrobeShell> {
  int _selectedIndex = 2;

  static const _pages = [
    WardrobePage(),
    CalendarPage(),
    HomePage(),
    ExplorePage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checkroom_outlined),
            selectedIcon: Icon(Icons.checkroom),
            label: 'Wardrobe',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.travel_explore_outlined),
            selectedIcon: Icon(Icons.travel_explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Today',
      subtitle: 'Warm afternoon, light breeze',
      children: [
        const ForecastCard(),
        SectionHeader(
          title: 'Recommended Outfits',
          actionLabel: 'Refresh',
          onPressed: () {},
        ),
        OutfitRecommendation(
          title: 'Cafe catch-up',
          description: 'Linen shirt, straight jeans, leather sandals',
          icon: Icons.local_cafe,
          colors: const [appWarmCream, appOlive, appTerracotta],
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OutfitDetailPage(
                  title: 'Cafe catch-up',
                  description: 'Linen shirt, straight jeans, leather sandals',
                  icon: Icons.local_cafe,
                  colors: [appWarmCream, appOlive, appTerracotta],
                  pieces: [
                    OutfitPiece('Linen shirt', 'Tops', color: appPeach, icon: Icons.dry_cleaning),
                    OutfitPiece('Straight jeans', 'Bottoms', color: appOlive, icon: Icons.style),
                    OutfitPiece('Leather sandals', 'Shoes', color: appEspresso, icon: Icons.ice_skating),
                  ],
                ),
              ),
            );
          },
        ),
        OutfitRecommendation(
          title: 'Evening errands',
          description: 'Ribbed tank, relaxed trousers, cropped overshirt',
          icon: Icons.shopping_bag_outlined,
          colors: const [appPeach, appEspresso, appTan],
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OutfitDetailPage(
                  title: 'Evening errands',
                  description: 'Ribbed tank, relaxed trousers, cropped overshirt',
                  icon: Icons.shopping_bag_outlined,
                  colors: [appPeach, appEspresso, appTan],
                  pieces: [
                    OutfitPiece('Ribbed tank', 'Tops', color: appPeach, icon: Icons.dry_cleaning),
                    OutfitPiece('Relaxed trousers', 'Bottoms', color: appOlive, icon: Icons.style),
                    OutfitPiece('Cropped overshirt', 'Outerwear', color: appWarmCream, icon: Icons.layers),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class OutfitDetailPage extends StatelessWidget {
  const OutfitDetailPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
    required this.pieces,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<Color> colors;
  final List<OutfitPiece> pieces;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: appWarmCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF1DFC8),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 56, color: appEspresso.withAlpha(60)),
                  const SizedBox(height: 10),
                  Text(
                    'Outfit image',
                    style: TextStyle(
                      color: appEspresso.withAlpha(120),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: appEspresso.withAlpha(180),
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: colors.map((color) {
                return Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: appEspresso.withAlpha(35)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Text(
              'Pieces',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              itemCount: pieces.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (context, index) {
                final piece = pieces[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => WardrobeDetailPage(
                          item: WardrobeItem(
                            piece.name,
                            piece.category,
                            piece.color ?? appTan,
                            piece.icon ?? Icons.checkroom_outlined,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: cardDecoration(appCard),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          piece.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          piece.category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: appEspresso.withAlpha(150),
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  final _allItems = <WardrobeItem>[
    const WardrobeItem('Silk blouse', 'Tops', appPeach, Icons.dry_cleaning, subColor: appWarmCream),
    const WardrobeItem('Wide-leg jeans', 'Bottoms', appOlive, Icons.style, subColor: appTan),
    const WardrobeItem('Trench coat', 'Outerwear', appWarmCream, Icons.layers, subColor: appCard),
    const WardrobeItem('Loafers', 'Shoes', appEspresso, Icons.ice_skating, subColor: appCream),
    const WardrobeItem('Midi dress', 'Dresses', appTerracotta, Icons.woman, subColor: appPeach),
    const WardrobeItem('Tote bag', 'Accessories', appTan, Icons.work_outline, subColor: appOlive),
  ];

  static const _categories = [
    'All',
    'Tops',
    'Bottoms',
    'Outerwear',
    'Shoes',
    'Dresses',
    'Accessories',
  ];

  String _selectedCategory = 'All';

  List<WardrobeItem> get _filteredItems => _selectedCategory == 'All'
      ? _allItems
      : _allItems.where((i) => i.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return AppPage(
      title: 'Wardrobe',
      subtitle: '${filtered.length} saved pieces',
      trailing: IconButton.filledTonal(
        onPressed: () async {
          final item = await Navigator.of(context).push<WardrobeItem>(
            MaterialPageRoute(builder: (_) => const AddItemPage()),
          );
          if (item != null && mounted) {
            setState(() => _allItems.add(item));
          }
        },
        icon: const Icon(Icons.add),
      ),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final selected = _selectedCategory == category;
            return FilterChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) {
                setState(() => _selectedCategory = category);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          itemCount: filtered.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.82,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemBuilder: (context, index) => WardrobeTile(
            item: filtered[index],
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WardrobeDetailPage(item: filtered[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  String _selectedCategory = 'Tops';
  String? _selectedSubColor;
  String? _imagePath;

  static const _categories = [
    'Tops',
    'Bottoms',
    'Outerwear',
    'Shoes',
    'Dresses',
    'Accessories',
  ];

  static const _iconMap = {
    'Tops': Icons.dry_cleaning,
    'Bottoms': Icons.style,
    'Outerwear': Icons.layers,
    'Shoes': Icons.ice_skating,
    'Dresses': Icons.woman,
    'Accessories': Icons.work_outline,
  };

  static const _colorMap = {
    'Tops': appPeach,
    'Bottoms': appOlive,
    'Outerwear': appWarmCream,
    'Shoes': appEspresso,
    'Dresses': appTerracotta,
    'Accessories': appTan,
  };

  static const _subColors = {
    'None': null,
    'White': Color(0xFFFFFFFF),
    'Cream': Color(0xFFFFF8ED),
    'Beige': Color(0xFFF5DEB3),
    'Tan': Color(0xFFD9B88F),
    'Olive': Color(0xFF8C7E5B),
    'Navy': Color(0xFF1A2F4C),
    'Gray': Color(0xFF9E9E9E),
    'Burgundy': Color(0xFF6B1C32),
    'Denim': Color(0xFF597A9E),
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xFile != null && mounted) {
      setState(() => _imagePath = xFile.path);
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final item = WardrobeItem(
      name,
      _selectedCategory,
      _colorMap[_selectedCategory]!,
      _iconMap[_selectedCategory]!,
      imagePath: _imagePath,
      subColor: _subColors[_selectedSubColor],
    );
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add item'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: appWarmCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF1DFC8),
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imagePath != null
                    ? Image.file(
                        File(_imagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 44,
                            color: appEspresso.withAlpha(80),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add photo',
                            style: TextStyle(
                              color: appEspresso.withAlpha(120),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Black jeans',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _selectedSubColor,
              decoration: const InputDecoration(
                labelText: 'Sub colour',
                prefixIcon: Icon(Icons.color_lens_outlined),
              ),
              items: _subColors.entries.map((entry) {
                final color = entry.value;
                return DropdownMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: color ?? Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD9B88F)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(entry.key),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedSubColor = value);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class WardrobeDetailPage extends StatelessWidget {
  const WardrobeDetailPage({required this.item, super.key});

  final WardrobeItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                color: item.color.withAlpha(46),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: item.imagePath != null
                  ? Image.file(
                      File(item.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        item.icon,
                        size: 80,
                        color: item.color,
                      ),
                    )
                  : Icon(item.icon, size: 80, color: item.color),
            ),
            const SizedBox(height: 20),
            Text(
              item.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              item.category,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: appEspresso.withAlpha(150),
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ColorSwatch(
                    label: 'Primary colour',
                    color: item.color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ColorSwatch(
                    label: 'Sub colour',
                    color: item.subColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, required this.label});

  final Color? color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(appCard),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color ?? Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: appTan),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: appEspresso.withAlpha(150),
                      ),
                ),
                Text(
                  color != null
                      ? '#${(color!.r * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}${(color!.g * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}${(color!.b * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}'
                      : 'None',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _events = <CalendarEvent>[
    const CalendarEvent(
      day: '29',
      month: 'May',
      title: 'Client lunch',
      occasion: 'Smart casual',
      icon: Icons.restaurant_outlined,
    ),
    const CalendarEvent(
      day: '31',
      month: 'May',
      title: 'Gallery opening',
      occasion: 'Creative evening',
      icon: Icons.palette_outlined,
    ),
    const CalendarEvent(
      day: '03',
      month: 'Jun',
      title: 'Outdoor brunch',
      occasion: 'Relaxed daytime',
      icon: Icons.wb_sunny_outlined,
    ),
  ];

  Future<void> _editEvent(int index) async {
    final updated = await Navigator.of(context).push<CalendarEvent>(
      MaterialPageRoute(
        builder: (_) => EditEventPage(event: _events[index]),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _events[index] = updated);
    }
  }

  Future<void> _addEvent() async {
    final event = await Navigator.of(context).push<CalendarEvent>(
      MaterialPageRoute(builder: (_) => const AddEventPage()),
    );
    if (event != null && mounted) {
      setState(() => _events.add(event));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Calendar',
      subtitle: 'Plan outfits around your week',
      trailing: IconButton.filledTonal(
        onPressed: _addEvent,
        icon: const Icon(Icons.add),
      ),
      children: _events.asMap().entries.map((entry) {
        final index = entry.key;
        final event = entry.value;
        return EventCard(
          day: event.day,
          month: event.month,
          title: event.title,
          occasion: event.occasion,
          icon: event.icon,
          onTap: () => _editEvent(index),
        );
      }).toList(),
    );
  }
}

class EditEventPage extends StatefulWidget {
  const EditEventPage({required this.event, super.key});

  final CalendarEvent event;

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late final _dayController = TextEditingController(text: widget.event.day);
  late final _monthController = TextEditingController(text: widget.event.month);
  late final _titleController = TextEditingController(text: widget.event.title);
  late final _occasionController = TextEditingController(text: widget.event.occasion);
  late IconData _icon = widget.event.icon;

  static const _iconChoices = {
    'Restaurant': Icons.restaurant_outlined,
    'Palette': Icons.palette_outlined,
    'Sunny': Icons.wb_sunny_outlined,
    'Work': Icons.work_outline,
    'Celebration': Icons.celebration_outlined,
    'Flight': Icons.flight_outlined,
    'Music': Icons.music_note_outlined,
    'Fitness': Icons.fitness_center_outlined,
    'Coffee': Icons.coffee_outlined,
    'Shopping': Icons.shopping_bag_outlined,
  };

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _titleController.dispose();
    _occasionController.dispose();
    super.dispose();
  }

  void _save() {
    final day = _dayController.text.trim();
    final month = _monthController.text.trim();
    final title = _titleController.text.trim();
    final occasion = _occasionController.text.trim();

    if (day.isEmpty || month.isEmpty || title.isEmpty) return;

    final updated = CalendarEvent(
      day: day,
      month: month,
      title: title,
      occasion: occasion,
      icon: _icon,
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    String? selectedIconLabel;
    for (final entry in _iconChoices.entries) {
      if (entry.value == _icon) {
        selectedIconLabel = entry.key;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit event'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dayController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      hintText: '29',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: _monthController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      hintText: 'May',
                      prefixIcon: Icon(Icons.event),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Client lunch',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _occasionController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Occasion',
                hintText: 'e.g. Smart casual',
                prefixIcon: Icon(Icons.style),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: selectedIconLabel,
              decoration: const InputDecoration(
                labelText: 'Icon',
                prefixIcon: Icon(Icons.emoji_events_outlined),
              ),
              items: _iconChoices.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(entry.value, size: 20),
                      const SizedBox(width: 10),
                      Text(entry.key),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _icon = _iconChoices[value]!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _titleController = TextEditingController();
  final _occasionController = TextEditingController();
  IconData _icon = Icons.restaurant_outlined;

  static const _iconChoices = {
    'Restaurant': Icons.restaurant_outlined,
    'Palette': Icons.palette_outlined,
    'Sunny': Icons.wb_sunny_outlined,
    'Work': Icons.work_outline,
    'Celebration': Icons.celebration_outlined,
    'Flight': Icons.flight_outlined,
    'Music': Icons.music_note_outlined,
    'Fitness': Icons.fitness_center_outlined,
    'Coffee': Icons.coffee_outlined,
    'Shopping': Icons.shopping_bag_outlined,
  };

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _titleController.dispose();
    _occasionController.dispose();
    super.dispose();
  }

  void _save() {
    final day = _dayController.text.trim();
    final month = _monthController.text.trim();
    final title = _titleController.text.trim();
    final occasion = _occasionController.text.trim();

    if (day.isEmpty || month.isEmpty || title.isEmpty) return;

    final event = CalendarEvent(
      day: day,
      month: month,
      title: title,
      occasion: occasion,
      icon: _icon,
    );
    Navigator.of(context).pop(event);
  }

  @override
  Widget build(BuildContext context) {
    String? selectedIconLabel;
    for (final entry in _iconChoices.entries) {
      if (entry.value == _icon) {
        selectedIconLabel = entry.key;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add event'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dayController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      hintText: '29',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: _monthController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      hintText: 'May',
                      prefixIcon: Icon(Icons.event),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Client lunch',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _occasionController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Occasion',
                hintText: 'e.g. Smart casual',
                prefixIcon: Icon(Icons.style),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: selectedIconLabel,
              decoration: const InputDecoration(
                labelText: 'Icon',
                prefixIcon: Icon(Icons.emoji_events_outlined),
              ),
              items: _iconChoices.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(entry.value, size: 20),
                      const SizedBox(width: 10),
                      Text(entry.key),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _icon = _iconChoices[value]!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Explore',
      subtitle: 'Newsletters and trend notes',
      children: [
        TrendCard(
          title: 'Light layers for humid weather',
          category: 'Trend report',
          icon: Icons.air,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ArticlePage(
                  title: 'Light layers for humid weather',
                  category: 'Trend report',
                  icon: Icons.air,
                  author: 'Mira Chen',
                  date: 'May 28, 2026',
                ),
              ),
            );
          },
        ),
        TrendCard(
          title: 'How stylists are wearing silver accents',
          category: 'Newsletter',
          icon: Icons.auto_awesome,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ArticlePage(
                  title: 'How stylists are wearing silver accents',
                  category: 'Newsletter',
                  icon: Icons.auto_awesome,
                  author: 'Jordan Park',
                  date: 'May 25, 2026',
                ),
              ),
            );
          },
        ),
        TrendCard(
          title: 'Capsule colors that still feel personal',
          category: 'Guide',
          icon: Icons.color_lens_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ArticlePage(
                  title: 'Capsule colors that still feel personal',
                  category: 'Guide',
                  icon: Icons.color_lens_outlined,
                  author: 'Reese Alvarado',
                  date: 'May 20, 2026',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ArticlePage extends StatelessWidget {
  const ArticlePage({
    required this.title,
    required this.category,
    required this.icon,
    required this.author,
    required this.date,
    super.key,
  });

  final String title;
  final String category;
  final IconData icon;
  final String author;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: appWarmCream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 64, color: appEspresso.withAlpha(60)),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: appPeach.withAlpha(50),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  color: appTerracotta,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: appPeach.withAlpha(80),
                  child: Text(
                    author[0].toUpperCase(),
                    style: const TextStyle(
                      color: appTerracotta,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  author,
                  style: TextStyle(
                    color: appEspresso.withAlpha(180),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  date,
                  style: TextStyle(
                    color: appEspresso.withAlpha(100),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.7,
                    color: appEspresso.withAlpha(200),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _newsletters = true;
  bool _weather = false;
  bool _outfitReminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _buildToggle(
            icon: Icons.email_outlined,
            title: 'Newsletters',
            subtitle: 'Trend reports, guides, and style tips',
            value: _newsletters,
            onChanged: (v) => setState(() => _newsletters = v),
          ),
          _buildToggle(
            icon: Icons.cloud_outlined,
            title: 'Weather changes',
            subtitle: 'Outfit suggestions when the forecast shifts',
            value: _weather,
            onChanged: (v) => setState(() => _weather = v),
          ),
          _buildToggle(
            icon: Icons.access_time_outlined,
            title: 'Outfit reminders',
            subtitle: 'Daily nudge to check your planned outfits',
            value: _outfitReminders,
            onChanged: (v) => setState(() => _outfitReminders = v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(appCard),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: appWarmCream,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: appEspresso.withAlpha(180)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: appEspresso.withAlpha(150),
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: appTerracotta,
          ),
        ],
      ),
    );
  }
}

class PersonalizationPage extends StatefulWidget {
  const PersonalizationPage({required this.profile, super.key});

  final UserProfile profile;

  @override
  State<PersonalizationPage> createState() => _PersonalizationPageState();
}

class _PersonalizationPageState extends State<PersonalizationPage> {
  late final _displayNameController = TextEditingController(
    text: widget.profile.displayName,
  );
  late final _emailController = TextEditingController(
    text: widget.profile.email,
  );
  late final _dobController = TextEditingController(
    text: widget.profile.dateOfBirth,
  );

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _save() {
    final displayName = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final dob = _dobController.text.trim();

    if (displayName.isEmpty || email.isEmpty) return;

    Navigator.of(context).pop(UserProfile(
      displayName: displayName,
      email: email,
      dateOfBirth: dob.isEmpty ? 'Not set' : dob,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalisation'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _displayNameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Display name',
                hintText: 'e.g. Jane Smith',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _dobController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Date of birth',
                hintText: 'YYYY-MM-DD',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _message = 'All fields are required.';
        _isError = true;
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _message = 'New passwords do not match.';
        _isError = true;
      });
      return;
    }

    final email = Supabase.instance.client.auth.currentUser?.email;
    if (email == null) {
      setState(() {
        _message = 'Unable to verify your account. Please sign in again.';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (mounted) {
        setState(() {
          _message = 'Password updated successfully.';
          _isError = false;
          _isLoading = false;
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _message = e.message;
          _isError = true;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = 'Something went wrong. Try again.';
          _isError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: _obscureOld,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Current password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureOld
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureOld = !_obscureOld),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'New password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm new password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isError ? appTerracotta : appOlive,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: appCard,
                      ),
                    )
                  : const Text('Update password'),
            ),
          ],
        ),
      ),
    );
  }
}

class StylePreferencesPage extends StatelessWidget {
  const StylePreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Style preferences'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isSigningOut = false;
  UserProfile _profile = const UserProfile(
    displayName: 'Your Wardrobe',
    email: 'you@example.com',
    dateOfBirth: 'Not set',
  );

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Account',
      subtitle: 'Preferences and privacy',
      children: [
        ProfileCard(
          displayName: _profile.displayName,
          subtitle: _profile.email,
          onTap: () async {
            final updated = await Navigator.of(context).push<UserProfile>(
              MaterialPageRoute(
                builder: (_) => PersonalizationPage(profile: _profile),
              ),
            );
            if (updated != null && mounted) {
              setState(() => _profile = updated);
            }
          },
        ),
        SettingsTile(
          icon: Icons.lock_outline,
          title: 'Password',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
            );
          },
        ),
        SettingsTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            );
          },
        ),
        SettingsTile(
          icon: Icons.tune,
          title: 'Style preferences',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StylePreferencesPage()),
            );
          },
        ),
        SettingsTile(
          icon: Icons.settings_outlined,
          title: 'App settings',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AppSettingsPage()),
            );
          },
        ),
        const SizedBox(height: 24),
        SettingsTile(
          icon: Icons.logout,
          title: 'Log out',
          onTap: _isSigningOut ? null : _signOut,
        ),
      ],
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({
    required this.title,
    required this.subtitle,
    required this.children,
    this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: appEspresso.withAlpha(165),
                        ),
                      ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          sliver: SliverList.separated(
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
            separatorBuilder: (context, index) => const SizedBox(height: 14),
          ),
        ),
      ],
    );
  }
}

class ForecastCard extends StatelessWidget {
  const ForecastCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(appWarmCream),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: appCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.cloud_queue,
              color: appTerracotta,
              size: 38,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '31 C / Cloudy',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: appEspresso,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose breathable layers and shoes that can handle a quick shower.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: appEspresso.withAlpha(170),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OutfitRecommendation extends StatelessWidget {
  const OutfitRecommendation({
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
    this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: onTap,
      leading: Icon(icon),
      title: title,
      subtitle: description,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: colors
            .map(
              (color) => Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: appEspresso.withAlpha(35)),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class WardrobeTile extends StatelessWidget {
  const WardrobeTile({required this.item, this.onTap, super.key});

  final WardrobeItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(appCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: item.color.withAlpha(46),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: item.imagePath != null
                    ? Image.file(
                        File(item.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                        item.icon,
                        size: 46,
                        color: item.color,
                      ),
                    )
                  : Icon(item.icon, size: 46, color: item.color),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            item.category,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: appEspresso.withAlpha(150)),
          ),
        ],
      ),
    ),
  );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({
    required this.day,
    required this.month,
    required this.title,
    required this.occasion,
    required this.icon,
    this.onTap,
    super.key,
  });

  final String day;
  final String month;
  final String title;
  final String occasion;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: onTap,
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 19,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            month,
            style: TextStyle(
              color: appEspresso.withAlpha(150),
              fontSize: 12,
              height: 1,
            ),
          ),
        ],
      ),
      title: title,
      subtitle: occasion,
      trailing: Icon(icon),
    );
  }
}

class TrendCard extends StatelessWidget {
  const TrendCard({
    required this.title,
    required this.category,
    required this.icon,
    this.onTap,
    super.key,
  });

  final String title;
  final String category;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: onTap,
      leading: Icon(icon),
      title: title,
      subtitle: category,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.displayName,
    required this.subtitle,
    this.onTap,
    super.key,
  });

  final String displayName;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: cardDecoration(appCard),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: appWarmCream,
              child: Icon(Icons.person, color: appTerracotta, size: 34),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: appTan),
          ],
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({required this.icon, required this.title, this.onTap, super.key});

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      leading: Icon(icon),
      title: title,
      subtitle: 'Manage $title',
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration(appCard),
        child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: appWarmCream,
              borderRadius: BorderRadius.circular(8),
            ),
            foregroundDecoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFF1DFC8)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: leading,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: appEspresso.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onPressed,
    super.key,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    );
  }
}

BoxDecoration cardDecoration(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: const Color(0xFFF3E3CC)),
    boxShadow: [
      BoxShadow(
        color: appTan.withAlpha(35),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

class WardrobeItem {
  const WardrobeItem(this.name, this.category, this.color, this.icon, {this.imagePath, this.subColor});

  final String name;
  final String category;
  final Color color;
  final IconData icon;
  final String? imagePath;
  final Color? subColor;
}

class CalendarEvent {
  const CalendarEvent({
    required this.day,
    required this.month,
    required this.title,
    required this.occasion,
    required this.icon,
  });

  final String day;
  final String month;
  final String title;
  final String occasion;
  final IconData icon;

  CalendarEvent copyWith({
    String? day,
    String? month,
    String? title,
    String? occasion,
    IconData? icon,
  }) {
    return CalendarEvent(
      day: day ?? this.day,
      month: month ?? this.month,
      title: title ?? this.title,
      occasion: occasion ?? this.occasion,
      icon: icon ?? this.icon,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.email,
    required this.dateOfBirth,
  });

  final String displayName;
  final String email;
  final String dateOfBirth;
}

class OutfitPiece {
  const OutfitPiece(this.name, this.category, {this.color, this.icon});

  final String name;
  final String category;
  final Color? color;
  final IconData? icon;
}
