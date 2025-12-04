import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget that displays a visual focus outline for keyboard navigation
class FocusOutlineContainer extends StatelessWidget {
  final Widget child;
  final bool isFocused;
  final Color focusColor;
  final double borderWidth;
  final BorderRadius borderRadius;

  const FocusOutlineContainer({
    super.key,
    required this.child,
    required this.isFocused,
    this.focusColor = const Color.fromARGB(255, 33, 150, 243),
    this.borderWidth = 3,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    // Use DecoratedBox to add outline without affecting size
    return DecoratedBox(
      decoration: BoxDecoration(
        border: isFocused
            ? Border.all(
                color: focusColor,
                width: borderWidth,
              )
            : null,
        borderRadius: borderRadius,
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: focusColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: child,
    );
  }
}

/// Wraps a button with keyboard accessibility features
/// - Focus outline when focused via keyboard
/// - Activation via Enter/Space
/// - Tab navigation support
class KeyboardAccessibleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final String semanticLabel;
  final bool autofocus;
  final FocusNode? focusNode;

  const KeyboardAccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<KeyboardAccessibleButton> createState() =>
      _KeyboardAccessibleButtonState();
}

class _KeyboardAccessibleButtonState extends State<KeyboardAccessibleButton> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
        event.isKeyPressed(LogicalKeyboardKey.space)) {
      if (event is RawKeyDownEvent) {
        widget.onPressed();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      autofocus: widget.autofocus,
      child: FocusOutlineContainer(
        isFocused: _isFocused,
        child: Semantics(
          label: widget.semanticLabel,
          button: true,
          enabled: true,
          onTap: widget.onPressed,
          child: GestureDetector(
            onTap: widget.onPressed,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Manages focus between answer options with WASD/Arrow key navigation
class AnswerFocusController {
  int? _currentFocusIndex;
  final int totalOptions;
  final Function(int) onFocusChanged;

  AnswerFocusController({
    required this.totalOptions,
    required this.onFocusChanged,
  });

  int? get currentFocusIndex => _currentFocusIndex;

  /// Returns true if key event was handled, false otherwise
  bool handleKeyEvent(RawKeyEvent event, {required bool isAnswered}) {
    if (isAnswered) {
      // After answering, only Tab moves focus
      return false;
    }

    int? newIndex;

    // Arrow keys and WASD for navigation
    if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) ||
        event.isKeyPressed(LogicalKeyboardKey.keyW)) {
      if (_currentFocusIndex == null) {
        newIndex = 0;
      } else if (_currentFocusIndex! > 0) {
        newIndex = _currentFocusIndex! - 1;
      } else {
        newIndex = totalOptions - 1; // Wrap around
      }
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) ||
        event.isKeyPressed(LogicalKeyboardKey.keyS)) {
      if (_currentFocusIndex == null) {
        newIndex = 0;
      } else if (_currentFocusIndex! < totalOptions - 1) {
        newIndex = _currentFocusIndex! + 1;
      } else {
        newIndex = 0; // Wrap around
      }
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) ||
        event.isKeyPressed(LogicalKeyboardKey.keyA)) {
      if (_currentFocusIndex == null) {
        newIndex = 0;
      } else if (_currentFocusIndex! > 0) {
        newIndex = _currentFocusIndex! - 1;
      } else {
        newIndex = totalOptions - 1; // Wrap around
      }
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) ||
        event.isKeyPressed(LogicalKeyboardKey.keyD)) {
      if (_currentFocusIndex == null) {
        newIndex = 0;
      } else if (_currentFocusIndex! < totalOptions - 1) {
        newIndex = _currentFocusIndex! + 1;
      } else {
        newIndex = 0; // Wrap around
      }
    }

    if (newIndex != null) {
      _currentFocusIndex = newIndex;
      onFocusChanged(newIndex);
      return true;
    }

    return false;
  }

  void setFocusIndex(int index) {
    if (index >= 0 && index < totalOptions) {
      _currentFocusIndex = index;
      onFocusChanged(index);
    }
  }

  void reset() {
    _currentFocusIndex = null;
  }
}
