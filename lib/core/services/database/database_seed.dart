part of '../database_service.dart';

/// Seeds demo data for a new hotel tenant when collections are empty.
extension DatabaseSeed on DatabaseService {
  Future<bool> _isCollectionEmpty(CollectionReference ref) async {
    final snapshot = await ref.limit(1).get();
    return snapshot.docs.isEmpty;
  }

  /// Bootstrap all entity collections with demo data if empty.
  Future<void> initializeDummyData(String hotelId) async {
    try {
      debugPrint('🌱 Seeding dummy data for hotel $hotelId...');

      await initializeBillingDefaults(hotelId);
      await initializeDummySettings(hotelId);
      await initializeDummyTables(hotelId);
      await initializeDummyRooms(hotelId);
      await initializeDummyMenu(hotelId);
      await initializeDummyInventory(hotelId);
      await initializeDummyCustomers(hotelId);
      await initializeDummyLoyalty(hotelId);
      await initializeDummyOffers(hotelId);
      await initializeDummyChecklists(hotelId);
      await initializeDummyIncidents(hotelId);
      await initializeDummyEvents(hotelId);
      await initializeDummyBookings(hotelId);
      await initializeDummyOrders(hotelId);
      await initializeDummyAuditLogs(hotelId);

      debugPrint('✅ Dummy data seeding complete');
    } catch (e) {
      debugPrint('❌ Error seeding dummy data: $e');
    }
  }

  Future<void> initializeDummySettings(String hotelId) async {
    final ref = _hotelDoc(hotelId).collection('settings');
    if (!await _isCollectionEmpty(ref)) return;

    await updateAppSettings(
      AppSettings(id: 'config', hotelId: hotelId, requiresPOApproval: true),
    );
  }

  Future<void> initializeDummyTables(String hotelId) async {
    final ref = _hotelDoc(hotelId).collection('tables');
    if (!await _isCollectionEmpty(ref)) return;

    final tables = [
      TableEntity(
        hotelId: hotelId,
        id: 't1',
        name: 'Window Table 1',
        tableCode: 'T1',
        maxCapacity: 4,
        status: TableStatus.available,
      ),
      TableEntity(
        hotelId: hotelId,
        id: 't2',
        name: 'Window Table 2',
        tableCode: 'T2',
        maxCapacity: 4,
        status: TableStatus.occupied,
      ),
      TableEntity(
        hotelId: hotelId,
        id: 't3',
        name: 'Center Table 3',
        tableCode: 'T3',
        maxCapacity: 6,
        status: TableStatus.reserved,
      ),
      TableEntity(
        hotelId: hotelId,
        id: 'b1',
        name: 'Bar Counter 1',
        tableCode: 'B1',
        maxCapacity: 1,
        status: TableStatus.available,
        isBarTable: true,
      ),
    ];

    for (final table in tables) {
      await saveTable(table);
    }
  }

  Future<void> initializeDummyRooms(String hotelId) async {
    final ref = _hotelDoc(hotelId).collection('rooms');
    if (!await _isCollectionEmpty(ref)) return;

    final rooms = [
      Room(
        id: 'r101',
        hotelId: hotelId,
        roomNumber: '101',
        type: RoomType.single,
        status: RoomStatus.available,
        pricePerNight: 2500,
        floor: 1,
        capacity: 1,
        amenities: const ['WiFi', 'AC', 'TV'],
      ),
      Room(
        id: 'r102',
        hotelId: hotelId,
        roomNumber: '102',
        type: RoomType.double,
        status: RoomStatus.occupied,
        pricePerNight: 3500,
        floor: 1,
        capacity: 2,
        amenities: const ['WiFi', 'AC', 'TV', 'Mini Bar'],
      ),
      Room(
        id: 'r201',
        hotelId: hotelId,
        roomNumber: '201',
        type: RoomType.suite,
        status: RoomStatus.available,
        pricePerNight: 7500,
        floor: 2,
        capacity: 4,
        amenities: const ['WiFi', 'AC', 'TV', 'Mini Bar', 'Jacuzzi'],
      ),
    ];

    for (final room in rooms) {
      await saveRoom(room);
    }
  }

