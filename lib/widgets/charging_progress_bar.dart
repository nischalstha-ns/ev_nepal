import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChargingProgressBar extends StatefulWidget {
  final DateTime startTime;
  final int targetPercent;
  final double batteryCapacityKwh;
  final double powerKw;

  const ChargingProgressBar({
    super.key,
    required this.startTime,
    required this.targetPercent,
    this.batteryCapacityKwh = 40.5,
    this.powerKw = 7.4,
  });

  @override
  State<ChargingProgressBar> createState() => _ChargingProgressBarState();
}

class _ChargingProgressBarState extends State<ChargingProgressBar> {
  Timer? _timer;
  double _currentPercent = 0;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _update());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _update() {
    final elapsed = DateTime.now().difference(widget.startTime);
    final elapsedHours = elapsed.inSeconds / 3600.0;
    final chargedKwh = elapsedHours * widget.powerKw;
    final chargedPercent =
        (chargedKwh / widget.batteryCapacityKwh) * 100;
    if (mounted) {
      setState(() {
        _currentPercent = chargedPercent.clamp(0, widget.targetPercent.toDouble());
      });
    }
  }

  int get _remainingMinutes {
    final remaining = widget.targetPercent - _currentPercent;
    if (remaining <= 0) return 0;
    final remainingKwh = (remaining / 100) * widget.batteryCapacityKwh;
    return ((remainingKwh / widget.powerKw) * 60).round();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentPercent / widget.targetPercent;
    final isComplete = _currentPercent >= widget.targetPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${_currentPercent.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.primary,
              ),
            ),
            Text(
              ' / ${widget.targetPercent}%',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
            const Spacer(),
            if (isComplete)
              const Text('Complete!',
                  style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 12))
            else
              Text(
                '~$_remainingMinutes min remaining',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            color: isComplete ? AppColors.success : AppColors.primary,
            backgroundColor: AppColors.surfaceContainerHigh,
          ),
        ),
      ],
    );
  }
}
