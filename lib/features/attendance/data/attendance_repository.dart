import 'package:equatable/equatable.dart';
import 'package:hotel_manager/core/services/location_service.dart';

enum AttendanceType { checkIn, checkOut }

class AttendanceRecord extends Equatable {
  final String id;
  final String userId;
  final DateTime timestamp;
  final AttendanceType type;
  final double latitude;
  final double longitude;
  final bool isWithinPremises;

  const AttendanceRecord({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.isWithinPremises,
  });

  @override
  List<Object?> get props => [id, userId, timestamp, type, latitude, longitude, isWithinPremises];
}

class AttendanceRepository {
  final LocationService _locationService;

  // Hotel Coordinates (Mock: Central Park, CP, New Delhi for example)
  static const double hotelLat = 28.6297;
  static const double hotelLng = 77.2177;
  static const double allowedRadiusMeters = 200; // 200 meters radius

  AttendanceRepository({LocationService? locationService}) 
      : _locationService = locationService ?? LocationService();

  final List<AttendanceRecord> _mockHistory = [];

  Future<List<AttendanceRecord>> getHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate API
    return List.from(_mockHistory.where((r) => r.userId == userId));
  }

  Future<AttendanceRecord> punch(String userId, AttendanceType type) async {
    // 1. Get Location
    final position = await _locationService.determinePosition();
    
    // 2. Check Geofence
    final distance = _locationService.getDistanceBetween(
      position.latitude, 
      position.longitude, 
      hotelLat, 
      hotelLng
    );
    
    final isWithinPremises = distance <= allowedRadiusMeters;

    if (!isWithinPremises) {
      throw Exception('You are ${(distance - allowedRadiusMeters).toStringAsFixed(0)}m away from the hotel. Please reach the hotel to punch in.');
    }

    // 3. Create Record
    final record = AttendanceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      timestamp: DateTime.now(),
      type: type,
      latitude: position.latitude,
      longitude: position.longitude,
      isWithinPremises: isWithinPremises,
    );

    // 4. Save (Mock)
    _mockHistory.insert(0, record); // Add to top
    return record;
  }

  Future<void> regularize(String userId, DateTime timestamp, AttendanceType type, String reason) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final record = AttendanceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      timestamp: timestamp,
      type: type,
      latitude: hotelLat, // Assume regularized at hotel
      longitude: hotelLng,
      isWithinPremises: true,
    );
    
    _mockHistory.add(record);
    _mockHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Keep sorted desc
  }
  
  Future<bool> isCheckedIn(String userId) async {
    if (_mockHistory.isEmpty) return false;
    final lastRecord = _mockHistory.firstWhere((r) => r.userId == userId, orElse: () => 
      AttendanceRecord(id: '', userId: '', timestamp: DateTime(2000), type: AttendanceType.checkOut, latitude: 0, longitude: 0, isWithinPremises: false)
    );
    return lastRecord.type == AttendanceType.checkIn;
  }

  /// Get attendance status for all users for a specific date
  Future<Map<String, AttendanceStatus>> getAllUsersAttendanceToday() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    final Map<String, AttendanceStatus> userStatuses = {};
    
    // Get all unique user IDs from history
    final allUserIds = _mockHistory.map((r) => r.userId).toSet();
    
    for (final userId in allUserIds) {
      final todayRecords = _mockHistory.where((r) => 
        r.userId == userId &&
        r.timestamp.isAfter(todayStart) &&
        r.timestamp.isBefore(todayEnd)
      ).toList();
      
      if (todayRecords.isEmpty) {
        userStatuses[userId] = AttendanceStatus.absent;
      } else {
        final checkInRecord = todayRecords.firstWhere(
          (r) => r.type == AttendanceType.checkIn,
          orElse: () => todayRecords.first,
        );
        
        if (checkInRecord.type == AttendanceType.checkIn) {
          // Check if late (after 9:30 AM)
          final checkInTime = checkInRecord.timestamp;
          final lateThreshold = DateTime(checkInTime.year, checkInTime.month, checkInTime.day, 9, 30);
          
          if (checkInTime.isAfter(lateThreshold)) {
            userStatuses[userId] = AttendanceStatus.late;
          } else {
            userStatuses[userId] = AttendanceStatus.present;
          }
        } else {
          userStatuses[userId] = AttendanceStatus.absent;
        }
      }
    }
    
    return userStatuses;
  }

  /// Get monthly attendance for a user
  Future<Map<DateTime, AttendanceStatus>> getMonthlyAttendance(String userId, int year, int month) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final Map<DateTime, AttendanceStatus> monthlyData = {};
    final daysInMonth = DateTime(year, month + 1, 0).day;
    
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dayStart = DateTime(year, month, day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final dayRecords = _mockHistory.where((r) =>
        r.userId == userId &&
        r.timestamp.isAfter(dayStart) &&
        r.timestamp.isBefore(dayEnd)
      ).toList();
      
      if (dayRecords.isEmpty) {
        monthlyData[date] = AttendanceStatus.absent;
      } else {
        final checkInRecord = dayRecords.firstWhere(
          (r) => r.type == AttendanceType.checkIn,
          orElse: () => dayRecords.first,
        );
        
        if (checkInRecord.type == AttendanceType.checkIn) {
          final checkInTime = checkInRecord.timestamp;
          final lateThreshold = DateTime(checkInTime.year, checkInTime.month, checkInTime.day, 9, 30);
          
          monthlyData[date] = checkInTime.isAfter(lateThreshold) 
            ? AttendanceStatus.late 
            : AttendanceStatus.present;
        } else {
          monthlyData[date] = AttendanceStatus.absent;
        }
      }
    }
    
    return monthlyData;
  }
}

enum AttendanceStatus {
  present,
  absent,
  late,
  onLeave,
}
