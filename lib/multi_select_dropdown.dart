part of 'custom_dropdown.dart';

class CustomMultiDropdown extends StatefulWidget {
  final List<Map<String, dynamic>>? items;
  final List<Map<String, dynamic>>? selectedValues;
  final String? nameKey;
  final String? nameMapKey;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? selectedStyle;
  final String? errorText;
  final TextStyle? errorStyle;
  final TextStyle? listItemStyle;
  final BorderSide? borderSide;
  final BorderSide? errorBorderSide;
  final BorderRadius? borderRadius;
  final Widget? fieldSuffixIcon;
  final Widget? fieldPrefixIcon;
  final Function(List<Map<String, dynamic>>)? onChanged;
  final bool? excludeSelected;
  final Color? fillColor;
  final EdgeInsets? contentPadding;
  final bool? canCloseOutsideBounds;
  final double? customOverRelayWidth;
  final Widget? label;
  final TextStyle? labelStyle;
  final String? labelText;
  final SearchType? searchType;
  final int? maxSelectedItems;
  final Widget Function(Map<String, dynamic>)? chipBuilder;
  final Widget? basicWidget;
  final void Function()? onRemoveClicked;
  final Color? selectedItemChipBackgroundColor;
  final String primaryIdKey;
  final Color selectColor;

  const CustomMultiDropdown({
    super.key,
    this.label,
    this.labelText,
    this.labelStyle,
    this.nameKey,
    this.nameMapKey,
    this.items,
    this.hintText,
    this.selectedValues,
    this.hintStyle,
    this.selectedStyle,
    this.errorText,
    this.errorStyle,
    this.listItemStyle,
    this.errorBorderSide,
    this.borderRadius,
    this.borderSide,
    this.fieldSuffixIcon,
    this.fieldPrefixIcon,
    this.onChanged,
    this.contentPadding,
    this.onRemoveClicked,
    this.basicWidget,
    this.customOverRelayWidth,
    this.excludeSelected = true,
    this.fillColor = Colors.white,
    this.maxSelectedItems = 5,
    this.chipBuilder,
    this.selectedItemChipBackgroundColor,
    required this.primaryIdKey,
    this.selectColor = Colors.black,
  }) : searchType = null,
       canCloseOutsideBounds = true;

  const CustomMultiDropdown.search({
    super.key,
    this.label,
    this.labelText,
    this.labelStyle,
    this.items,
    this.nameKey,
    this.nameMapKey,
    this.hintText,
    this.selectedValues,
    this.hintStyle,
    this.selectedStyle,
    this.errorText,
    this.errorStyle,
    this.listItemStyle,
    this.errorBorderSide,
    this.borderRadius,
    this.borderSide,
    this.basicWidget,
    this.fieldSuffixIcon,
    this.fieldPrefixIcon,
    this.onChanged,
    this.onRemoveClicked,
    this.contentPadding,
    this.customOverRelayWidth,
    this.excludeSelected = false,
    this.canCloseOutsideBounds = true,
    this.fillColor = Colors.white,
    this.maxSelectedItems = 5,
    this.chipBuilder,
    this.selectedItemChipBackgroundColor,
    required this.primaryIdKey,
    this.selectColor = Colors.black,
  }) : searchType = SearchType.onListData;

  @override
  CustomMultiDropdownState createState() => CustomMultiDropdownState();
}

