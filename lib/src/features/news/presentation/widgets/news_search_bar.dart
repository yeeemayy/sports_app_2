import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/shared_widgets/custom_text_field.dart';

class NewsSearchBar extends StatefulWidget {
  const NewsSearchBar({
    super.key,
    required this.onSearch,
    this.debounceMs = 500,
  });

  final ValueChanged<String> onSearch;
  final int debounceMs;

  @override
  State<NewsSearchBar> createState() => _NewsSearchBarState();
}

class _NewsSearchBarState extends State<NewsSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      widget.onSearch(value.trim());
    });
  }

  void _onClear() {
    _controller.clear();
    _debounce?.cancel();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      textEditingController: _controller,
      onChanged: _onChanged,
      hintText: 'news.search_hint'.tr(),
      prefixIcon: const Icon(Icons.search, size: 20),
      suffixIcon: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (_, value, __) {
          if (value.text.isEmpty) return const SizedBox.shrink();
          return IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: _onClear,
          );
        },
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
    );
  }
}
