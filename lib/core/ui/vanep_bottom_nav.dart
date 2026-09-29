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

const EdgeInsets _itemPadding = EdgeInsets.symmetric(
  vertical: 10,
  horizontal: 16,
);

const double _navIconSize = 24;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelMaxWidth = measureSelectedLabelMaxWidth(
          barWidth: constraints.maxWidth,
          itemCount: items.length,
        );
        return SalomonBottomBar(
          currentIndex: currentIndex,
          onTap: onDestinationSelected,
          backgroundColor: VanepColors.card,
          selectedItemColor: VanepColors.action,
          unselectedItemColor: VanepColors.textSecondary,
          selectedColorOpacity: _selectedPillOpacity,
          margin: _rowMargin,
          itemPadding: _itemPadding,
          items: [
            for (var index = 0; index < items.length; index++)
              navBarItem(
                items[index],
                selected: index == currentIndex,
                labelMaxWidth: labelMaxWidth,
              ),
          ],
        );
      },
    );
  }
}

double measureSelectedLabelMaxWidth({
  required double barWidth,
  required int itemCount,
}) {
  final collapsedItemWidth = _navIconSize + _itemPadding.horizontal;
  final selectedItemChromeWidth =
      _navIconSize +
      _itemPadding.left +
      _itemPadding.left / 2 +
      _itemPadding.right;
  final remaining =
      barWidth -
      _rowMargin.horizontal -
      collapsedItemWidth * (itemCount - 1) -
      selectedItemChromeWidth;
  return remaining < 0 ? 0 : remaining;
}

SalomonBottomBarItem navBarItem(
  VanepNavItem item, {
  required bool selected,
  required double labelMaxWidth,
}) {
  return SalomonBottomBarItem(
    icon: NavItemIcon(item: item, selected: false),
    activeIcon: NavItemIcon(item: item, selected: true),
    // The label is announced by [NavItemIcon] whether or not it is selected;
    // without this the unselected labels would be clipped out of semantics.
    title: ExcludeSemantics(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: labelMaxWidth),
        child: Text(
          item.label,
          style: VanepTypography.button,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
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
