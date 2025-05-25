import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'map_screen.dart';
import '../providers/favorites_provider.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  bool _initialized = false;
  
  final List<Widget> _screens = [
    const SearchScreen(),
    const FavoritesScreen(),
    const MapScreen(),
  ];
  
  @override
  void initState() {
    super.initState();
    // Initialiser les favoris après le premier rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFavorites();
    });
  }
  
  // Initialiser les favoris avec les équipes françaises
  Future<void> _initializeFavorites() async {
    if (_initialized) return;
    
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final frenchTeams = _apiService.getFrenchTeams(); // Utiliser la méthode publique
    
    // Ajouter les équipes françaises aux favoris
    await favoritesProvider.addFrenchTeamsToFavorites(frenchTeams);
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
      ),
    );
  }
}
