import 'package:flutter/material.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Premium custom snackbar with beautiful design and animations
///
/// Provides success, error, warning, and info variants with:
/// - Smooth slide-in animations
/// - Icon indicators
/// - Auto-dismiss with progress indicator
/// - Glassmorphism effect
class CustomSnackbar {
  CustomSnackbar._();

  /// Show success snackbar
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      type: _SnackbarType.success,
      duration: duration,
    );
  }

  /// Show error snackbar
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message: message,
      type: _SnackbarType.error,
      duration: duration,
    );
  }

  /// Show warning snackbar
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      type: _SnackbarType.warning,
      duration: duration,
    );
  }

  /// Show info snackbar
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      type: _SnackbarType.info,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required _SnackbarType type,
    required Duration duration,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) =>
          _SnackbarWidget(message: message, type: type, duration: duration),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration + const Duration(milliseconds: 500), () {
      overlayEntry.remove();
    });
  }
}

enum _SnackbarType { success, error, warning, info }

class _SnackbarWidget extends StatefulWidget {
  final String message;
  final _SnackbarType type;
  final Duration duration;

  const _SnackbarWidget({
    required this.message,
    required this.type,
    required this.duration,
  });

  @override
  State<_SnackbarWidget> createState() => _SnackbarWidgetState();
}

class _SnackbarWidgetState extends State<_SnackbarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDesign.durationNormal,
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: AppDesign.curveEmphasized,
          ),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor() {
    switch (widget.type) {
      case _SnackbarType.success:
        return AppDesign.success;
      case _SnackbarType.error:
        return AppDesign.error;
      case _SnackbarType.warning:
        return AppDesign.warning;
      case _SnackbarType.info:
        return AppDesign.info;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case _SnackbarType.success:
        return Icons.check_circle;
      case _SnackbarType.error:
        return Icons.error;
      case _SnackbarType.warning:
        return Icons.warning;
      case _SnackbarType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Positioned(
      top: AppDesign.space6,
      left: AppDesign.space4,
      right: AppDesign.space4,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(AppDesign.space4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppDesign.radiusLg),
                    boxShadow: AppDesign.shadowXl,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppDesign.space2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getIcon(), color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: AppDesign.space3),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: AppDesign.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDesign.space2),
                      _ProgressIndicator(
                        duration: widget.duration,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatefulWidget {
  final Duration duration;
  final Color color;

  const _ProgressIndicator({required this.duration, required this.color});

  @override
  State<_ProgressIndicator> createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<_ProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CircularProgressIndicator(
            value: _controller.value,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(widget.color),
            backgroundColor: widget.color.withOpacity(0.3),
          );
        },
      ),
    );
  }
}
