import 'package:campus_cush_consumer/models/hostels.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HostelService {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref('hostels');

  Future<List<Hostel>> getFeaturedHostels() async {
    try {
      final snapshot = await _databaseRef.limitToFirst(5).get();
      if (snapshot.exists) {
        final hostelsMap = snapshot.value as Map<dynamic, dynamic>;
        return hostelsMap.entries.map((entry) {
          return Hostel.fromMap(
              entry.key, Map<String, dynamic>.from(entry.value));
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching featured hostels: $e');
      return [];
    }
  }

  Future<List<Hostel>> getRecentHostels() async {
    try {
      final snapshot =
          await _databaseRef.orderByChild('createdAt').limitToLast(3).get();
      if (snapshot.exists) {
        final hostelsMap = snapshot.value as Map<dynamic, dynamic>;
        return hostelsMap.entries.map((entry) {
          return Hostel.fromMap(
              entry.key, Map<String, dynamic>.from(entry.value));
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching recent hostels: $e');
      return [];
    }
  }
}
