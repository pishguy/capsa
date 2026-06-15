import 'package:flutter/rendering.dart';

class UltraStackParentData extends ContainerBoxParentData<RenderBox> {
  double? left;
  double? right;
  double? top;
  double? bottom;
  double? width;
  double? height;

  bool get isPositioned =>
      left != null ||
          right != null ||
          top != null ||
          bottom != null ||
          width != null ||
          height != null;
}
