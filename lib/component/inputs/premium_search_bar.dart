import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Premium search bar with smooth animations and debouncing
///
/// Features:
/// - Debounced search to avoid excessive queries
/// - Smooth expand/collapse animation
/// - Clear button
/// - Filter integration
class PremiumSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onSearch;
  final VoidCallback? onFilterTap;
  final bool showFilter;
  final Duration debounce;

  const PremiumSearchBar({
    super.key,
    this.hintText = 'Search...',
    required this.onSearch,
    this.onFilterTap,
    this.showFilter = false,
    this.debounce = const Duration(milliseconds: 500),
  });

  @override
  State<PremiumSearchBar> createState() => _PremiumSearchBarState();
}

class _PremiumSearchBarState extends State<PremiumSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(widget.debounce, () {
      widget.onSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDesign.durationNormal,
      curve: AppDesign.curveDefault,
      decoration: BoxDecoration(
        color: _isFocused ? Colors.white : AppDesign.neutral50,
        borderRadius: BorderRadius.circular(AppDesign.radiusFull),
        border: Border.all(
          color: _isFocused ? AppDesign.primaryStart : AppDesign.neutral200,
          width: _isFocused ? 2 : 1,
        ),
        boxShadow: _isFocused ? AppDesign.shadowMd : AppDesign.shadowSm,
      ),
      child: Row(
        children: [
          const SizedBox(width: AppDesign.space4),
          Icon(
            Icons.search,
            color: _isFocused ? AppDesign.primaryStart : AppDesign.neutral400,
            size: 20,
          ),
          const SizedBox(width: AppDesign.space2),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppDesign.bodyMedium.copyWith(
                  color: AppDesign.neutral400, // Lighter hint color
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              style: AppDesign.bodyMedium,
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                _controller.clear();
                widget.onSearch('');
              },
              color: AppDesign.neutral400,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (widget.showFilter) ...[
            const SizedBox(width: AppDesign.space2),
            IconButton(
              icon: const Icon(Icons.tune, size: 20),
              onPressed: widget.onFilterTap,
              color: _isFocused
                  ? AppDesign.primaryStart
                  : AppDesign.neutral500, // Different color when inactive
            ),
          ],
          const SizedBox(width: AppDesign.space2),
        ],
      ),
    );
  }
}
