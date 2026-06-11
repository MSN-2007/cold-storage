import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/dashboard_provider.dart';
import '../widgets/fleet_status_card.dart';
import '../widgets/active_alert_card.dart';
import '../widgets/storage_card.dart';
import '../widgets/quick_actions_row.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: CSColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: CSColors.accent,
          backgroundColor: CSColors.surfaceLight,
          onRefresh: () => ref.refresh(dashboardProvider.future),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          dashboardState.when(
                            loading: () => _buildHeaderSkeleton(),
                            error: (_, __) => _buildHeaderTitle("Dashboard"),
                            data: (data) => _buildHeaderTitle(data.userName ?? 'Ramesh!'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Here's what's happening in your cold storage today.",
                            style: CSTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          dashboardState.when(
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                            data: (data) => _AlertBadge(count: data.activeAlertCount),
                          ),
                          IconButton(
                            icon: const Icon(Icons.help_outline, color: CSColors.textPrimaryLight),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: CSColors.surfaceLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: CSColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: CSColors.accentLight,
                                  child: Icon(Icons.person, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Ramesh Kumar', style: CSTextStyles.labelMedium.copyWith(color: CSColors.textPrimaryLight)),
                                    Text('Owner', style: CSTextStyles.labelSmall),
                                  ],
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down, size: 16, color: CSColors.textSecondaryLight),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Last Updated
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Last Updated: 10:30 AM', style: CSTextStyles.labelSmall),
                        const SizedBox(width: 4),
                        const Icon(Icons.refresh, size: 14, color: CSColors.textTertiaryLight),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Fleet Status Cards ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: dashboardState.when(
                    loading: () => const _FleetStatusSkeleton(),
                    error: (e, _) => _ErrorCard(message: e.toString()),
                    data: (data) => FleetStatusRow(
                      total: data.totalDevices,
                      healthy: data.healthyDevices,
                      warning: data.warningDevices,
                      critical: data.criticalDevices,
                      offline: data.offlineDevices,
                    ),
                  ),
                ),
              ),

              // ── Active Alerts Section ──────────────────────────────────────
              dashboardState.when(
                loading: () => const SliverToBoxAdapter(child: SizedBox()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
                data: (data) => data.activeAlerts.isEmpty
                    ? const SliverToBoxAdapter(child: SizedBox())
                    : SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_rounded, color: CSColors.critical, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Immediate Action Required', style: CSTextStyles.headlineSmall),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => context.go('/alerts'),
                                    child: Text('View All Alerts →', style: CSTextStyles.labelMedium.copyWith(color: CSColors.accent)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 180,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                itemCount: data.activeAlerts.length.clamp(0, 5),
                                separatorBuilder: (_, __) => const SizedBox(width: 16),
                                itemBuilder: (context, index) => ActiveAlertCard(
                                  alert: data.activeAlerts[index],
                                  onTap: () => context.go('/alerts/${data.activeAlerts[index].id}'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              // ── Your Cold Storages ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Text('Your Cold Storages', style: CSTextStyles.headlineSmall),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.go('/devices'),
                            child: Text('View All Storages →', style: CSTextStyles.labelMedium.copyWith(color: CSColors.accent)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              dashboardState.when(
                loading: () => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid.count(
                    crossAxisCount: _getCrossAxisCount(context),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: List.generate(4, (_) => const _StorageCardSkeleton()),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(child: _ErrorCard(message: e.toString())),
                data: (data) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid.count(
                    crossAxisCount: _getCrossAxisCount(context),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: data.devices.map((device) => StorageCard(
                      device: device,
                      onTap: () => context.go('/devices/${device.id}'),
                    )).toList(),
                  ),
                ),
              ),

              // ── Quick Actions ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text('Quick Actions', style: CSTextStyles.headlineSmall),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: QuickActionsRow(),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 900) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Widget _buildHeaderTitle(String name) {
    return Text(
      'Good Morning, $name',
      style: CSTextStyles.displayMedium,
    );
  }

  Widget _buildHeaderSkeleton() {
    return Shimmer.fromColors(
      baseColor: CSColors.borderLight,
      highlightColor: CSColors.surfaceLight,
      child: Container(width: 200, height: 28, color: Colors.white),
    );
  }
}


// ─── Alert Badge ──────────────────────────────────────────────────────────────

class _AlertBadge extends StatelessWidget {
  final int count;
  const _AlertBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: CSColors.textPrimaryLight),
          onPressed: () => GoRouter.of(context).go('/alerts'),
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: CSColors.critical,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}


// ─── Skeleton Widgets ─────────────────────────────────────────────────────────

class _FleetStatusSkeleton extends StatelessWidget {
  const _FleetStatusSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: CSColors.borderLight,
      highlightColor: CSColors.surfaceLight,
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: List.generate(5, (i) => Container(
          width: 200,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: CSRadius.cardBorder,
          ),
        )),
      ),
    );
  }
}

class _StorageCardSkeleton extends StatelessWidget {
  const _StorageCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: CSColors.borderLight,
      highlightColor: CSColors.surfaceLight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: CSRadius.cardBorder,
        ),
      ),
    );
  }
}

// ─── Error Card ───────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CSColors.criticalLight.withOpacity(0.5),
        border: Border.all(color: CSColors.critical.withOpacity(0.3)),
        borderRadius: CSRadius.cardBorder,
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: CSColors.critical, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed to load dashboard. Pull down to retry.',
              style: CSTextStyles.bodySmall.copyWith(color: CSColors.critical),
            ),
          ),
        ],
      ),
    );
  }
}
