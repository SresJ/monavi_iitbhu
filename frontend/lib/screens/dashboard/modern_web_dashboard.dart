import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../config/design_tokens.dart';

class ModernWebDashboard extends StatefulWidget {
  const ModernWebDashboard({super.key});

  @override
  State<ModernWebDashboard> createState() => _ModernWebDashboardState();
}

class _ModernWebDashboardState extends State<ModernWebDashboard> {
  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: DesignTokens.voidBlack,
      body: Row(
        children: [
          if (isDesktop) const _Sidebar(),
          Expanded(
            child: Column(
              children: [
                const _TopNavBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(DesignTokens.spaceLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard Overview',
                          style: DesignTokens.headingLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back! Here\'s what\'s happening today.',
                          style: DesignTokens.bodyMedium.copyWith(color: DesignTokens.textSecondary),
                        ),
                        const SizedBox(height: DesignTokens.spaceXl),
                        const _AnalyticsCardsRow(),
                        const SizedBox(height: DesignTokens.spaceXl),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              flex: 7,
                              child: _RecentActivityTable(),
                            ),
                            if (isDesktop) const SizedBox(width: DesignTokens.spaceLg),
                            if (isDesktop)
                              const Expanded(
                                flex: 3,
                                child: _UserProfilePanel(),
                              ),
                          ],
                        ),
                        if (!isDesktop) const SizedBox(height: DesignTokens.spaceLg),
                        if (!isDesktop) const _UserProfilePanel(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: DesignTokens.surfaceBlack,
        border: Border(
          right: const BorderSide(color: DesignTokens.borderGray, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    gradient: DesignTokens.medicalGradient,
                    borderRadius: DesignTokens.radiusMd,
                  ),
                  child: const Icon(Iconsax.flash_copy, color: DesignTokens.textPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'ClinicalAdmin',
                  style: DesignTokens.headingMedium,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _SidebarItem(icon: Iconsax.category_copy, label: 'Dashboard', isActive: true),
                _SidebarItem(icon: Iconsax.chart_copy, label: 'Analytics'),
                _SidebarItem(icon: Iconsax.profile_2user_copy, label: 'Patients'),
                _SidebarItem(icon: Iconsax.setting_2_copy, label: 'Settings'),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignTokens.cardBlack,
                borderRadius: DesignTokens.radiusMd,
                border: Border.all(color: DesignTokens.borderGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pro Plan',
                    style: DesignTokens.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unlock advanced features and analytics.',
                    style: DesignTokens.labelSmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.medicalBlue,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: DesignTokens.radiusSm,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Upgrade',
                        style: DesignTokens.labelLarge,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive
        ? DesignTokens.clinicalTeal
        : isHovered
            ? DesignTokens.textPrimary
            : DesignTokens.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.isActive
              ? DesignTokens.clinicalTeal.withOpacity(0.1)
              : isHovered
                  ? DesignTokens.cardBlack
                  : Colors.transparent,
          borderRadius: DesignTokens.radiusMd,
          border: Border.all(
            color: widget.isActive || isHovered ? DesignTokens.borderGray : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: color, size: 20),
            const SizedBox(width: 16),
            Text(
              widget.label,
              style: widget.isActive
                  ? DesignTokens.labelMedium.copyWith(color: color, fontWeight: FontWeight.w600)
                  : DesignTokens.labelMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  const _TopNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: DesignTokens.surfaceBlack,
        border: const Border(
          bottom: BorderSide(color: DesignTokens.borderGray, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search Input Field
          Container(
            width: 320,
            height: 40,
            decoration: BoxDecoration(
              color: DesignTokens.cardBlack,
              borderRadius: DesignTokens.radiusSm,
              border: Border.all(color: DesignTokens.borderGray),
            ),
            child: TextField(
              style: DesignTokens.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: DesignTokens.bodyMedium.copyWith(color: DesignTokens.textTertiary),
                prefixIcon: const Icon(Iconsax.search_normal_copy, size: 18, color: DesignTokens.textTertiary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          
          // Right Nav Items
          Row(
            children: [
              IconButton(
                icon: const Icon(Iconsax.notification_copy, color: DesignTokens.textSecondary, size: 22),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: DesignTokens.borderGray),
                  image: const DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?img=68'), 
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _AnalyticsCardsRow extends StatelessWidget {
  const _AnalyticsCardsRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
        double spacing = 24.0;
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          children: const [
            _StatCard(title: 'Total Revenue', value: '\$45,231.89', percentage: '+20.1%', isPositive: true),
            _StatCard(title: 'Subscriptions', value: '+2350', percentage: '+18.2%', isPositive: true),
            _StatCard(title: 'Sales', value: '+12,234', percentage: '-4.1%', isPositive: false),
            _StatCard(title: 'Active Now', value: '573', percentage: '+1.2%', isPositive: true),
          ],
        );
      }
    );
  }
}

class _StatCard extends StatefulWidget {
  final String title;
  final String value;
  final String percentage;
  final bool isPositive;

  const _StatCard({
    required this.title,
    required this.value,
    required this.percentage,
    required this.isPositive,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: DesignTokens.quick,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isHovered ? DesignTokens.surfaceBlack : DesignTokens.cardBlack,
          borderRadius: DesignTokens.radiusLg,
          border: Border.all(
            color: isHovered ? DesignTokens.clinicalTeal : DesignTokens.borderGray,
          ),
          boxShadow: isHovered ? DesignTokens.glowTeal : DesignTokens.depth1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: DesignTokens.labelMedium,
                ),
                Icon(
                  widget.isPositive ? Iconsax.arrow_up_3_copy : Iconsax.arrow_down_copy,
                  color: widget.isPositive ? DesignTokens.success : DesignTokens.error,
                  size: 16,
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.value,
                  style: DesignTokens.headingLarge,
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.percentage,
                    style: DesignTokens.labelSmall.copyWith(
                      color: widget.isPositive ? DesignTokens.success : DesignTokens.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityTable extends StatelessWidget {
  const _RecentActivityTable();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.cardBlack,
        borderRadius: DesignTokens.radiusLg,
        border: Border.all(color: DesignTokens.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: DesignTokens.headingMedium,
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: DesignTokens.labelLarge.copyWith(color: DesignTokens.medicalBlue),
                  ),
                )
              ],
            ),
          ),
          DataTable(
            headingRowColor: WidgetStateProperty.resolveWith((states) => DesignTokens.surfaceBlack),
            dataRowMaxHeight: 64,
            dataRowMinHeight: 64,
            columns: [
              DataColumn(label: Text('Customer', style: DesignTokens.labelMedium)),
              DataColumn(label: Text('Amount', style: DesignTokens.labelMedium)),
              DataColumn(label: Text('Status', style: DesignTokens.labelMedium)),
              DataColumn(label: Text('Date', style: DesignTokens.labelMedium)),
            ],
            rows: [
              _buildDataRow('Olivia Martin', 'olivia.martin@email.com', '\$1,999.00', 'Completed', 'Today, 2:34 PM', true),
              _buildDataRow('Jackson Lee', 'jackson.lee@email.com', '\$39.00', 'Pending', 'Today, 1:12 PM', false),
              _buildDataRow('Isabella Nguyen', 'isabella.nguyen@email.com', '\$299.00', 'Completed', 'Yesterday', true),
              _buildDataRow('William Kim', 'will@email.com', '\$99.00', 'Completed', 'Yesterday', true),
              _buildDataRow('Sofia Davis', 'sofia.davis@email.com', '\$39.00', 'Failed', '2 days ago', false, isFailed: true),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String name, String email, String amount, String status, String date, bool isAlternate, {bool isFailed = false}) {
    Color statusColor = status == 'Completed' ? DesignTokens.success : (isFailed ? DesignTokens.error : DesignTokens.warning);
    Color statusBg = (status == 'Completed' ? DesignTokens.success : (isFailed ? DesignTokens.error : DesignTokens.warning)).withOpacity(0.15);

    return DataRow(
      color: WidgetStateProperty.resolveWith((states) => isAlternate ? DesignTokens.surfaceBlack : DesignTokens.cardBlack),
      cells: [
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name, style: DesignTokens.labelLarge),
              Text(email, style: DesignTokens.labelSmall),
            ],
          )
        ),
        DataCell(Text(amount, style: DesignTokens.labelLarge)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: DesignTokens.radiusSm,
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              status,
              style: DesignTokens.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold),
            ),
          )
        ),
        DataCell(Text(date, style: DesignTokens.labelSmall)),
      ],
    );
  }
}

class _UserProfilePanel extends StatelessWidget {
  const _UserProfilePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DesignTokens.cardBlack,
        borderRadius: DesignTokens.radiusLg,
        border: Border.all(color: DesignTokens.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/150?img=68'), 
                fit: BoxFit.cover,
              ),
              border: Border.all(color: DesignTokens.clinicalTeal, width: 2),
              boxShadow: DesignTokens.glowTeal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Alex Jonathan',
            style: DesignTokens.headingMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Senior Developer',
            style: DesignTokens.bodySmall,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProfileStat('Projects', '42'),
              Container(width: 1, height: 32, color: DesignTokens.borderGray),
              _buildProfileStat('Following', '128'),
              Container(width: 1, height: 32, color: DesignTokens.borderGray),
              _buildProfileStat('Followers', '3.1k'),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.medicalBlue,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: DesignTokens.radiusSm,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'View Public Profile',
                style: DesignTokens.labelLarge,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: DesignTokens.borderGray),
                shape: const RoundedRectangleBorder(
                  borderRadius: DesignTokens.radiusSm,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Edit Settings',
                style: DesignTokens.labelLarge.copyWith(color: DesignTokens.textPrimary),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: DesignTokens.headingSmall,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: DesignTokens.labelSmall,
        ),
      ],
    );
  }
}
