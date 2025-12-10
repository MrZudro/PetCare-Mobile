import 'package:flutter/material.dart';

/// Sistema de transiciones de página reutilizables para animaciones smooth y profesionales
class PageTransitions {
  /// Transición de deslizamiento desde abajo
  static Route slideFromBottom(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Transición de deslizamiento desde la derecha
  static Route slideFromRight(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Transición de desvanecimiento suave
  static Route fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Transición de escala con zoom
  static Route scale(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;

        var scaleTween = Tween(
          begin: 0.8,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        var fadeTween = Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  /// Transición combinada de deslizamiento y desvanecimiento
  static Route slideAndFade(Widget page, {bool fromBottom = true}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = fromBottom
            ? const Offset(0.0, 0.3)
            : const Offset(0.3, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var slideTween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        var fadeTween = Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}

/// Extension methods para facilitar el uso de transiciones
extension NavigatorTransitions on NavigatorState {
  Future<T?> pushWithSlideFromBottom<T>(Widget page) {
    return push<T>(PageTransitions.slideFromBottom(page) as Route<T>);
  }

  Future<T?> pushWithSlideFromRight<T>(Widget page) {
    return push<T>(PageTransitions.slideFromRight(page) as Route<T>);
  }

  Future<T?> pushWithFade<T>(Widget page) {
    return push<T>(PageTransitions.fade(page) as Route<T>);
  }

  Future<T?> pushWithScale<T>(Widget page) {
    return push<T>(PageTransitions.scale(page) as Route<T>);
  }

  Future<T?> pushWithSlideAndFade<T>(Widget page, {bool fromBottom = true}) {
    return push<T>(
      PageTransitions.slideAndFade(page, fromBottom: fromBottom) as Route<T>,
    );
  }
}