  Future<void> initializeDummyMenu(String hotelId) async {
    final ref = _hotelDoc(hotelId).collection('menu_items');
    if (!await _isCollectionEmpty(ref)) return;

    final items = [
      MenuItem(
        id: 'm1',
        hotelId: hotelId,
        name: 'Paneer Tikka',
        description: 'Grilled cottage cheese with spices',
        price: 320,
        category: MenuCategory.starter,
        imageUrl: '',
        dietaryType: DietaryType.veg,
        preparationTimeMinutes: 20,
      ),
      MenuItem(
        id: 'm2',
        hotelId: hotelId,
        name: 'Butter Chicken',
        description: 'Creamy tomato-based chicken curry',
        price: 450,
        category: MenuCategory.mainCourse,
        imageUrl: '',
        dietaryType: DietaryType.nonVeg,
        preparationTimeMinutes: 25,
      ),
      MenuItem(
        id: 'm3',
        hotelId: hotelId,
        name: 'Gulab Jamun',
        description: 'Sweet milk dumplings in syrup',
        price: 120,
        category: MenuCategory.dessert,
        imageUrl: '',
        dietaryType: DietaryType.veg,
        preparationTimeMinutes: 5,
      ),
      MenuItem(
        id: 'm4',
        hotelId: hotelId,
        name: 'Fresh Lime Soda',
        description: 'Refreshing lime drink',
        price: 80,
        category: MenuCategory.drink,
        imageUrl: '',
        dietaryType: DietaryType.veg,
        preparationTimeMinutes: 5,
      ),
      MenuItem(
        id: 'm5',
        hotelId: hotelId,
        name: 'Kingfisher Beer',
        description: '330ml bottled beer',
        price: 200,
        category: MenuCategory.alcohol,
        imageUrl: '',
        dietaryType: DietaryType.veg,
        preparationTimeMinutes: 2,
      ),
    ];

    for (final item in items) {
      await saveMenuItem(item);
    }
  }

  Future<void> initializeDummyInventory(String hotelId) async {
    final inventoryRef = _hotelDoc(hotelId).collection('inventory');
    if (await _isCollectionEmpty(inventoryRef)) {
      final items = [
        InventoryItem(
          id: 'inv1',
          hotelId: hotelId,
          name: 'Chicken Breast',
          category: ItemCategory.food,
          quantity: 25,
          minQuantity: 10,
          unit: UnitType.kg,
          pricePerUnit: 280,
        ),
        InventoryItem(
          id: 'inv2',
          hotelId: hotelId,
          name: 'Paneer',
          category: ItemCategory.food,
          quantity: 8,
          minQuantity: 10,
          unit: UnitType.kg,
          pricePerUnit: 320,
        ),
        InventoryItem(
          id: 'inv3',
          hotelId: hotelId,
          name: 'Cooking Oil',
          category: ItemCategory.food,
          quantity: 40,
          minQuantity: 15,
          unit: UnitType.liters,
          pricePerUnit: 150,
        ),
        InventoryItem(
          id: 'inv4',
          hotelId: hotelId,
          name: 'Towels',
          category: ItemCategory.housekeeping,
          quantity: 100,
          minQuantity: 30,
          unit: UnitType.pieces,
          pricePerUnit: 120,
        ),
      ];

      for (final item in items) {
        await saveInventoryItem(item);
      }
    }

    final vendorsRef = _hotelDoc(hotelId).collection('vendors');
    if (await _isCollectionEmpty(vendorsRef)) {
      final vendors = [
        Vendor(
          id: 'v1',
          hotelId: hotelId,
          name: 'Fresh Farms Supplies',
          category: VendorCategory.vegetables,
          contactPerson: 'Rajesh Kumar',
          phoneNumber: '+919876543210',
          email: 'rajesh@freshfarms.com',
          paymentTerms: PaymentTerms.net15,
          isPreferred: true,
        ),
        Vendor(
          id: 'v2',
          hotelId: hotelId,
          name: 'Metro Beverages',
          category: VendorCategory.beverages,
          contactPerson: 'Priya Sharma',
          phoneNumber: '+919876543211',
          paymentTerms: PaymentTerms.net30,
        ),
      ];

      for (final vendor in vendors) {
        await DatabaseInventory(this).saveVendor(vendor);
      }
    }
  }

  Future<void> initializeDummyCustomers(String hotelId) async {
    final ref = _hotelDoc(hotelId).collection('customers');
    if (!await _isCollectionEmpty(ref)) return;

    final customers = [
      Customer(
        id: 'c1',
        hotelId: hotelId,
        name: 'Amit Patel',
        phone: '+919988776655',
        email: 'amit@example.com',
        totalBookings: 3,
        totalSpent: 15000,
        loyaltyInfo: const LoyaltyInfo(tierId: 'tier_silver', totalPoints: 500),
      ),
      Customer(
        id: 'c2',
        hotelId: hotelId,
        name: 'Sneha Reddy',
        phone: '+919877665544',
        email: 'sneha@example.com',
        totalBookings: 1,
        totalSpent: 4500,
        loyaltyInfo: const LoyaltyInfo(tierId: 'tier_bronze', totalPoints: 120),
      ),
    ];

    for (final customer in customers) {
      await saveCustomer(customer);
    }
  }

