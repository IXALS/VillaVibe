import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

OverlayEntry? _previousEntry;

void showCustomSnackBar(
  BuildContext context, {
  required String message,
  IconData? icon,
  VoidCallback? onAction,
  String? actionLabel,
  bool isError = false,
}) {
  // Remove existing snackbar if any
  if (_previousEntry != null) {
    _previousEntry!.remove();
    _previousEntry = null;
  }

  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => _TopSnackBar(
      message: message,
      icon: icon,
      onAction: onAction,
      actionLabel: actionLabel,
      isError: isError,
      onDismiss: () {
        if (entry.mounted) {
          entry.remove();
        }
        if (_previousEntry == entry) {
          _previousEntry = null;
        }
      },
    ),
  );

  overlay.insert(entry);
  _previousEntry = entry;
}

class _TopSnackBar extends StatefulWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final bool isError;
  final VoidCallback onDismiss;

  const _TopSnackBar({
    required this.message,
    this.icon,
    this.onAction,
    this.actionLabel,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<_TopSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      reverseDuration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInBack,
    ));

    _controller.forward();

    // Auto dismiss
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: SlideTransition(
          position: _offsetAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.isError ? Colors.red[50] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 20,
                        color: widget.isError ? Colors.red : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Text(
                      widget.message,
                      style: GoogleFonts.outfit(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.onAction != null && widget.actionLabel != null)
                    TextButton(
                      onPressed: () {
                        widget.onAction!();
                        _controller.reverse().then((_) => widget.onDismiss());
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        widget.actionLabel!,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
