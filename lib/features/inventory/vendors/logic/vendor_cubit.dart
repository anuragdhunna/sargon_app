import 'package:uuid/uuid.dart';
import '../../inventory_index.dart';

/// Cubit for managing vendor operations
///
/// Handles CRUD operations for vendors and provides
/// vendor selection functionality for PO creation
class VendorCubit extends Cubit<VendorState> {
  final IInventoryRepository _repository;

  VendorCubit({IInventoryRepository? repository})
    : _repository = repository ?? InventoryRepository(),
      super(VendorInitial()) {
    loadVendors();
  }

  final _uuid = const Uuid();
  final List<Vendor> _vendors = [];

  /// Load all vendors
  Future<void> loadVendors() async {
    emit(VendorLoading());
    try {
      final vendors = await _repository.getVendors();
      _vendors.clear();
      _vendors.addAll(vendors);
      emit(VendorLoaded(List.from(_vendors)));
    } catch (e) {
      emit(VendorError('Failed to load vendors: ${e.toString()}'));
    }
  }

  /// Create a new vendor
  Future<void> createVendor({
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
  }) async {
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

    try {
      await _repository.saveVendor(vendor);
      _vendors.insert(0, vendor);
      emit(VendorLoaded(List.from(_vendors)));
    } catch (e) {
      emit(VendorError('Failed to create vendor: ${e.toString()}'));
    }
  }

  /// Get vendor by ID
  Vendor? getVendorById(String id) {
    try {
      return _vendors.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get vendors by category
  List<Vendor> getVendorsByCategory(VendorCategory category) {
    return _vendors.where((v) => v.category == category).toList();
  }

  /// Get preferred vendors
  List<Vendor> getPreferredVendors() {
    return _vendors.where((v) => v.isPreferred).toList();
  }

  /// Search vendors
  List<Vendor> searchVendors(String query) {
    if (query.isEmpty) return _vendors;

    final lowerQuery = query.toLowerCase();
    return _vendors.where((v) {
      return v.name.toLowerCase().contains(lowerQuery) ||
          v.contactPerson.toLowerCase().contains(lowerQuery) ||
          v.phoneNumber.contains(query);
    }).toList();
  }
}