  Future<void> initializeDummyLoyalty(String hotelId) async {
    final tiersRef = _hotelDoc(hotelId).collection('loyalty_tiers');
    if (await _isCollectionEmpty(tiersRef)) {
      final tiers = [
        LoyaltyTier(
          id: 'tier_bronze',
          hotelId: hotelId,
          name: 'Bronze',
          minSpend: 0,
          earnMultiplier: 1.0,
          benefits: const ['Birthday discount 5%'],
        ),
        LoyaltyTier(
          id: 'tier_silver',
          hotelId: hotelId,
          name: 'Silver',
          minSpend: 10000,
          earnMultiplier: 1.5,
          benefits: const ['Free dessert', 'Priority seating'],
        ),
        LoyaltyTier(
          id: 'tier_gold',
          hotelId: hotelId,
          name: 'Gold',
          minSpend: 50000,
          earnMultiplier: 2.0,
          benefits: const ['Room upgrade', 'Complimentary breakfast'],
        ),
      ];

      for (final tier in tiers) {
        await saveLoyaltyTier(tier);
      }
    }

    final rulesRef = _hotelDoc(hotelId).collection('point_rules');
    if (await _isCollectionEmpty(rulesRef)) {
      await savePointRule(
        PointRule(
          id: 'pr_bill',
          hotelId: hotelId,
          earnType: PointEarnType.billAmount,
          earnValue: 1,
          minBillAmount: 500,
        ),
      );
    }
  }

  Future<void> initializeDummyOffers(String hotelId) async {
    final offersRef = _hotelDoc(hotelId).collection('offers');
    if (await _isCollectionEmpty(offersRef)) {
      await saveOffer(
        Offer(
          id: 'offer_welcome',
          hotelId: hotelId,
          name: 'Welcome 10% Off',
          offerType: OfferType.bill,
          discountType: DiscountType.percent,
          discountValue: 10,
          minBillAmount: 500,
          maxDiscountAmount: 200,
          description: 'First visit discount for new guests',
        ),
      );
    }

    final happyHoursRef = _hotelDoc(hotelId).collection('happy_hours');
    if (await _isCollectionEmpty(happyHoursRef)) {
      await DatabaseOffers(this).saveHappyHour(
        HappyHour(
          id: 'hh_evening',
          hotelId: hotelId,
          name: 'Evening Happy Hour',
          applicableDays: const [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
          ],
          startTime: '17:00',
          endTime: '19:00',
          applicableCategoryIds: const ['alcohol'],
          discountType: DiscountType.percent,
          discountValue: 20,
        ),
      );
    }
  }

  Future<void> initializeDummyChecklists(String hotelId) async {
    final ref = _hotelDoc(hotelId).collection('checklists');
    if (!await _isCollectionEmpty(ref)) return;

    final checklists = [
      Checklist(
        id: 'cl_opening',
        hotelId: hotelId,
        title: 'Restaurant Opening Checklist',
        description: 'Daily tasks before opening the restaurant',
        type: ChecklistType.general,
        status: ChecklistStatus.pending,
        assignedRole: UserRole.manager,
        dueDate: DateTime.now().add(const Duration(hours: 2)),
        items: const [
          ChecklistItem(id: '1', task: 'Check kitchen equipment'),
          ChecklistItem(id: '2', task: 'Verify cash float'),
          ChecklistItem(id: '3', task: 'Review reservations'),
        ],
      ),
      Checklist(
        id: 'cl_hk_floor1',
        hotelId: hotelId,
        title: 'Floor 1 Housekeeping',
        description: 'Morning room cleaning round',
        type: ChecklistType.housekeeping,
        status: ChecklistStatus.inProgress,
        assignedRole: UserRole.housekeeping,
        dueDate: DateTime.now().add(const Duration(hours: 4)),
        items: const [
          ChecklistItem(id: '1', task: 'Clean Room 101', isCompleted: true),
          ChecklistItem(id: '2', task: 'Clean Room 102'),
        ],
      ),
    ];

    for (final checklist in checklists) {
      await DatabaseChecklists(this).saveChecklist(checklist);
    }
  }

