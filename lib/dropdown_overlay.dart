part of 'custom_dropdown.dart';

const _headerPadding = EdgeInsets.only(
  left: 16.0,
  top: 16,
  bottom: 16,
  right: 14,
);
const _overlayOuterPadding = EdgeInsets.only(bottom: 12, left: 12, right: 12);
const _overlayShadowOffset = Offset(0, 6);
const _listItemPadding = EdgeInsets.symmetric(vertical: 12, horizontal: 16);

class _DropdownOverlay extends StatefulWidget {
  final List<String> items;
  final TextEditingController controller;
  final Size size;
  final LayerLink layerLink;
  final VoidCallback hideOverlay;
  final String hintText;
  final TextStyle? headerStyle;
  final TextStyle? listItemStyle;
  final bool? excludeSelected;
  final bool? canCloseOutsideBounds;
  final SearchType? searchType;
  final Function(String)? onChanged;
  final double? customOverRelayWidth;
  final String? searchHintText;
  final BorderRadius? borderRadius;

  const _DropdownOverlay({
    required this.items,
    required this.controller,
    required this.size,
    required this.layerLink,
    required this.hideOverlay,
    required this.hintText,
    this.headerStyle,
    this.listItemStyle,
    this.excludeSelected,
    this.canCloseOutsideBounds,
    this.searchType,
    this.customOverRelayWidth,
    this.onChanged,
    this.searchHintText,
    this.borderRadius,
  });

  @override
  _DropdownOverlayState createState() => _DropdownOverlayState();
}

class _DropdownOverlayState extends State<_DropdownOverlay> {
  bool displayOverly = true;
  bool displayOverlayBottom = true;
  late String headerText;
  late List<String> items;
  late List<String> filteredItems;
  final key1 = GlobalKey(), key2 = GlobalKey();
  final scrollController = ScrollController();
  String? prevText;
  bool listenChanges = true;

  void listenItemChanges() {
    if (listenChanges) {
      final text = widget.controller.text;
      if (prevText != null && prevText != text && text.isNotEmpty) {
        // widget.onChanged!(text);
      }
      prevText = text;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.onChanged != null) {
      widget.controller.addListener(listenItemChanges);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final render1 = key1.currentContext?.findRenderObject() as RenderBox;
      final render2 = key2.currentContext?.findRenderObject() as RenderBox;
      final screenHeight = MediaQuery.of(context).size.height;
      double y = render1.localToGlobal(Offset.zero).dy;
      if (screenHeight - y < render2.size.height) {
        displayOverlayBottom = false;
        setState(() {});
      }
    });

    headerText = widget.controller.text;
    if (widget.excludeSelected! &&
        widget.items.length > 1 &&
        widget.controller.text.isNotEmpty) {
      items = widget.items.where((item) => item != headerText).toList();
    } else {
      items = widget.items;
    }
    filteredItems = items;
  }

  @override
  void dispose() {
    scrollController.dispose();
    widget.controller.removeListener(listenItemChanges);

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _DropdownOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onChanged != null) {
      widget.controller.addListener(listenItemChanges);
    } else {
      listenChanges = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // search availability check
    final onListDataSearch = widget.searchType == SearchType.onListData;

    // overlay icon
    final overlayIcon = Icon(
      displayOverlayBottom
          ? Icons.keyboard_arrow_up_rounded
          : Icons.keyboard_arrow_down_rounded,
      color: Colors.black,
      size: 20,
    );

    // overlay offset
    final overlayOffset = Offset(-12, displayOverlayBottom ? 0 : 60);

    // list padding
    final listPadding =
        onListDataSearch ? const EdgeInsets.only(top: 8) : EdgeInsets.zero;

    // items list
    final list =
        items.isNotEmpty
            ? _ItemsList(
              scrollController: scrollController,
              excludeSelected:
                  widget.items.length > 1 ? widget.excludeSelected! : false,
              items: items,
              padding: listPadding,
              headerText: headerText,
              itemTextStyle: widget.listItemStyle,
              onItemSelect: (value) async {
                setState(() => displayOverly = false);
                await Future.delayed(const Duration(milliseconds: 300));
                if (headerText != value) {
                  widget.controller.text = value;
                  widget.onChanged?.call(widget.controller.text);
                }
              },
            )
            : const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('No result found.', style: TextStyle(fontSize: 16)),
              ),
            );

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
              key: key1,
              padding: _overlayOuterPadding,
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
                      key: key2,
                      // height: items.length > 4
                      //     ? onListDataSearch
                      //         ? 270
                      //         : 225
                      //     : null,
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
                                  padding: _headerPadding,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          headerText.isNotEmpty
                                              ? headerText
                                              : widget.hintText,
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
                                  _SearchField(
                                    items: filteredItems,
                                    searchHintText: widget.searchHintText,
                                    onSearchedItems: (val) {
                                      setState(() => items = val);
                                    },
                                  ),
                                items.length > 4 ? Expanded(child: list) : list,
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
      onTap: () => setState(() => displayOverly = false),
      child:
          widget.canCloseOutsideBounds!
              ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.transparent,
                child: child,
              )
              : child,
    );
  }
}

class _ItemsList extends StatelessWidget {
  final ScrollController scrollController;
  final List<String> items;
  final bool excludeSelected;
  final String headerText;
  final ValueSetter<String> onItemSelect;
  final EdgeInsets padding;
  final TextStyle? itemTextStyle;

  const _ItemsList({
    required this.scrollController,
    required this.items,
    required this.excludeSelected,
    required this.headerText,
    required this.onItemSelect,
    required this.padding,
    this.itemTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final listItemStyle = const TextStyle(fontSize: 16).merge(itemTextStyle);

    return Scrollbar(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        padding: padding,
        itemCount: items.length,
        itemBuilder: (_, index) {
          final selected = !excludeSelected && headerText == items[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.grey[200],
              onTap: () => onItemSelect(items[index]),
              child: Container(
                color: selected ? Colors.grey[100] : Colors.transparent,
                padding: _listItemPadding,
                child: Text(
                  items[index],
                  style: listItemStyle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  final String? searchHintText;
  final List<String> items;
  final void Function(List<String>) onSearchedItems;
  const _SearchField({
    required this.items,
    required this.onSearchedItems,
    this.searchHintText,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final searchCtrl = TextEditingController();
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  void onSearch(String str) {
    final result =
        widget.items
            .where((item) => item.toLowerCase().contains(str.toLowerCase()))
            .toList();
    widget.onSearchedItems(result);
  }

  void onClear() {
    if (searchCtrl.text.isNotEmpty) {
      searchCtrl.clear();
      widget.onSearchedItems(widget.items);
      _focusNode?.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        focusNode: _focusNode,
        controller: searchCtrl,
        onChanged: onSearch,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[50],
          constraints: const BoxConstraints.tightFor(height: 40),
          contentPadding: const EdgeInsets.all(8),
          hintText: widget.searchHintText ?? 'Search',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
          suffixIcon: GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, color: Colors.grey, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(.25),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(.25),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(.25),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
