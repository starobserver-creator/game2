import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget that displays a visual focus outline for keyboard navigation
class FocusOutlineContainer extends StatelessWidget {
  final Widget child;
  final bool isFocused;
  final bool isKeyboardFocused;
  final Color focusColor;
  final double borderWidth;
  final BorderRadius borderRadius;
  final bool hideOutlineForSingleButton;

  const FocusOutlineContainer({
    super.key,
    required this.child,
    required this.isFocused,
    this.isKeyboardFocused = false,
    this.focusColor = Colors.black,
    this.borderWidth = 3,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.hideOutlineForSingleButton = false,
  });

  @override
  Widget build(BuildContext context) {
    // Only show outline if keyboard focused (not mouse focused)
    // Hide outline if this is a single button and hideOutlineForSingleButton is true
    final shouldShowOutline = isFocused && isKeyboardFocused && !hideOutlineForSingleButton;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: shouldShowOutline
            ? Border.all(
                color: focusColor,
                width: borderWidth + 1,  // Thicker border for more visibility
              )
            : null,
        borderRadius: borderRadius,
        boxShadow: shouldShowOutline
            ? [
                BoxShadow(
                  color: focusColor.withOpacity(0.5),  // Black shadow
                  blurRadius: 16,  // Larger blur
                  spreadRadius: 6,  // Larger spread
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
  final bool hideOutlineForSingleButton;

  const KeyboardAccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
    this.hideOutlineForSingleButton = false,
  });

  @override
  State<KeyboardAccessibleButton> createState() =>
      _KeyboardAccessibleButtonState();
}

class _KeyboardAccessibleButtonState extends State<KeyboardAccessibleButton> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isKeyboardFocused = false;

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
        // Mark as keyboard focused when key pressed
        setState(() => _isKeyboardFocused = true);
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
      onFocusChange: (hasFocus) {
        // Set keyboard focused flag when gaining focus via keyboard
        if (hasFocus && !_isKeyboardFocused) {
          // Check if focus was via keyboard (not mouse)
          setState(() => _isKeyboardFocused = true);
        } else if (!hasFocus) {
          setState(() => _isKeyboardFocused = false);
        }
      },
      child: FocusOutlineContainer(
        isFocused: _isFocused,
        isKeyboardFocused: _isKeyboardFocused,
        hideOutlineForSingleButton: widget.hideOutlineForSingleButton,
        child: Semantics(
          label: widget.semanticLabel,
          button: true,
          enabled: true,
          onTap: widget.onPressed,
          child: GestureDetector(
            onTap: widget.onPressed,
            onTapDown: (_) {
              // Disable keyboard focus outline on tap
              setState(() => _isKeyboardFocused = false);
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Manages focus between answer options with WASD/Arrow key navigation
/// Handles 2x2 grid layout properly
class AnswerFocusController {
  int? _currentFocusIndex;
  final int totalOptions;
  final int columnsPerRow; // e.g., 2 for a 2x2 grid
  final Function(int) onFocusChanged;

  AnswerFocusController({
    required this.totalOptions,
    required this.onFocusChanged,
    this.columnsPerRow = 2,
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
      } else {
        // Move up (subtract columnsPerRow)
        newIndex = _currentFocusIndex! - columnsPerRow;
        if (newIndex < 0) {
          // Wrap to bottom row same column
          newIndex = _currentFocusIndex! + (columnsPerRow * (totalOptions ~/ columnsPerRow - 1));
          if (newIndex >= totalOptions) {
            newIndex = _currentFocusIndex! % columnsPerRow + (columnsPerRow * (totalOptions ~/ columnsPerRow - 1));
          }
        }
      }
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) ||
        event.isKeyPressed(LogicalKeyboardKey.keyS)) {
      if (_currentFocusIndex == null) {
        newIndex = 0;
      } else {
        // Move down (add columnsPerRow)
        newIndex = _currentFocusIndex! + columnsPerRow;
        if (newIndex >= totalOptions) {
          // Wrap to top row same column
          newIndex = _currentFocusIndex! % columnsPerRow;
        }
      }
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) ||
        event.isKeyPressed(LogicalKeyboardKey.keyA)) {
      if (_currentFocusIndex == null) {
        newIndex = 0;
      } else {
        // Move left (no wrapping)
        if (_currentFocusIndex! % columnsPerRow > 0) {
          newIndex = _currentFocusIndex! - 1;
        }
        // If already at leftmost, don't move (don't wrap)
      }
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) ||
        event.isKeyPressed(LogicalKeyboardKey.keyD)) {
      if (_currentFocusIndex == null) {
        newIndex = 0;
      } else {
        // Move right (no wrapping within current row)
        if ((_currentFocusIndex! + 1) % columnsPerRow != 0) {
          newIndex = _currentFocusIndex! + 1;
        }
        // If already at rightmost of row, don't move (don't wrap)
      }
    }

    if (newIndex != null && newIndex >= 0 && newIndex < totalOptions) {
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
