import 'package:eClassify/ui/screens/location/helpers/debounce_search_mixin.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:flutter/material.dart';

class ChatSearchBar extends StatefulWidget {
  const ChatSearchBar({
    required this.onSearch,
    required this.onClear,
    super.key,
  });

  final ValueChanged<String?> onSearch;
  final VoidCallback onClear;

  @override
  State<ChatSearchBar> createState() => _ChatSearchBarState();
}

class _ChatSearchBarState extends State<ChatSearchBar>
    with DebounceSearchMixin {
  late final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void onDebouncedSearch(String? value) {
    if (value.isNullOrEmpty) {
      widget.onClear();
    } else {
      widget.onSearch(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: false,
      focusNode: _focusNode,
      controller: _searchController,
      onChanged: onChanged,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: 'search'.translate(context),
        hintStyle: TextStyle(color: context.color.textLightColor),
        prefixIcon: Icon(Icons.search, color: context.color.territoryColor),
        suffixIcon: ListenableBuilder(
          listenable: _searchController,
          builder: (context, child) {
            return _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      widget.onClear();
                    },
                    icon: Icon(
                      Icons.clear,
                      color: context.color.textLightColor,
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
        prefixIconConstraints: BoxConstraints.tight(const Size.square(38)),
        constraints: const BoxConstraints(maxHeight: 48),
      ),
      onTapOutside: (_) {
        _focusNode.unfocus();
      },
    );
  }
}
