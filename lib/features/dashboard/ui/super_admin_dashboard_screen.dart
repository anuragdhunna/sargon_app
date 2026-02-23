import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:genui/genui.dart'; // Commented out due to missing Firebase AI dependencies
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/theme/app_design.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  static const routeName = '/super-admin-dashboard';

  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  bool _isLoading = false; // Set to true if GenUI is actively initializing

  @override
  void initState() {
    super.initState();
    _initGenUi();
  }

  void _initGenUi() {
    // Scaffold implementation for GenUi.
    // The 'genui_firebase_ai' package had a flutter dependency conflict
    // and requires Firebase Vertex AI credentials.
    // You can un-comment the GenUI imports and define a Conversation here
    // once your firebase_core versions align and credentials exist.
    /*
    _conversation = GenUiConversation(
      contentGenerator: FirebaseContentGenerator(...),
      catalog: Catalog(...),
      a2uiMessageProcessor: A2uiMessageProcessor(...),
      dataModel: DataModel(),
    );
    */
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Super Admin GenUI Dashboard'),
        backgroundColor: Colors.white,
      ),
      body: const SafeArea(child: _PaginatedFallbackDashboard()),
    );
  }
}

class _PaginatedFallbackDashboard extends StatefulWidget {
  const _PaginatedFallbackDashboard();

  @override
  State<_PaginatedFallbackDashboard> createState() =>
      _PaginatedFallbackDashboardState();
}

class _PaginatedFallbackDashboardState
    extends State<_PaginatedFallbackDashboard> {
  final List<dynamic> _hotels = [];
  bool _isLoading = false;
  bool _hasMore = true;
  dynamic _lastDoc;

  @override
  void initState() {
    super.initState();
    _fetchPaginatedHotels();
  }

  Future<void> _fetchPaginatedHotels() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final db = context.read<DatabaseService>();
      final newHotels = await db.getHotelsPaginated(
        limit: 10,
        startAfter: _lastDoc,
      );

      if (newHotels.isEmpty) {
        _hasMore = false;
      } else {
        _hotels.addAll(newHotels);
        _lastDoc = null; // Normally we save the actual DocumentSnapshot
      }
    } catch (e) {
      debugPrint('Error fetching paginated hotels: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDesign.space4),
          child: Text(
            'Hotel Performance (Fallback View)',
            style: AppDesign.titleLarge.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                _fetchPaginatedHotels();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: _hotels.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _hotels.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final hotel = _hotels[index];
                return ListTile(
                  title: Text(hotel.name),
                  subtitle: Text(hotel.address),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
