import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Use this Widget if you have Expanded as descendant of SingleChildScrollView
class SingleChildScrollViewExpanded extends StatelessWidget {
  final Axis scrollDirection;
  final bool reverse;
  final EdgeInsetsGeometry? padding;
  final bool? primary;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final Widget child;
  final DragStartBehavior dragStartBehavior;

  const SingleChildScrollViewExpanded({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    bool? primary,
    this.physics,
    this.controller,
    required this.child,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(
  !(controller != null && primary == true),
  'Primary ScrollViews obtain their ScrollController via inheritance from a PrimaryScrollController widget. '
      'You cannot both set primary to true and pass an explicit controller.'),
        primary = primary ??
            controller == null && identical(scrollDirection, Axis.vertical);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: scrollDirection,
          reverse: reverse,
          padding: padding,
          primary: primary,
          physics: physics,
          controller: controller,
          dragStartBehavior: dragStartBehavior,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: child,
            ),
          ),
        );
      },
    );
  }
}
