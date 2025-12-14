import 'package:flutter/material.dart';
import 'animation_constants.dart';

class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final AnimationController controller;
  final Offset beginOffset;
  
  const FadeSlideTransition({
    super.key,
    required this.child,
    required this.controller,
    this.beginOffset = const Offset(0.0, 0.3),
  });
  
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: AnimationConstants.easeOut,
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: controller,
          curve: AnimationConstants.easeOut,
        ),
        child: child,
      ),
    );
  }
}

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final PageTransitionType transitionType;
  
  CustomPageRoute({
    required this.page,
    this.transitionType = PageTransitionType.fadeSlide,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AnimationConstants.pageTransition,
          reverseTransitionDuration: AnimationConstants.pageTransition,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (transitionType) {
              case PageTransitionType.fadeSlide:
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.3, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: AnimationConstants.easeOut,
                    )),
                    child: child,
                  ),
                );
              case PageTransitionType.scale:
                return ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.9,
                    end: 1.0,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: AnimationConstants.easeOut,
                  )),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              case PageTransitionType.fade:
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
            }
          },
        );
}

enum PageTransitionType {
  fadeSlide,
  scale,
  fade,
}
