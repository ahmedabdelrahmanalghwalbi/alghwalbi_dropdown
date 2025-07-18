part of 'custom_dropdown.dart';

class _MultiSelectDropdownOverlay extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> selectedItems;
  final String? nameKey;
  final String? subNameKey;
  final String? nameMapKey;
  final Size size;
  final LayerLink layerLink;
  final VoidCallback hideOverlay;
  final String hintText;
  final TextStyle? headerStyle;
  final TextStyle? listItemStyle;
  final bool? excludeSelected;
  final bool? canCloseOutsideBounds;
  final SearchType? searchType;
  final Function(Map<String, dynamic>) onItemSelected;
  final int? maxSelectedItems;
  final double? customOverRelayWidth;
  final String primaryIdKey;
  final Color selectColor;
  final VoidCallback? onComplete;
  final String? searchHintText;
  final BorderRadius? borderRadius;

  const _MultiSelectDropdownOverlay({
    required this.items,
    required this.selectedItems,
    required this.nameKey,
    this.subNameKey,
    this.nameMapKey,
    required this.size,
    required this.layerLink,
    required this.hideOverlay,
    required this.hintText,
    required this.primaryIdKey,
    required this.selectColor,
    this.headerStyle,
    this.listItemStyle,
    this.excludeSelected,
    this.canCloseOutsideBounds,
    this.searchType,
    required this.onItemSelected,
    this.maxSelectedItems,
    this.customOverRelayWidth,
    this.onComplete,
    this.searchHintText,
    this.borderRadius,
  });

  @override
  _MultiSelectDropdownOverlayState createState() =>
      _MultiSelectDropdownOverlayState();
}

