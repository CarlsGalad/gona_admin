import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatefulWidget {
  const PieChartWidget({super.key});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  List<Sector> sectors = [
    Sector(color: Colors.blue, value: 30.0),
    Sector(color: Colors.green, value: 20.0),
    Sector(color: Colors.red, value: 50.0),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: PieChart(
          PieChartData(
            sections: _chartSections(sectors),
            centerSpaceRadius: 48.0,
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _chartSections(List<Sector> sectors) {
    final List<PieChartSectionData> list = [];
    for (var sector in sectors) {
      final data = PieChartSectionData(
        color: sector.color,
        value: sector.value,
        title: '',
      );
      list.add(data);
    }
    return list;
  }
}

class Sector {
  final Color color;
  final double value;

  Sector({required this.color, required this.value});
}
