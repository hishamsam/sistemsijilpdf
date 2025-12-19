import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_styles.dart';
import '../core/localization/app_strings.dart';
import 'responsive_layout.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isCollapsed;
  final VoidCallback? onToggle;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF252836) : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDark ? Colors.white60 : AppColors.textSecondary;
    final dividerColor = isDark ? Colors.white12 : AppColors.divider;
    final bgColor = isDark ? const Color(0xFF1A1C2A) : AppColors.background;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final showCollapsed = isCollapsed || screenWidth < 900;
    final sidebarWidth = showCollapsed ? 70.0 : 260.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: sidebarWidth,
      color: surfaceColor,
      child: Column(
        children: [
          // Logo section
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 24,
              horizontal: showCollapsed ? 12 : 24,
            ),
            child: showCollapsed
                ? Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr(context, 'system_sijil'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            Text(
                              tr(context, 'certificate_management'),
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),

          Divider(height: 1, color: dividerColor),
          const SizedBox(height: 16),

          // Menu items
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: showCollapsed ? 8 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!showCollapsed)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 8),
                      child: Text(
                        tr(context, 'main_menu'),
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  _SidebarItem(
                    icon: Icons.dashboard_rounded,
                    label: tr(context, 'dashboard'),
                    isSelected: selectedIndex == 0,
                    isCollapsed: showCollapsed,
                    onTap: () => onItemSelected(0),
                  ),
                  _SidebarItem(
                    icon: Icons.folder_rounded,
                    label: tr(context, 'program'),
                    isSelected: selectedIndex == 1,
                    isCollapsed: showCollapsed,
                    onTap: () => onItemSelected(1),
                  ),
                  _SidebarItem(
                    icon: Icons.people_rounded,
                    label: tr(context, 'participants'),
                    isSelected: selectedIndex == 2,
                    isCollapsed: showCollapsed,
                    onTap: () => onItemSelected(2),
                  ),
                  _SidebarItem(
                    icon: Icons.how_to_reg_rounded,
                    label: tr(context, 'counter_registration'),
                    isSelected: selectedIndex == 3,
                    isCollapsed: showCollapsed,
                    onTap: () => onItemSelected(3),
                  ),
                  _SidebarItem(
                    icon: Icons.verified_rounded,
                    label: tr(context, 'certificate_verification'),
                    isSelected: selectedIndex == 4,
                    isCollapsed: showCollapsed,
                    onTap: () => onItemSelected(4),
                  ),
                  if (!showCollapsed) const SizedBox(height: 24),
                  if (!showCollapsed)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 8),
                      child: Text(
                        tr(context, 'others'),
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  _SidebarItem(
                    icon: Icons.settings_rounded,
                    label: tr(context, 'settings'),
                    isSelected: selectedIndex == 5,
                    isCollapsed: showCollapsed,
                    onTap: () => onItemSelected(5),
                  ),
                ],
              ),
            ),
          ),

          // Created by credit
          Divider(height: 1, color: dividerColor),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: showCollapsed ? 8 : 16,
            ),
            child: showCollapsed
                ? Tooltip(
                    message: 'Developed by Hishamsam',
                    child: Icon(
                      Icons.code,
                      size: 16,
                      color: secondaryTextColor,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.code,
                        size: 14,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Developed by Hishamsam',
                        style: TextStyle(
                          fontSize: 11,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isCollapsed = false,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDark ? Colors.white60 : AppColors.textSecondary;
    final hoverColor = isDark ? Colors.white10 : AppColors.background;

    final item = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 4),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 0 : 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary
                : _isHovered
                    ? hoverColor
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
          child: widget.isCollapsed
              ? Center(
                  child: Icon(
                    widget.icon,
                    size: 22,
                    color: widget.isSelected ? AppColors.white : secondaryTextColor,
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: 22,
                      color: widget.isSelected ? AppColors.white : secondaryTextColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: widget.isSelected ? AppColors.white : textColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    if (widget.isCollapsed) {
      return Tooltip(
        message: widget.label,
        preferBelow: false,
        child: item,
      );
    }
    return item;
  }
}
