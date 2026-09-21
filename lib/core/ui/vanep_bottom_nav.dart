import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';

/// Matches [VanepColors.actionSurface] (`0x14` alpha) so the selected pill
/// keeps the same tint the cards and badges use.
const double _selectedPillOpacity = 0.08;

/// The bar lays its destinations out with `spaceBetween`, so the outer two sit
/// flush against whatever room they are given. Insetting the row pulls them in
/// towards the centre instead of letting them hug the screen edges.
const EdgeInsets _rowMargin = EdgeInsets.symmetric(horizontal: 24, vertical: 8);

class VanepNavItem {
  const VanepNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Bottom navigation where the selected destination expands into a labelled
/// stadium pill and the others stay icon-only.
class VanepBottomNav extends StatelessWidget {
  const VanepBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final List<VanepNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return SalomonBottomBar(
      currentIndex: currentIndex,
      onTap: onDestinationSelected,
      backgroundColor: VanepColors.card,
      selectedItemColor: VanepColors.action,
      unselectedItemColor: VanepColors.textSecondary,
      selectedColorOpacity: _selectedPillOpacity,
      margin: _rowMargin,
      items: [
        for (var index = 0; index < items.length; index++)
          navBarItem(items[index], selected: index == currentIndex),
      ],
    );
  }
}

SalomonBottomBarItem navBarItem(VanepNavItem item, {required bool selected}) {
  return SalomonBottomBarItem(
    icon: NavItemIcon(item: item, selected: false),
    activeIcon: NavItemIcon(item: item, selected: true),
    // The label is announced by [NavItemIcon] whether or not it is selected;
    // without this the unselected labels would be clipped out of semantics.
    title: ExcludeSemantics(
      child: Text(item.label, style: VanepTypography.button),
    ),
  );
}

class NavItemIcon extends StatelessWidget {
  const NavItemIcon({required this.item, required this.selected, super.key});

  final VanepNavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: item.label,
      selected: selected,
      child: ExcludeSemantics(
        child: Icon(selected ? item.selectedIcon : item.icon),
      ),
    );
  }
}
