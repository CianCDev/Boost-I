// lib/features/pos/presentation/providers/isar_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());