import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Standalone script to create a Super Admin user by directly writing to Firestore.
///
/// Usage:
///   1. Get your Project ID from Firebase Console.
///   2. Get an ID Token for an existing user (or use a Service Account).
///   3. Run: `dart bin/create_super_admin.dart <project_id> <user_uid> <email> <name>`
///
/// NOTE: This script uses the REST API. In a real production environment,
/// you would use the Firebase Admin SDK (Node.js/Go/Python/Dart).
void main(List<String> args) async {
  if (args.length < 4) {
    print(
      'Usage: dart bin/create_super_admin.dart <project_id> <user_uid> <email> <name>',
    );
    exit(1);
  }

  final String projectId = args[0];
  final String uid = args[1];
  final String email = args[2];
  final String name = args[3];

  print('🚀 Creating Super Admin user: $email ($uid)...');

  final url =
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/$uid';

  final data = {
    'fields': {
      'id': {'stringValue': uid},
      'email': {'stringValue': email},
      'name': {'stringValue': name},
      'role': {'stringValue': 'superAdmin'},
      'status': {'stringValue': 'active'},
      'hotelIds': {
        'arrayValue': {
          'values': [
            {'stringValue': 'system'},
          ],
        },
      },
      'createdOn': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
    },
  };

  print('⚠️ Please enter your Firebase ID Token (get it from app or CLI):');
  final String? token = stdin.readLineSync();

  if (token == null || token.isEmpty) {
    print('❌ Token is required.');
    exit(1);
  }

  try {
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('✅ Super Admin created successfully!');
    } else {
      print('❌ Failed to create Super Admin: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