class _MultiSelectDropdownOverlayState
    extends State<_MultiSelectDropdownOverlay> {
  bool displayOverly = true;
  bool displayOverlayBottom = true;
  late List<Map<String, dynamic>> items;
  late List<Map<String, dynamic>> filteredItems;
  final scrollController = ScrollController();
  final searchCtrl = TextEditingController();
  void onSearch(String str) {
    try {
      if (str.isEmpty) {
        setState(() => items = widget.items);
        return;
      }
      final result =
          widget.items.where((item) {
            final displayText =
                item[widget.nameKey] is Map
                    ? (item[widget.nameKey][widget.nameMapKey] ?? '').toString()
                    : (item[widget.nameKey] ?? '').toString();
            return displayText.toLowerCase().contains(str.toLowerCase());
          }).toList();

      setState(() => items = result);
    } catch (ex, t) {
      setState(() => items = []);
      log('Search Error', error: ex, stackTrace: t);
    }
  }

  @override
  void initState() {
    super.initState();
    items = widget.items;
    filteredItems = widget.items;
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchCtrl.dispose();
    super.dispose();
  }

  String getSelectedText() {
    if (widget.selectedItems.isEmpty) return widget.hintText;
    if (widget.selectedItems.length == 1) {
      return widget.selectedItems.first[widget.nameKey] is Map
          ? widget.selectedItems.first[widget.nameKey][widget.nameMapKey]
          : widget.selectedItems.first[widget.nameKey];
    }
    return '${widget.selectedItems.length} items selected';
  }

  @override
  Widget build(BuildContext context) {
    final onListDataSearch = widget.searchType == SearchType.onListData;
    final overlayIcon = Icon(
      displayOverlayBottom
          ? Icons.keyboard_arrow_up_rounded
          : Icons.keyboard_arrow_down_rounded,
      color: Colors.black,
      size: 20,
    );
    final overlayOffset = Offset(-12, displayOverlayBottom ? 0 : 60);
    final listPadding =
        onListDataSearch ? const EdgeInsets.only(top: 8) : EdgeInsets.zero;

    final child = Stack(
      children: [
        Positioned(
          width: widget.customOverRelayWidth ?? widget.size.width + 23,
          child: CompositedTransformFollower(
            link: widget.layerLink,
            followerAnchor:
                displayOverlayBottom ? Alignment.topLeft : Alignment.bottomLeft,
            showWhenUnlinked: false,
            offset: overlayOffset,
            child: Container(
              padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 24.0,
                      color: Colors.black.withOpacity(.08),
                      offset: _overlayShadowOffset,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedSection(
                    animationDismissed: widget.hideOverlay,
                    expand: displayOverly,
                    axisAlignment: displayOverlayBottom ? 1.0 : -1.0,
                    child: SizedBox(
                      height:
                          items.length > 4
                              ? MediaQuery.of(context).size.height / 2
                              : null,
                      child: ClipRRect(
                        borderRadius:
                            widget.borderRadius ?? BorderRadius.circular(12.0),
                        child: NotificationListener<
                          OverscrollIndicatorNotification
                        >(
                          onNotification: (notification) {
                            notification.disallowIndicator();
                            return true;
                          },
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                                thumbVisibility: WidgetStateProperty.all(true),
                                thickness: WidgetStateProperty.all(5),
                                radius: const Radius.circular(4),
                                thumbColor: WidgetStateProperty.all(
                                  Colors.grey[300],
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16.0,
                                    top: 16,
                                    bottom: 16,
                                    right: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          getSelectedText(),
                                          style: widget.headerStyle,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      overlayIcon,
                                    ],
                                  ),
                                ),
                                if (onListDataSearch)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: TextField(
                                      controller: searchCtrl,
                                      onChanged: onSearch,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        constraints:
                                            const BoxConstraints.tightFor(
                                              height: 40,
                                            ),
                                        contentPadding: const EdgeInsets.all(8),
                                        hintText: widget.searchHintText,
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                          size: 22,
                                        ),
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            searchCtrl.clear();
                                            onSearch('');
                                          },
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(.25),
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(.25),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(.25),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                (items.isEmpty)
                                    ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.0,
                                        ),
                                        child: Text(
                                          'No result found.',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    )
                                    : items.length > 4
                                    ? Expanded(
                                      child: _MultiSelectItemsList(
                                        selectColor: widget.selectColor,
                                        primaryIdKey: widget.primaryIdKey,
                                        scrollController: scrollController,
                                        items: items,
                                        selectedItems: widget.selectedItems,
                                        nameKey: widget.nameKey,
                                        nameMapKey: widget.nameMapKey,
                                        padding: listPadding,
                                        itemTextStyle: widget.listItemStyle,
                                        subNameKey: widget.subNameKey,
                                        onItemSelect: (item) {
                                          widget.onItemSelected(item);
                                          if (searchCtrl.text.isNotEmpty) {
                                            searchCtrl.clear();
                                            onSearch('');
                                          }
                                          setState(() {});
                                        },
                                        maxSelectedItems:
                                            widget.maxSelectedItems,
                                      ),
                                    )
                                    : _MultiSelectItemsList(
                                      selectColor: widget.selectColor,
                                      primaryIdKey: widget.primaryIdKey,
                                      scrollController: scrollController,
                                      items: items,
                                      selectedItems: widget.selectedItems,
                                      nameKey: widget.nameKey,
                                      nameMapKey: widget.nameMapKey,
                                      padding: listPadding,
                                      itemTextStyle: widget.listItemStyle,
                                      subNameKey: widget.subNameKey,
                                      onItemSelect: (item) {
                                        widget.onItemSelected(item);
                                        if (searchCtrl.text.isNotEmpty) {
                                          searchCtrl.clear();
                                          onSearch('');
                                        }
                                        setState(() {});
                                      },
                                      maxSelectedItems: widget.maxSelectedItems,
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: () {
        if (displayOverly) {
          setState(() => displayOverly = false);
          widget.hideOverlay();
        }
      },
      child:
          widget.canCloseOutsideBounds!
              ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.transparent,
                child: child,
                // child: Column(
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //     Expanded(child: child),
                //     if (widget.onComplete != null)
                //       Padding(
                //         padding: const EdgeInsets.all(8.0),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.end,
                //           children: [
                //             if (widget.onComplete != null)
                //               ElevatedButton(
                //                 onPressed: () {
                //                   widget.hideOverlay();
                //                   widget.onComplete?.call();
                //                 },
                //                 child: const Text('Confirm'),
                //               ),
                //           ],
                //         ),
                //       ),
                //   ],
                // ),
              )
              : child,
    );
  }
}

class _MultiSelectItemsList extends StatefulWidget {
  final ScrollController scrollController;
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> selectedItems;
  final String? nameKey;
  final String? subNameKey;
  final String? nameMapKey;
  final String primaryIdKey;
  final ValueSetter<Map<String, dynamic>> onItemSelect;
  final EdgeInsets padding;
  final TextStyle? itemTextStyle;
  final int? maxSelectedItems;
  final Color selectColor;

  const _MultiSelectItemsList({
    required this.primaryIdKey,
    required this.scrollController,
    required this.items,
    required this.selectedItems,
    required this.nameKey,
    this.subNameKey,
    this.nameMapKey,
    required this.onItemSelect,
    required this.padding,
    this.itemTextStyle,
    this.maxSelectedItems,
    required this.selectColor,
  });

  @override
  State<_MultiSelectItemsList> createState() => _MultiSelectItemsListState();
}

class _MultiSelectItemsListState extends State<_MultiSelectItemsList> {
  Set<String> get selectedItemIds =>
      widget.selectedItems
          .map((item) => item[widget.primaryIdKey].toString())
          .toSet();

  @override
  Widget build(BuildContext context) {
    final listItemStyle = const TextStyle(
      fontSize: 14.0,
      color: Colors.black87,
    );
    return ListView.builder(
      controller: widget.scrollController,
      shrinkWrap: true,
      padding: widget.padding,
      itemCount: widget.items.length,
      itemBuilder: (_, index) {
        final item = widget.items[index];
        final itemId = item[widget.primaryIdKey].toString();
        final displayText =
            item[widget.nameKey] is Map
                ? item[widget.nameKey][widget.nameMapKey].toString()
                : item[widget.nameKey].toString();
        final subDisplayText =
            widget.subNameKey != null ? item[widget.subNameKey] : null;
        final isSelected = selectedItemIds.contains(itemId);
        final isDisabled =
            widget.maxSelectedItems != null &&
            widget.selectedItems.length >= widget.maxSelectedItems! &&
            !isSelected;

        return InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.grey[200],
          onTap:
              isDisabled
                  ? null
                  : () {
                    widget.onItemSelect(item);
                  },
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 12.0,
            ),
            child: Row(
              spacing: 8.0,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isSelected
                    ? Icon(
                      Icons.check_box_rounded,
                      size: 16.0,
                      color: widget.selectColor,
                    )
                    : Icon(
                      Icons.check_box_outline_blank,
                      color:
                          isDisabled ? Colors.grey[400] : listItemStyle.color,
                      size: 16.0,
                    ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        displayText,
                        style: listItemStyle.copyWith(
                          color:
                              isDisabled
                                  ? Colors.grey[400]
                                  : listItemStyle.color,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (subDisplayText != null)
                        Text(
                          subDisplayText,
                          style: TextStyle(color: Colors.grey, fontSize: 12.0),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
