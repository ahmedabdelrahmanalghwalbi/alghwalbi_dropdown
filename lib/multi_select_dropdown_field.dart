part of 'custom_dropdown.dart';

class _MultiSelectDropDownField extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final String? nameKey;
  final String? nameMapKey;
  final VoidCallback onTap;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final String? errorText;
  final TextStyle? errorStyle;
  final BorderSide? borderSide;
  final BorderSide? errorBorderSide;
  final BorderRadius? borderRadius;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Color? fillColor;
  final EdgeInsets? contentPadding;
  final bool isItemsNullOrEmpty;
  final Widget? label;
  final TextStyle? labelStyle;
  final String? labelText;
  final void Function()? onRemoveClicked;
  final Widget Function(Map<String, dynamic>)? chipBuilder;
  final Color? selectedItemChipBackgroundColor;
  final Function(Map<String, dynamic>)? onItemRemoved;

  const _MultiSelectDropDownField({
    required this.selectedItems,
    required this.nameKey,
    this.nameMapKey,
    required this.onTap,
    this.label,
    this.labelText,
    this.labelStyle,
    this.suffixIcon,
    this.prefixIcon,
    this.isItemsNullOrEmpty = false,
    this.hintText,
    this.hintStyle,
    this.style,
    this.errorText,
    this.errorStyle,
    this.errorBorderSide,
    this.borderRadius,
    this.borderSide,
    this.fillColor,
    this.onRemoveClicked,
    this.contentPadding,
    this.chipBuilder,
    this.selectedItemChipBackgroundColor,
    this.onItemRemoved,
  });

  @override
  State<_MultiSelectDropDownField> createState() =>
      _MultiSelectDropDownFieldState();
}

class _MultiSelectDropDownFieldState extends State<_MultiSelectDropDownField> {
  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
      borderSide:
          widget.borderSide ?? const BorderSide(color: Colors.transparent),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
      borderSide:
          widget.errorBorderSide ??
          const BorderSide(color: Colors.redAccent, width: 2),
    );

    return InkWell(
      onTap: widget.onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          label: widget.label,
          labelStyle: widget.labelStyle,
          labelText: widget.labelText,
          isDense: true,
          contentPadding:
              widget.contentPadding ?? const EdgeInsets.only(left: 16),
          prefixIcon: widget.prefixIcon,
          suffixIcon:
              widget.suffixIcon ??
              (widget.selectedItems.isNotEmpty
                  ? InkWell(
                    onTap: () {
                      widget.onRemoveClicked?.call();
                      setState(() {});
                    },
                    child: const Icon(Icons.close, color: Colors.red, size: 20),
                  )
                  : Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color:
                        widget.isItemsNullOrEmpty ? Colors.grey : Colors.black,
                    size: 20,
                  )),
          hintText: widget.hintText,
          hintStyle: widget.hintStyle,
          fillColor: widget.fillColor,
          filled: true,
          errorStyle:
              widget.errorText != null
                  ? widget.errorStyle
                  : const TextStyle(height: 0),
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          errorBorder: errorBorder,
          focusedErrorBorder: errorBorder,
        ),
        child:
            widget.selectedItems.isEmpty
                ? Text(
                  widget.hintText ?? 'Select items',
                  style: widget.hintStyle,
                )
                : Wrap(
                  spacing: 8.0,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  runAlignment: WrapAlignment.start,
                  children:
                      widget.selectedItems.map((item) {
                        final displayText =
                            item[widget.nameKey] is Map
                                ? item[widget.nameKey][widget.nameMapKey]
                                    .toString()
                                : item[widget.nameKey].toString();

                        return widget.chipBuilder != null
                            ? widget.chipBuilder!(item)
                            : Chip(
                              backgroundColor:
                                  widget.selectedItemChipBackgroundColor,
                              label: Text(displayText),
                              deleteIcon: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.red,
                              ),
                              onDeleted: () {
                                widget.onItemRemoved?.call(item);
                                setState(() {});
                              },
                            );
                      }).toList(),
                ),
      ),
    );
  }
}
