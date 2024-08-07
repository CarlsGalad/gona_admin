import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatefulWidget {
  const PieChartWidget({super.key});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  List<Sector> sectors = [
    Sector(color: Colors.blue, value: 30.0, title: 'Lagos'),
    Sector(color: Colors.green, value: 20.0, title: 'Abuja'),
    Sector(color: Colors.red, value: 50.0, title: 'Nassarawa'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Card(
        elevation: 4,
        shape: CircleBorder(side: BorderSide(color: Colors.white, width: 3)),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: PieChart(
            PieChartData(
                sections: _chartSections(sectors),
                centerSpaceRadius: 48.0,
                borderData: FlBorderData(
                  show: true,
                )),
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
        title: sector.title,
      );
      list.add(data);
    }
    return list;
  }
}

class Sector {
  final Color color;
  final double value;
  final String title;

  Sector({required this.color, required this.value, required this.title});
}