  Future<void> initializeDummyIncidents(String hotelId) async {
    final ref = _hotelDoc(hotelId).collection('incidents');
    if (!await _isCollectionEmpty(ref)) return;

    await saveIncident(
      Incident(
        id: 'inc1',
        hotelId: hotelId,
        title: 'AC not cooling in Room 102',
        description: 'Guest reported AC blowing warm air',
        reportedBy: 'system',
        reportedByName: 'Front Desk',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        priority: IncidentPriority.medium,
        status: IncidentStatus.open,
        location: 'Room 102',
        assignedTo: 'maintenance',
        assignedToName: 'Maintenance Team',
      ),
    );
  }

  Future<void> initializeDummyEvents(String hotelId) async {
    final featuresRef = _hotelDoc(hotelId).collection('hall_features');
    if (await _isCollectionEmpty(featuresRef)) {
      await DatabaseEvents(this).saveHallFeature(
        HallFeature(
          id: 'hf_dj',
          hotelId: hotelId,
          name: 'DJ Setup',
          description: 'Professional sound system with DJ',
          defaultPrice: 15000,
        ),
      );
    }

    final hallsRef = _hotelDoc(hotelId).collection('halls');
    if (await _isCollectionEmpty(hallsRef)) {
      await saveHall(
        Hall(
          id: 'hall_grand',
          hotelId: hotelId,
          name: 'Grand Ballroom',
          capacity: 200,
          description: 'Main banquet hall with stage',
          featureIds: const ['hf_dj'],
        ),
      );
    }

    final eventsRef = _hotelDoc(hotelId).collection('events');
    if (await _isCollectionEmpty(eventsRef)) {
      await saveEvent(
        PrivateEvent(
          id: 'evt1',
          hotelId: hotelId,
          name: 'Sharma Wedding Reception',
          guestName: 'Rahul Sharma',
          guestPhone: '+919900112233',
          date: DateTime.now().add(const Duration(days: 14)),
          startTime: '18:00',
          endTime: '23:00',
          hallIds: const ['hall_grand'],
          menuItemIds: const ['m2', 'm3', 'm4'],
          expectedPax: 150,
          status: EventStatus.confirmed,
          pricing: const EventPricing(
            category: PricingCategory.perPax,
            perPaxRate: 1200,
          ),
          advancePayment: 50000,
        ),
      );
    }
  }

  Future<void> initializeDummyBookings(String hotelId) async {
    final ref = _hotelDoc(hotelId).collection('bookings');
    if (!await _isCollectionEmpty(ref)) return;

    final now = DateTime.now();
    await saveBooking(
      Booking(
        id: 'bk1',
        hotelId: hotelId,
        guestName: 'Amit Patel',
        guestPhone: '+919988776655',
        guestEmail: 'amit@example.com',
        roomId: 'r102',
        checkIn: now,
        checkOut: now.add(const Duration(days: 2)),
        totalAmount: 7000,
        status: BookingStatus.checkedIn,
        bookedBy: 'system',
        customerId: 'c1',
        numberOfGuests: 2,
        paidAmount: 3500,
      ),
    );
  }

  Future<void> initializeDummyOrders(String hotelId) async {
    final ref = _hotelDoc(hotelId).collection('orders');
    if (!await _isCollectionEmpty(ref)) return;

    await saveOrder(
      Order(
        id: 'ord1',
        hotelId: hotelId,
        tableId: 't2',
        tableNumber: 'T2',
        status: OrderStatus.cooking,
        paxCount: 2,
        waiterName: 'Demo Waiter',
        customerId: 'c1',
        guestName: 'Amit Patel',
        items: [
          OrderItem.fromMenuItem(
            const MenuItem(
              id: 'm1',
              hotelId: '',
              name: 'Paneer Tikka',
              description: '',
              price: 320,
              category: MenuCategory.starter,
              imageUrl: '',
            ),
            quantity: 1,
            course: CourseType.starters,
          ),
          OrderItem.fromMenuItem(
            const MenuItem(
              id: 'm2',
              hotelId: '',
              name: 'Butter Chicken',
              description: '',
              price: 450,
              category: MenuCategory.mainCourse,
              imageUrl: '',
            ),
            quantity: 2,
            course: CourseType.mains,
          ),
        ],
        openedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    );
  }

  Future<void> initializeDummyAuditLogs(String hotelId) async {
    final ref = _hotelDoc(hotelId).collection('audit_logs');
    if (!await _isCollectionEmpty(ref)) return;

    await saveAuditLog(
      AuditLog(
        id: 'audit_seed',
        actionType: AuditAction.create.name,
        performedBy: 'system',
        performedByRole: UserRole.owner.name,
        hotelId: hotelId,
        timestamp: DateTime.now(),
        description: 'Demo data seeded on first login',
      ),
    );
  }
}