class CustomMultiDropdownState extends State<CustomMultiDropdown> {
  final layerLink = LayerLink();
  late List<Map<String, dynamic>> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.selectedValues ?? [];
  }

  List<String> get dataItems =>
      widget.items
          ?.map(
            (element) =>
                (element[widget.nameKey] is Map)
                    ? (element[widget.nameKey][widget.nameMapKey]).toString()
                    : element[widget.nameKey].toString(),
          )
          .toList() ??
      [];

  String get selectedItemsText {
    if (_selectedItems.isEmpty) return widget.hintText ?? 'Select items';
    if (_selectedItems.length == 1) {
      return _selectedItems.first[widget.nameKey] is Map
          ? _selectedItems.first[widget.nameKey][widget.nameMapKey]
          : _selectedItems.first[widget.nameKey];
    }
    return '${_selectedItems.length} items selected';
  }

  void _onItemSelected(Map<String, dynamic> item) {
    final selectedIndex = _selectedItems.indexWhere(
      (selected) =>
          selected[widget.primaryIdKey].toString() ==
          item[widget.primaryIdKey].toString(),
    );

    setState(() {
      if (selectedIndex != -1) {
        _selectedItems.removeAt(selectedIndex);
      } else {
        if (widget.maxSelectedItems == null ||
            _selectedItems.length < widget.maxSelectedItems!) {
          _selectedItems.add(item);
        }
      }
    });
    widget.onChanged?.call(_selectedItems);
  }

  void _clearSelection() {
    setState(() {
      _selectedItems.clear();
    });
    widget.onChanged?.call(_selectedItems);
    widget.onRemoveClicked?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hintText = widget.hintText ?? 'Select items';
    final hintStyle = const TextStyle(
      fontSize: 16,
      color: Color(0xFFA7A7A7),
      fontWeight: FontWeight.w400,
    ).merge(widget.hintStyle);

    final selectedStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ).merge(widget.selectedStyle);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: AbsorbPointer(
        absorbing: (widget.items == null || (widget.items?.isEmpty ?? false)),
        child: _OverlayBuilder(
          overlay: (size, hideCallback) {
            return _MultiSelectDropdownOverlay(
              selectColor: widget.selectColor,
              primaryIdKey: widget.primaryIdKey,
              customOverRelayWidth: widget.customOverRelayWidth,
              items: widget.items ?? [],
              selectedItems: _selectedItems,
              nameKey: widget.nameKey,
              nameMapKey: widget.nameMapKey,
              size: size,
              layerLink: layerLink,
              hideOverlay: hideCallback,
              headerStyle:
                  _selectedItems.isNotEmpty ? selectedStyle : hintStyle,
              hintText: hintText,
              listItemStyle: widget.listItemStyle,
              excludeSelected: widget.excludeSelected,
              canCloseOutsideBounds: widget.canCloseOutsideBounds,
              searchType: widget.searchType,
              onItemSelected: _onItemSelected,
              maxSelectedItems: widget.maxSelectedItems,
            );
          },
          child: (showCallback) {
            return CompositedTransformTarget(
              link: layerLink,
              child:
                  widget.basicWidget != null
                      ? InkWell(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          showCallback();
                        },
                        child: widget.basicWidget,
                      )
                      : _MultiSelectDropDownField(
                        onItemRemoved: (item) {
                          setState(() {
                            _selectedItems.remove(item);
                          });
                          widget.onChanged?.call(_selectedItems);
                        },
                        selectedItemChipBackgroundColor:
                            widget.selectedItemChipBackgroundColor,
                        label: widget.label,
                        labelStyle: widget.labelStyle,
                        labelText: widget.labelText,
                        onRemoveClicked: _clearSelection,
                        isItemsNullOrEmpty: dataItems.isEmpty,
                        selectedItems: _selectedItems,
                        nameKey: widget.nameKey,
                        nameMapKey: widget.nameMapKey,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          showCallback();
                        },
                        style: selectedStyle,
                        borderRadius: widget.borderRadius,
                        borderSide: widget.borderSide,
                        errorBorderSide: widget.errorBorderSide,
                        errorStyle: widget.errorStyle,
                        errorText: widget.errorText,
                        hintStyle: hintStyle,
                        hintText: hintText,
                        prefixIcon: widget.fieldPrefixIcon,
                        suffixIcon: widget.fieldSuffixIcon,
                        fillColor: widget.fillColor,
                        contentPadding: widget.contentPadding,
                        chipBuilder: widget.chipBuilder,
                      ),
            );
          },
        ),
      ),
    );
  }
}
