import 'package:flutter/scheduler.dart';

class FrameMetricsSnapshot {
  const FrameMetricsSnapshot({
    required this.totalFrames,
    required this.jankyFrames,
    required this.maxBuildMillis,
    required this.maxRasterMillis,
    required this.averageBuildMillis,
    required this.averageRasterMillis,
  });

  final int totalFrames;
  final int jankyFrames;
  final double maxBuildMillis;
  final double maxRasterMillis;
  final double averageBuildMillis;
  final double averageRasterMillis;

  double get jankPercentage =>
      totalFrames == 0 ? 0.0 : (jankyFrames / totalFrames) * 100.0;
}

class FrameTimingTracker {
  static const int _budgetMicros60Hz = 16667;

  final List<FrameTiming> _samples = <FrameTiming>[];
  bool _listening = false;

  void start() {
    if (_listening) return;
    _listening = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  void stop() {
    if (!_listening) return;
    _listening = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
  }

  void reset() {
    _samples.clear();
  }

  void _onTimings(List<FrameTiming> timings) {
    _samples.addAll(timings);
    if (_samples.length > 600) {
      _samples.removeRange(0, _samples.length - 600);
    }
  }

  FrameMetricsSnapshot snapshot({int frameBudgetMicros = _budgetMicros60Hz}) {
    if (_samples.isEmpty) {
      return const FrameMetricsSnapshot(
        totalFrames: 0,
        jankyFrames: 0,
        maxBuildMillis: 0,
        maxRasterMillis: 0,
        averageBuildMillis: 0,
        averageRasterMillis: 0,
      );
    }

    int janky = 0;
    int maxBuild = 0;
    int maxRaster = 0;
    int sumBuild = 0;
    int sumRaster = 0;

    for (final timing in _samples) {
      final build = timing.buildDuration.inMicroseconds;
      final raster = timing.rasterDuration.inMicroseconds;
      final total = timing.totalSpan.inMicroseconds;

      if (total > frameBudgetMicros) {
        janky++;
      }
      if (build > maxBuild) maxBuild = build;
      if (raster > maxRaster) maxRaster = raster;
      sumBuild += build;
      sumRaster += raster;
    }

    final count = _samples.length;
    return FrameMetricsSnapshot(
      totalFrames: count,
      jankyFrames: janky,
      maxBuildMillis: maxBuild / 1000.0,
      maxRasterMillis: maxRaster / 1000.0,
      averageBuildMillis: (sumBuild / count) / 1000.0,
      averageRasterMillis: (sumRaster / count) / 1000.0,
    );
  }
}
