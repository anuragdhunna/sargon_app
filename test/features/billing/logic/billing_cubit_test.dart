import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/core/services/database/interfaces/billing_database.dart';
import 'package:hotel_manager/features/billing/logic/billing_cubit.dart';
import 'package:hotel_manager/features/billing/logic/billing_settlement_processor.dart';
import 'package:hotel_manager/features/billing/logic/billing_state.dart';
import 'package:mocktail/mocktail.dart';

class MockBillingDatabase extends Mock implements IBillingDatabase {}

class MockAuditService extends Mock implements AuditService {}

class MockSettlementProcessor extends Mock
    implements BillingSettlementProcessor {}

class FakeBillingDatabase extends Fake implements IBillingDatabase {}

class FakeAuditService extends Fake implements AuditService {}

class FakeBill extends Fake implements Bill {}

class FakeTaxRule extends Fake implements TaxRule {}

class FakeServiceChargeRule extends Fake implements ServiceChargeRule {}

void main() {
  late MockBillingDatabase mockDatabase;
  late MockAuditService mockAuditService;
  late MockSettlementProcessor mockSettlementProcessor;

  const testHotelId = 'hotel_test_1';

  final testTaxRule = TaxRule(
    id: 'gst_5',
    hotelId: testHotelId,
    name: 'GST 5%',
    cgstPercent: 2.5,
    sgstPercent: 2.5,
  );

  final testScRule = ServiceChargeRule(
    id: 'sc_10',
    hotelId: testHotelId,
    name: 'Service Charge 10%',
    percent: 10.0,
  );

  final testBill = Bill(
    id: 'bill_1',
    hotelId: testHotelId,
    tableId: 'table_1',
    orderIds: ['order_1'],
    subTotal: 500.0,
    taxRuleId: 'gst_5',
    serviceChargeRuleId: 'sc_10',
    taxSummary: const BillTaxSummary(
      subTotal: 500.0,
      totalDiscountAmount: 0.0,
      taxableAmount: 550.0,
      cgstAmount: 13.75,
      sgstAmount: 13.75,
      igstAmount: 0.0,
      serviceChargeAmount: 50.0,
      totalTax: 27.5,
      grandTotal: 577.5,
    ),
    paymentStatus: PaymentStatus.pending,
    openedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(FakeBillingDatabase());
    registerFallbackValue(FakeAuditService());
    registerFallbackValue(FakeBill());
    registerFallbackValue(FakeTaxRule());
    registerFallbackValue(FakeServiceChargeRule());
    registerFallbackValue(AuditAction.update);
    registerFallbackValue(PaymentStatus.billed);
    registerFallbackValue(PaymentMethod.card);
    registerFallbackValue(TableStatus.cleaning);
  });

  setUp(() {
    mockDatabase = MockBillingDatabase();
    mockAuditService = MockAuditService();
    mockSettlementProcessor = MockSettlementProcessor();

    when(
      () => mockDatabase.getTaxRules(any()),
    ).thenAnswer((_) async => [testTaxRule]);
    when(
      () => mockDatabase.getServiceChargeRules(any()),
    ).thenAnswer((_) async => [testScRule]);
    when(
      () => mockDatabase.streamBills(any()),
    ).thenAnswer((_) => Stream.value([testBill]));
    when(() => mockDatabase.saveBill(any())).thenAnswer((_) async => {});
    when(
      () => mockDatabase.updateOrderPaymentStatus(any(), any(), any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockDatabase.updateTableStatus(any(), any(), any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockDatabase.deleteServiceChargeRule(any(), any()),
    ).thenAnswer((_) async => {});

    when(
      () => mockAuditService.log(
        hotelId: any(named: 'hotelId'),
        performedBy: any(named: 'performedBy'),
        performedByRole: any(named: 'performedByRole'),
        action: any(named: 'action'),
        targetUserId: any(named: 'targetUserId'),
        description: any(named: 'description'),
        newData: any(named: 'newData'),
      ),
    ).thenAnswer((_) async => {});

    when(
      () => mockSettlementProcessor.awardLoyaltyPoints(
        databaseService: any(named: 'databaseService'),
        hotelId: any(named: 'hotelId'),
        bill: any(named: 'bill'),
      ),
    ).thenAnswer((_) async => {});

    when(
      () => mockSettlementProcessor.attachBillToFolio(
        databaseService: any(named: 'databaseService'),
        hotelId: any(named: 'hotelId'),
        bookingId: any(named: 'bookingId'),
        bill: any(named: 'bill'),
      ),
    ).thenAnswer((_) async => {});

    when(
      () => mockSettlementProcessor.settleFolio(
        databaseService: any(named: 'databaseService'),
        auditService: any(named: 'auditService'),
        hotelId: any(named: 'hotelId'),
        bookingId: any(named: 'bookingId'),
        method: any(named: 'method'),
        bills: any(named: 'bills'),
        reference: any(named: 'reference'),
      ),
    ).thenAnswer((_) async => {});
  });

  BillingCubit createCubit() {
    return BillingCubit(
      databaseService: mockDatabase,
      auditService: mockAuditService,
      settlementProcessor: mockSettlementProcessor,
    );
  }

  group('BillingCubit Unit Tests', () {
    test('initial state is BillingInitial', () {
      final cubit = createCubit();
      expect(cubit.state, isA<BillingInitial>());
      cubit.close();
    });

    blocTest<BillingCubit, BillingState>(
      'loadBillingData loads tax rules, sc rules, and streams bills',
      build: createCubit,
      act: (cubit) => cubit.loadBillingData(hotelId: testHotelId),
      expect: () => [
        isA<BillingLoaded>().having((s) => s.bills, 'bills', isEmpty),
        isA<BillingLoaded>()
            .having((s) => s.bills, 'bills', hasLength(1))
            .having((s) => s.taxRules, 'taxRules', hasLength(1))
            .having(
              (s) => s.serviceChargeRules,
              'serviceChargeRules',
              hasLength(1),
            ),
      ],
      verify: (_) {
        verify(() => mockDatabase.getTaxRules(testHotelId)).called(1);
        verify(
          () => mockDatabase.getServiceChargeRules(testHotelId),
        ).called(1);
        verify(() => mockDatabase.streamBills(testHotelId)).called(1);
      },
    );

    blocTest<BillingCubit, BillingState>(
      'deleteServiceChargeRule invokes databaseService and updates state',
      build: createCubit,
      seed: () => BillingLoaded(
        bills: [testBill],
        taxRules: [testTaxRule],
        serviceChargeRules: [testScRule],
      ),
      act: (cubit) => cubit.deleteServiceChargeRule(testHotelId, 'sc_10'),
      verify: (_) {
        verify(
          () => mockDatabase.deleteServiceChargeRule(testHotelId, 'sc_10'),
        ).called(1);
      },
    );

    blocTest<BillingCubit, BillingState>(
      'addPayment records payment, saves bill, and triggers settlement updates',
      build: createCubit,
      seed: () => BillingLoaded(
        bills: [testBill],
        taxRules: [testTaxRule],
        serviceChargeRules: [testScRule],
      ),
      act: (cubit) => cubit.addPayment(
        billId: testBill.id,
        amount: 577.5,
        method: PaymentMethod.card,
        hotelId: testHotelId,
        reference: 'TXN12345',
      ),
      verify: (_) {
        verify(() => mockDatabase.saveBill(any())).called(1);
        verify(
          () => mockDatabase.updateOrderPaymentStatus(
            testHotelId,
            'order_1',
            PaymentStatus.paid,
          ),
        ).called(1);
        verify(
          () => mockDatabase.updateTableStatus(
            testHotelId,
            testBill.tableId,
            TableStatus.cleaning,
          ),
        ).called(1);
        verify(
          () => mockAuditService.log(
            hotelId: testHotelId,
            performedBy: 'system',
            performedByRole: 'finance',
            action: AuditAction.update,
            targetUserId: any(named: 'targetUserId'),
            description: any(named: 'description'),
            newData: any(named: 'newData'),
          ),
        ).called(1);
      },
    );

    blocTest<BillingCubit, BillingState>(
      'settleFolio delegates to BillingSettlementProcessor',
      build: createCubit,
      seed: () => BillingLoaded(
        bills: [testBill],
        taxRules: [testTaxRule],
        serviceChargeRules: [testScRule],
      ),
      act: (cubit) => cubit.settleFolio(
        bookingId: 'booking_123',
        hotelId: testHotelId,
        method: PaymentMethod.card,
        reference: 'Folio Ref',
      ),
      verify: (_) {
        verify(
          () => mockSettlementProcessor.settleFolio(
            databaseService: mockDatabase,
            auditService: mockAuditService,
            hotelId: testHotelId,
            bookingId: 'booking_123',
            method: PaymentMethod.card,
            bills: any(named: 'bills'),
            reference: 'Folio Ref',
          ),
        ).called(1);
      },
    );
  });
}
