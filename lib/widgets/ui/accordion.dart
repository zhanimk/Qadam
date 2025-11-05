
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';

/// A data class for an item in the [Accordion] widget.
class AccordionItem {
  final String title;
  final Widget content;

  AccordionItem({
    required this.title,
    required this.content,
  });
}

/// A custom accordion widget that displays a list of expandable items.
///
/// This widget is a Flutter implementation of the provided React accordion component.
/// It uses an [ExpansionPanelList] to create a vertically stacked list of items
/// that can be expanded or collapsed to reveal their content.
class Accordion extends StatefulWidget {
  /// The list of items to display in the accordion.
  final List<AccordionItem> items;
  
  /// Whether multiple panels can be open at once. Defaults to false.
  final bool allowMultiple;

  const Accordion({
    Key? key,
    required this.items,
    this.allowMultiple = false,
  }) : super(key: key);

  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  late List<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = List.generate(widget.items.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      elevation: 0,
      dividerColor: AppTheme.border,
      materialGapSize: 0,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          if (!widget.allowMultiple) {
            // Collapse all other panels
            for (int i = 0; i < _isExpanded.length; i++) {
              if (i != index) _isExpanded[i] = false;
            }
          }
          // Toggle the tapped panel
          _isExpanded[index] = !isExpanded;
        });
      },
      children: widget.items.asMap().entries.map<ExpansionPanel>((entry) {
        int index = entry.key;
        AccordionItem item = entry.value;
        return ExpansionPanel(
          backgroundColor: AppTheme.surface,
          canTapOnHeader: true,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: AppTheme.textTheme.titleMedium,
                    ),
                  ),
                  RotationTransition(
                    turns: _isExpanded[index]
                        ? const AlwaysStoppedAnimation(0.5)
                        : const AlwaysStoppedAnimation(0),
                    child: const Icon(
                      LucideIcons.chevronDown,
                      color: AppTheme.mutedForeground,
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          },
          body: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0, right: 24.0, left: 8.0), // Keep content from overlapping icon
              child: item.content,
            ),
          ),
          isExpanded: _isExpanded[index],
        );
      }).toList(),
    );
  }
}
