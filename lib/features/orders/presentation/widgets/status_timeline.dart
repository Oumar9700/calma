import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/build_context_ext.dart';
import '../../domain/entities/order_status.dart';

class StatusTimeline extends StatelessWidget {
  final OrderStatus currentStatus;

  const StatusTimeline({super.key, required this.currentStatus});

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.accepted,
    OrderStatus.awaitingConfirmation,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final isCancelled = currentStatus == OrderStatus.cancelled ||
        currentStatus == OrderStatus.rejected;

    if (isCancelled) {
      return _CancelledIndicator(status: currentStatus);
    }

    final currentIndex = _steps.indexOf(currentStatus);
    final activeIndex = currentIndex < 0 ? 0 : currentIndex;

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIndex = i ~/ 2;
          final isCompleted = stepIndex < activeIndex;
          return Expanded(
            child: Container(
              height: 2.h,
              color: isCompleted
                  ? context.colorPrimary
                  : context.colorSurfaceContainerHighest,
            ),
          );
        }
        // Step dot
        final stepIndex = i ~/ 2;
        final isCompleted = stepIndex <= activeIndex;
        final step = _steps[stepIndex];
        return _StepDot(
          step: step,
          isCompleted: isCompleted,
          isActive: stepIndex == activeIndex,
        );
      }),
    );
  }
}

class _StepDot extends StatelessWidget {
  final OrderStatus step;
  final bool isCompleted;
  final bool isActive;

  const _StepDot({
    required this.step,
    required this.isCompleted,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isActive ? 24.w : 16.w,
          height: isActive ? 24.w : 16.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? context.colorPrimary
                : context.colorSurfaceContainerHighest,
            border: isActive
                ? Border.all(
                    color: context.colorPrimary,
                    width: 2,
                  )
                : null,
          ),
          child: isCompleted && !isActive
              ? Icon(Icons.check, size: 10.w, color: context.colorOnPrimary)
              : null,
        ),
        SizedBox(height: 4.h),
        Text(
          _shortLabel(step),
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isCompleted
                ? context.colorPrimary
                : context.colorOnSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _shortLabel(OrderStatus step) {
    switch (step) {
      case OrderStatus.pending:
        return 'Envoyée';
      case OrderStatus.accepted:
        return 'Acceptée';
      case OrderStatus.awaitingConfirmation:
        return 'Paiement';
      case OrderStatus.preparing:
        return 'Prép.';
      case OrderStatus.ready:
        return 'Prête';
      case OrderStatus.completed:
        return 'Terminée';
      default:
        return step.label;
    }
  }
}

class _CancelledIndicator extends StatelessWidget {
  final OrderStatus status;
  const _CancelledIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            status == OrderStatus.rejected
                ? Icons.cancel_outlined
                : Icons.highlight_off_outlined,
            size: 18.w,
            color: status.color,
          ),
          SizedBox(width: 8.w),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}
