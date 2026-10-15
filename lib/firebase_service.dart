import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'models.dart' as app_models;

class FirebaseService {
  FirebaseAuth? get _auth {
    try {
      return Firebase.apps.isNotEmpty ? FirebaseAuth.instance : null;
    } catch (e) {
      debugPrint("FirebaseAuth instance unavailable: $e");
      return null;
    }
  }

  FirebaseFirestore? get _db {
    try {
      return Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;
    } catch (e) {
      debugPrint("FirebaseFirestore instance unavailable: $e");
      return null;
    }
  }

  // --- User Authentication & Profiles ---

  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    String? shopCategory,
    String? whishPhone,
  }) async {
    final auth = _auth;
    final db = _db;
    if (auth == null || db == null) {
      debugPrint("Firebase not initialized. Demo signup.");
      return null;
    }

    try {
      UserCredential res = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user profile to Firestore
      await db.collection('users').doc(res.user!.uid).set({
        'uid': res.user!.uid,
        'email': email,
        'fullName': fullName,
        'phone': phone,
        'role': role,
        'shopCategory': shopCategory,
        'whishPhone': whishPhone,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return res;
    } catch (e) {
      debugPrint("SignUp Error: $e");
      return null;
    }
  }

  Future<UserCredential?> login(String email, String password) async {
    final auth = _auth;
    if (auth == null) {
      debugPrint("Firebase not initialized. Demo login.");
      return null;
    }

    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint("Login Error: $e");
      return null;
    }
  }

  Future<String?> getUserRole(String uid) async {
    final db = _db;
    if (db == null) return null;

    try {
      DocumentSnapshot doc = await db.collection('users').doc(uid).get();
      return doc.exists ? (doc.data() as Map<String, dynamic>)['role'] : null;
    } catch (e) {
      debugPrint("getUserRole Error: $e");
      return null;
    }
  }

  // --- Order Management (Real-time) ---

  Future<void> placeOrder(app_models.Order order) async {
    final db = _db;
    if (db == null) {
      debugPrint("Firebase not initialized. Saving order locally.");
      app_models.AppData.myOrders.add(order);
      return;
    }

    try {
      await db.collection('orders').doc(order.id).set({
        'id': order.id,
        'customerId': order.customerId,
        'marketplaceId': order.marketplaceId,
        'productName': order.productName,
        'price': order.price,
        'remarks': order.remarks,
        'location': order.location, // Format: "lat, lng"
        'status': order.status.name,
        'timestamp': FieldValue.serverTimestamp(),
        'agentId': null,
      });
    } catch (e) {
      debugPrint("placeOrder Error: $e");
      app_models.AppData.myOrders.add(order);
    }
  }

  Stream<List<app_models.Order>> getAvailableOrders() {
    final db = _db;
    if (db == null) {
      return Stream.value(
        app_models.AppData.myOrders
            .where((o) => o.status == app_models.OrderStatus.placed)
            .toList(),
      );
    }

    try {
      return db
          .collection('orders')
          .where('status', isEqualTo: 'placed')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs.map((doc) => _mapToOrder(doc)).toList(),
          );
    } catch (e) {
      debugPrint("getAvailableOrders Error: $e");
      return Stream.value([]);
    }
  }

  Stream<app_models.Order?> getActiveOrderForAgent(String agentId) {
    final db = _db;
    if (db == null) {
      final active = app_models.AppData.myOrders.where(
        (o) =>
            o.agentId == agentId &&
            (o.status == app_models.OrderStatus.accepted ||
                o.status == app_models.OrderStatus.packing ||
                o.status == app_models.OrderStatus.pickedUp),
      );
      return Stream.value(active.isNotEmpty ? active.first : null);
    }

    try {
      return db
          .collection('orders')
          .where('agentId', isEqualTo: agentId)
          .where('status', whereIn: ['accepted', 'packing', 'pickedUp'])
          .snapshots()
          .map(
            (snapshot) => snapshot.docs.isNotEmpty
                ? _mapToOrder(snapshot.docs.first)
                : null,
          );
    } catch (e) {
      debugPrint("getActiveOrderForAgent Error: $e");
      return Stream.value(null);
    }
  }

  Future<void> updateOrderStatus(
    String orderId,
    app_models.OrderStatus status, {
    String? agentId,
  }) async {
    final db = _db;
    if (db == null) {
      int index = app_models.AppData.myOrders.indexWhere(
        (o) => o.id == orderId,
      );
      if (index != -1) {
        final old = app_models.AppData.myOrders[index];
        app_models.AppData.myOrders[index] = app_models.Order(
          id: old.id,
          customerId: old.customerId,
          marketplaceId: old.marketplaceId,
          agentId: agentId ?? old.agentId,
          productName: old.productName,
          price: old.price,
          remarks: old.remarks,
          location: old.location,
          status: status,
          timestamp: old.timestamp,
        );
      }
      return;
    }

    try {
      Map<String, dynamic> data = {'status': status.name};
      if (agentId != null) data['agentId'] = agentId;

      await db.collection('orders').doc(orderId).update(data);
    } catch (e) {
      debugPrint("updateOrderStatus Error: $e");
    }
  }

  app_models.Order _mapToOrder(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return app_models.Order(
      id: data['id'],
      customerId: data['customerId'],
      marketplaceId: data['marketplaceId'],
      agentId: data['agentId'],
      productName: data['productName'],
      price: (data['price'] as num).toDouble(),
      remarks: data['remarks'] ?? "",
      location: data['location'],
      status: app_models.OrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
      ),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
