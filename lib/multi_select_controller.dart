part of 'custom_dropdown.dart';

class CustomMultiDropdownController {
  late CustomMultiDropdownState _state;

  void attach(CustomMultiDropdownState state) {
    _state = state;
  }

  void openDropdown() {
    _state._showOverlay();
  }

  void closeDropdown() {
    _state._hideOverlay();
  }

  void clearSelection() {
    _state._clearSelection();
  }

  List<Map<String, dynamic>> get selectedItems => _state._selectedItems;
}
