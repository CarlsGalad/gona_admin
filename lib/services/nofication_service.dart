import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:gona_admin/services/admin_service.dart';

class NotificationService {
  final AdminService _adminService = AdminService();
  final List<String> _notifications = [];
  final _notificationsController = StreamController<List<String>>.broadcast();

  Stream<List<String>> get notificationsStream =>
      _notificationsController.stream;

  void _addNotification(String notification) {
    _notifications.add(notification);
    _notificationsController.add(_notifications);
  }

  void setupListeners(String role, String department) {
    if (department == 'Order Management') {
      if (role == 'Order Manager') {
        _adminService.listenToOrders().listen((snapshot) {
          for (var doc in snapshot.docs) {
            _addNotification('A new order has been placed: ${doc['order_id']}');
          }
        });

        _adminService.listenToOrderItems().listen((snapshot) {
          for (var doc in snapshot.docs) {
            if (doc['status'] == 'placed') {
              DateTime placedTime = (doc['order_date'] as Timestamp).toDate();
              if (DateTime.now().difference(placedTime).inHours >= 24) {
                String farmId = doc['farmId'];
                _adminService.getFarmData(farmId).then((farmData) {
                  String farmName = farmData!['itemFarm'];
                  String mobile = farmData['mobile'];
                  _addNotification(
                      'Order ${doc['item_name']} with Order ID: ${doc['order_id']} hasn\'t been processed. Please contact vendor $farmName at $mobile.');
                });
              }
            }
          }
        });
      } else if (role == 'Order Processing Staff') {
        _adminService.listenToOrderItems().listen((snapshot) {
          for (var doc in snapshot.docs) {
            if (doc['status'] == 'shipping') {
              DateTime shippingTime =
                  (doc['shipping_time'] as Timestamp).toDate();
              if (DateTime.now().difference(shippingTime).inHours >= 24) {
                String courierName = doc['courierName'];
                _addNotification(
                    'Item ${doc['item_name']} was processed 24hrs ago and is yet to be picked by courier $courierName.');
              }
            }
          }
        });

        _adminService.listenToOrders().listen((snapshot) {
          for (var doc in snapshot.docs) {
            if (doc['orderStatus']['shipped'] == true) {
              DateTime shippedTime =
                  (doc['shipped_time'] as Timestamp).toDate();
              if (DateTime.now().difference(shippedTime).inHours >= 74 &&
                  doc['orderStatus']['hubNear'] != true) {
                String courierName = doc['courierName'];
                String courierMobile = doc['courierMobile'];
                _addNotification(
                    'Order ${doc['order_id']} delivery is behind schedule. Please contact courier $courierName at $courierMobile.');
              }
            }
          }
        });
      }
    } else if (department == 'Content Management') {
      if (role == 'Content Manager') {
        _adminService.listenToNews().listen((snapshot) {
          for (var doc in snapshot.docs) {
            _addNotification(
                'Your article ${doc['title']} has been added successfully.');
          }
        });
      } else if (role == 'Content Editors') {
        _adminService.listenToItems().listen((snapshot) {
          for (var doc in snapshot.docs) {
            _addNotification('A new item has been added: ${doc['itemId']}');
          }
        });
      }
    } else if (department == 'Finance and Accounting') {
      if (role == 'Finance Manager') {
        _adminService.listenToOrders().listen((snapshot) {
          int totalDeliveredOrderCount = snapshot.docs
              .where((doc) => doc['orderStatus']['delivered'] == true)
              .length;
          if (totalDeliveredOrderCount > 0) {
            _addNotification(
                '$totalDeliveredOrderCount Orders have been delivered, settle vendors');
          }
        });
      }
    } else if (department == 'Dispute Management') {
      if (role == 'Dispute Resolution Specialist') {
        _adminService.listenToDisputes().listen((snapshot) {
          for (var doc in snapshot.docs) {
            _addNotification('You have a new dispute in ${doc['category']}');
          }
        });
      }
    }
  }

  void dispose() {
    _notificationsController.close();
  }
}
