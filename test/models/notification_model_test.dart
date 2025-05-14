import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    test('debe crear una instancia correctamente con constructor directo', () {
      final date = DateTime(2023, 12, 31);
      final notification = NotificationModel(
        id: '1',
        title: 'Test Notification',
        body: 'This is a test notification',
        date: date,
        isRead: false,
        type: 'info',
        data: {'key': 'value'},
      );
      
      expect(notification.id, equals('1'));
      expect(notification.title, equals('Test Notification'));
      expect(notification.body, equals('This is a test notification'));
      expect(notification.date, equals(date));
      expect(notification.isRead, isFalse);
      expect(notification.type, equals('info'));
      expect(notification.data, equals({'key': 'value'}));
    });
    
    test('debe crear una instancia desde JSON completo', () {
      final json = {
        'id': '2',
        'title': 'JSON Notification',
        'body': 'This is from JSON',
        'date': '2023-12-31T12:00:00.000Z',
        'isRead': true,
        'type': 'success',
        'data': {'source': 'json'},
      };
      
      final notification = NotificationModel.fromJson(json);
      
      expect(notification.id, equals('2'));
      expect(notification.title, equals('JSON Notification'));
      expect(notification.body, equals('This is from JSON'));
      expect(notification.date, equals(DateTime.parse('2023-12-31T12:00:00.000Z')));
      expect(notification.isRead, isTrue);
      expect(notification.type, equals('success'));
      expect(notification.data, equals({'source': 'json'}));
    });
    
    test('debe manejar valores faltantes en JSON', () {
      final json = <String, dynamic>{};
      
      final notification = NotificationModel.fromJson(json);
      
      expect(notification.id, equals(''));
      expect(notification.title, equals('Notificación'));
      expect(notification.body, equals(''));
      expect(notification.isRead, isFalse);
      expect(notification.type, equals('info'));
      expect(notification.data, isNull);
      // No verificamos la fecha porque usa DateTime.now()
    });
    
    test('debe convertir a JSON correctamente', () {
      final date = DateTime(2023, 12, 31);
      final notification = NotificationModel(
        id: '3',
        title: 'Test Notification',
        body: 'This is a test notification',
        date: date,
        isRead: true,
        type: 'warning',
        data: {'key': 'value'},
      );
      
      final json = notification.toJson();
      
      expect(json['id'], equals('3'));
      expect(json['title'], equals('Test Notification'));
      expect(json['body'], equals('This is a test notification'));
      expect(json['date'], equals(date.toIso8601String()));
      expect(json['isRead'], isTrue);
      expect(json['type'], equals('warning'));
      expect(json['data'], equals({'key': 'value'}));
    });
    
    test('debe convertir a formato estático correctamente', () {
      final date = DateTime(2023, 12, 31);
      final notification = NotificationModel(
        id: '4',
        title: 'Static Format',
        body: 'This is for static format',
        date: date,
        isRead: true,
        type: 'info',
        data: {'key': 'value'},
      );
      
      final staticFormat = notification.toStaticFormat();
      
      expect(staticFormat['isPositive'], isTrue);
      expect(staticFormat['icon'], equals(Icons.info));
      expect(staticFormat['text'], equals('This is for static format'));
      expect(staticFormat['date'], equals(date));
      expect(staticFormat['title'], equals('Static Format'));
      expect(staticFormat['status'], equals('leído'));
      expect(staticFormat['data'], equals({'key': 'value'}));
    });
    
    test('debe determinar correctamente si es positivo', () {
      final infoNotification = NotificationModel(
        id: '5',
        title: 'Info',
        body: 'Info notification',
        date: DateTime.now(),
        type: 'info',
      );
      
      final successNotification = NotificationModel(
        id: '6',
        title: 'Success',
        body: 'Success notification',
        date: DateTime.now(),
        type: 'success',
      );
      
      final warningNotification = NotificationModel(
        id: '7',
        title: 'Warning',
        body: 'Warning notification',
        date: DateTime.now(),
        type: 'warning',
      );
      
      final errorNotification = NotificationModel(
        id: '8',
        title: 'Error',
        body: 'Error notification',
        date: DateTime.now(),
        type: 'error',
      );
      
      expect(infoNotification.isPositive, isTrue);
      expect(successNotification.isPositive, isTrue);
      expect(warningNotification.isPositive, isFalse);
      expect(errorNotification.isPositive, isFalse);
    });
    
    test('debe devolver el icono correcto según el tipo', () {
      final infoNotification = NotificationModel(
        id: '9',
        title: 'Info',
        body: 'Info notification',
        date: DateTime.now(),
        type: 'info',
      );
      
      final successNotification = NotificationModel(
        id: '10',
        title: 'Success',
        body: 'Success notification',
        date: DateTime.now(),
        type: 'success',
      );
      
      final warningNotification = NotificationModel(
        id: '11',
        title: 'Warning',
        body: 'Warning notification',
        date: DateTime.now(),
        type: 'warning',
      );
      
      final errorNotification = NotificationModel(
        id: '12',
        title: 'Error',
        body: 'Error notification',
        date: DateTime.now(),
        type: 'error',
      );
      
      final unknownNotification = NotificationModel(
        id: '13',
        title: 'Unknown',
        body: 'Unknown notification',
        date: DateTime.now(),
        type: 'unknown',
      );
      
      expect(infoNotification.icon, equals(Icons.info));
      expect(successNotification.icon, equals(Icons.check_circle));
      expect(warningNotification.icon, equals(Icons.warning));
      expect(errorNotification.icon, equals(Icons.error));
      expect(unknownNotification.icon, equals(Icons.notifications));
    });
  });
}
