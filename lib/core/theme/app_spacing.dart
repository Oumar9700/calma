import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppSpacing {
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 12.w;
  static double get lg => 16.w;
  static double get xl => 20.w;
  static double get xxl => 24.w;
  static double get xxxl => 32.w;
  static double get huge => 48.w;

  static EdgeInsets get pagePadding => EdgeInsets.symmetric(horizontal: 20.w);
  static EdgeInsets get cardPadding => EdgeInsets.all(16.w);
  static EdgeInsets get listItemPadding =>
      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h);

  static double get borderRadiusSm => 8.r;
  static double get borderRadiusMd => 12.r;
  static double get borderRadiusLg => 16.r;
  static double get borderRadiusXl => 20.r;
  static double get borderRadiusFull => 100.r;

  static SizedBox get gapXs => SizedBox(height: 4.h);
  static SizedBox get gapSm => SizedBox(height: 8.h);
  static SizedBox get gapMd => SizedBox(height: 12.h);
  static SizedBox get gapLg => SizedBox(height: 16.h);
  static SizedBox get gapXl => SizedBox(height: 20.h);
  static SizedBox get gapXxl => SizedBox(height: 24.h);
  static SizedBox get gapXxxl => SizedBox(height: 32.h);

  static SizedBox get hGapXs => SizedBox(width: 4.w);
  static SizedBox get hGapSm => SizedBox(width: 8.w);
  static SizedBox get hGapMd => SizedBox(width: 12.w);
  static SizedBox get hGapLg => SizedBox(width: 16.w);
  static SizedBox get hGapXl => SizedBox(width: 20.w);
}
