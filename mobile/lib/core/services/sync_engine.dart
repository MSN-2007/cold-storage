import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import '../local_db/drift_database.dart';

part 'sync_engine.g.dart';

@Riverpod(keepAlive: true)
class SyncEngine extends _$SyncEngine {
  late ColdSmartDatabase _db;
  bool _isSyncing = false;

  @override
  void build() {
    _db = ref.watch(coldSmartDbProvider);
  }

  bool get isSyncing => _isSyncing;

  Future<void> triggerSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pending = await _db.getPendingSyncItems();
      if (pending.isEmpty) {
        if (kDebugMode) {
          print("Sync Engine: No pending items to sync.");
        }
        _isSyncing = false;
        return;
      }

      if (kDebugMode) {
        print("Sync Engine: Syncing ${pending.length} pending items...");
      }

      for (final item in pending) {
        // Mock HTTP request to backend endpoint (e.g. POST /api/v1/sync)
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Mark as processed in local db
        await _db.markSyncItemProcessed(item.id);

        if (kDebugMode) {
          print("Sync Engine: Synced item ${item.id} (${item.entityType} ${item.action})");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Sync Engine Error: $e");
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> queueOfflineAction({
    required String entityType,
    required String? entityId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final now = DateTime.now().toIso8601String();
    final queueItem = OfflineSyncQueueTableCompanion.insert(
      id: UniqueKey().toString(),
      entityType: entityType,
      entityId: Value(entityId),
      action: action,
      payloadJson: jsonEncode(payload),
      clientTimestamp: now,
    );

    await _db.addToSyncQueue(queueItem);
    
    // Attempt live sync immediately (if online)
    triggerSync();
  }
}
