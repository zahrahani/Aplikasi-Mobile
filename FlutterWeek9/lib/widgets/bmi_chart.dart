// Widget line chart untuk menampilkan perkembangan BMI dari waktu ke waktu.
// Menggunakan package fl_chart.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bmi_record_model.dart';
import '../theme.dart';

class BmiChart extends StatelessWidget {
  final List<BmiRecord> riwayat;

  const BmiChart({super.key, required this.riwayat});

  @override
  Widget build(BuildContext context) {
    if (riwayat.length < 2) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart, color: AppColors.textHint, size: 36),
              SizedBox(height: 8),
              Text(
                'Minimal 2 data untuk menampilkan grafik',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // Ambil maksimal 10 data terakhir agar chart tidak terlalu padat
    final data = riwayat.length > 10
        ? riwayat.sublist(riwayat.length - 10)
        : riwayat;

    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.bmi);
    }).toList();

    final minBmi = data.map((r) => r.bmi).reduce((a, b) => a < b ? a : b);
    final maxBmi = data.map((r) => r.bmi).reduce((a, b) => a > b ? a : b);
    final padding = 2.0;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: 5,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  // Tampilkan tanggal singkat
                  final tanggal = data[index].tanggal;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('dd/MM').format(tanggal),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: (minBmi - padding).clamp(0, double.infinity),
          maxY: maxBmi + padding,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.primary,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: AppColors.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          // Tooltip saat tap titik data
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  final record = data[index];
                  return LineTooltipItem(
                    'BMI: ${record.bmi.toStringAsFixed(1)}\n'
                    '${DateFormat('dd MMM yyyy').format(record.tanggal)}',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}