import 'package:uuid/uuid.dart';

import '../../inventory_index.dart';

/// Cubit for managing vendor operations
///
/// Handles CRUD operations for vendors and provides
/// vendor selection functionality for PO creation
class VendorCubit extends Cubit<VendorState> {
  VendorCubit() : super(VendorInitial()) {
    loadVendors();
  }

  final _uuid = const Uuid();
  final List<Vendor> _mockVendors = [];

  /// Load all vendors
  void loadVendors() async {
    emit(VendorLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    if (_mockVendors.isEmpty) {
      _initializeMockData();
    }

    emit(VendorLoaded(List.from(_mockVendors)));
  }

  /// Initialize mock vendor data
  void _initializeMockData() {
    final now = DateTime.now();

    _mockVendors.addAll([
      Vendor(
        id: 'vendor_001',
        name: 'Fresh Dairy Farms',
        category: VendorCategory.dairy,
        contactPerson: 'Rajesh Kumar',
        phoneNumber: '+91 98765 43210',
        email: 'rajesh@freshdairy.com',
        address: 'Plot 45, Dairy Road, Mumbai',
        paymentTerms: PaymentTerms.net30,
        isPreferred: true,
        creditLimit: 100000,
        gstNumber: '27AABCU9603R1ZM',
        createdAt: now.subtract(const Duration(days: 180)),
      ),
      Vendor(
        id: 'vendor_002',
        name: 'Green Valley Vegetables',
        category: VendorCategory.vegetables,
        contactPerson: 'Amit Patel',
        phoneNumber: '+91 98765 43211',
        email: 'amit@greenvalley.com',
        address: 'Farm House 12, Pune Road',
        paymentTerms: PaymentTerms.net15,
        isPreferred: true,
        creditLimit: 50000,
        gstNumber: '27AABCU9603R1ZN',
        createdAt: now.subtract(const Duration(days: 150)),
      ),
      Vendor(
        id: 'vendor_003',
        name: 'Premium Beverages Ltd',
        category: VendorCategory.beverages,
        contactPerson: 'Suresh Sharma',
        phoneNumber: '+91 98765 43212',
        email: 'suresh@premiumbev.com',
        address: 'Industrial Area, Sector 5, Delhi',
        paymentTerms: PaymentTerms.net30,
        isPreferred: true,
        creditLimit: 200000,
        gstNumber: '07AABCU9603R1ZO',
        createdAt: now.subtract(const Duration(days: 200)),
      ),
      Vendor(
        id: 'vendor_004',
        name: 'Quality Meats & Poultry',
        category: VendorCategory.meat,
        contactPerson: 'Mohammed Ali',
        phoneNumber: '+91 98765 43213',
        email: 'ali@qualitymeats.com',
        address: 'Cold Storage Complex, Bangalore',
        paymentTerms: PaymentTerms.net7,
        isPreferred: false,
        creditLimit: 75000,
        gstNumber: '29AABCU9603R1ZP',
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      Vendor(
        id: 'vendor_005',
        name: 'Sparkle Housekeeping Supplies',
        category: VendorCategory.housekeeping,
        contactPerson: 'Priya Singh',
        phoneNumber: '+91 98765 43214',
        email: 'priya@sparklesupplies.com',
        address: 'Warehouse 8, Hyderabad',
        paymentTerms: PaymentTerms.net30,
        isPreferred: true,
        creditLimit: 60000,
        gstNumber: '36AABCU9603R1ZQ',
        createdAt: now.subtract(const Duration(days: 120)),
      ),
    ]);
  }

  /// Create a new vendor
  void createVendor({
    required String name,
    required VendorCategory category,
    required String contactPerson,
    required String phoneNumber,
    String? email,
    String? address,
    PaymentTerms paymentTerms = PaymentTerms.net30,
    bool isPreferred = false,
    double? creditLimit,
    String? gstNumber,
  }) {
    final vendor = Vendor(
      id: _uuid.v4(),
      name: name,
      category: category,
      contactPerson: contactPerson,
      phoneNumber: phoneNumber,
      email: email,
      address: address,
      paymentTerms: paymentTerms,
      isPreferred: isPreferred,
      creditLimit: creditLimit,
      gstNumber: gstNumber,
      createdAt: DateTime.now(),
    );

    _mockVendors.insert(0, vendor);
    emit(VendorLoaded(List.from(_mockVendors)));
  }

  /// Get vendor by ID
  Vendor? getVendorById(String id) {
    try {
      return _mockVendors.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get vendors by category
  List<Vendor> getVendorsByCategory(VendorCategory category) {
    return _mockVendors.where((v) => v.category == category).toList();
  }

  /// Get preferred vendors
  List<Vendor> getPreferredVendors() {
    return _mockVendors.where((v) => v.isPreferred).toList();
  }

  /// Search vendors
  List<Vendor> searchVendors(String query) {
    if (query.isEmpty) return _mockVendors;

    final lowerQuery = query.toLowerCase();
    return _mockVendors.where((v) {
      return v.name.toLowerCase().contains(lowerQuery) ||
          v.contactPerson.toLowerCase().contains(lowerQuery) ||
          v.phoneNumber.contains(query);
    }).toList();
  }
}
