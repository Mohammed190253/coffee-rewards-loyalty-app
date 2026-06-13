import 'package:flutter/material.dart';

class StampModel {
  final String id;
  final String title;
  final String description;
  final IconData iconData;
  final String? dateEarned;
  final String? branchName;
  final bool isUnlocked;

  StampModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconData,
    this.dateEarned,
    this.branchName,
    this.isUnlocked = false,
  });

  StampModel copyWith({
    String? id,
    String? title,
    String? description,
    IconData? iconData,
    String? dateEarned,
    String? branchName,
    bool? isUnlocked,
  }) {
    return StampModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconData: iconData ?? this.iconData,
      dateEarned: dateEarned ?? this.dateEarned,
      branchName: branchName ?? this.branchName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
