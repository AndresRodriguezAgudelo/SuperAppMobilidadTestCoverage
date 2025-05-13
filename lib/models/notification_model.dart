import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final bool isRead;
  final String type;
  final Map<String, dynamic>? data;
  
  // Propiedades derivadas para la UI
  bool get isPositive => type != 'warning' && type != 'error';
  IconData get icon {
    switch (type) {
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
        return Icons.info;
      case 'success':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }
  
  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
    this.type = 'info',
    this.data,
  });
  
  // Crear desde JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Notificación',
      body: json['body'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      type: json['type'] ?? 'info',
      data: json['data'],
    );
  }
  
  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'date': date.toIso8601String(),
      'isRead': isRead,
      'type': type,
      'data': data,
    };
  }
  
  // Convertir al formato de la lista estática actual
  Map<String, dynamic> toStaticFormat() {
    return {
      'isPositive': isPositive,
      'icon': icon,
      'text': body,
      'date': date,
      'title': title,
      'status': isRead ? 'leído' : 'nuevo',
      'data': data,
    };
  }
}
