// Exports - only export the main library file
export 'custom_dropdown.dart';

// Imports
import 'dart:developer';
import 'package:flutter/material.dart';

// Parts
part 'animated_section.dart';
part 'dropdown_field.dart';
part 'dropdown_overlay.dart';
part 'overlay_builder.dart';
part 'multi_select_dropdown.dart';
part 'multi_select_dropdown_field.dart';
part 'multi_select_dropdown_overlay.dart';
part 'multi_select_controller.dart';

enum SearchType { onListData }

// ignore: must_be_immutable
class CustomDropdown extends StatefulWidget {
  final List<Map<String, dynamic>>? items;
  final Map<String, dynamic>? selectedValue;
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
  final Function(Map<String, dynamic>)? onChanged;
  final bool? excludeSelected;
  final Color? fillColor;
  final EdgeInsets? contentPadding;
  final bool? canCloseOutsideBounds;
  final double? customOverRelayWidth;
  final Widget? label;
  final TextStyle? labelStyle;
  final String? labelText;
  Map<String, String>? headers;
  final SearchType? searchType;

  /// the widget you click at to open drop down
  final Widget? basicWidget;

  final void Function()? onRemoveClicked;

  CustomDropdown({
    super.key,
    this.label,
    this.labelText,
    this.labelStyle,
    this.nameKey,
    this.nameMapKey,
    this.items,
    this.hintText,
    this.selectedValue,
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
  }) : searchType = null,
       canCloseOutsideBounds = true;

  CustomDropdown.search({
    super.key,
    this.label,
    this.labelText,
    this.labelStyle,
    this.items,
    this.nameKey,
    this.nameMapKey,
    this.hintText,
    this.selectedValue,
    this.hintStyle,
    this.selectedStyle,
    this.errorText,
    this.errorStyle,
    this.listItemStyle,
    this.errorBorderSide,
    this.headers,
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
  }) : searchType = SearchType.onListData;

  @override
  CustomDropdownState createState() => CustomDropdownState();
}

class CustomDropdownState extends State<CustomDropdown> {
  final layerLink = LayerLink();
  late TextEditingController textEditingController;
  String? _initSelected;

  @override
  void initState() {
    super.initState();
    init();
  }

  String? get widgetSelectedValue =>
      (widget.selectedValue?[widget.nameKey] is Map)
          ? (widget.selectedValue?[widget.nameKey][widget.nameMapKey])
          : widget.selectedValue?[widget.nameKey];

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

  void init() {
    textEditingController = TextEditingController(text: widgetSelectedValue);
    _initSelected = textEditingController.text;
  }

  void onChangeEx(String value) {
    var result = widget.items?.indexWhere(
      (e) =>
          ((e[widget.nameKey] is Map)
              ? e[widget.nameKey][widget.nameMapKey]
              : e[widget.nameKey]) ==
          value,
    );
    if (result != -1) {
      widget.onChanged?.call(widget.items?[result ?? 0] ?? {});
    } else {
      widget.onChanged?.call({});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initSelected != widgetSelectedValue) {
      textEditingController.text = widgetSelectedValue ?? '';
      _initSelected = widgetSelectedValue;
    }

    /// hint text
    final hintText = widget.hintText ?? 'Select value';

    // hint style :: if provided then merge with default
    final hintStyle = const TextStyle(
      fontSize: 16,
      color: Color(0xFFA7A7A7),
      fontWeight: FontWeight.w400,
    ).merge(widget.hintStyle);

    // selected item style :: if provided then merge with default
    final selectedStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ).merge(widget.selectedStyle);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: AbsorbPointer(
        absorbing:
            ((widget.items == null) || (widget.items?.isEmpty ?? false))
                ? true
                : false,
        child: _OverlayBuilder(
          overlay: (size, hideCallback) {
            return _DropdownOverlay(
              customOverRelayWidth: widget.customOverRelayWidth,
              items: dataItems,
              controller: textEditingController,
              size: size,
              layerLink: layerLink,
              hideOverlay: hideCallback,
              headerStyle:
                  (textEditingController.text.isNotEmpty)
                      ? selectedStyle
                      : hintStyle,
              hintText: hintText,
              listItemStyle: widget.listItemStyle,
              excludeSelected: widget.excludeSelected,
              canCloseOutsideBounds: widget.canCloseOutsideBounds,
              searchType: widget.searchType,
              onChanged: (value) {
                onChangeEx(value);
                FocusScope.of(context).unfocus();
              },
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
                      : _DropDownField(
                        label: widget.label,
                        labelStyle: widget.labelStyle,
                        labelText: widget.labelText,
                        onRemoveClicked: widget.onRemoveClicked,
                        isItemsNullOrEmpty: dataItems.isEmpty,
                        controller: textEditingController,
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
                        // onChanged: widget.onChanged,
                        fillColor: widget.fillColor,
                        contentPadding: widget.contentPadding,
                      ),
            );
          },
        ),
      ),
    );
  }
}
