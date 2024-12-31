import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
//import 'package:fl_chart/fl_chart.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(showTitles: true),
                    bottomTitles: SideTitles(showTitles: true),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 30),
                        FlSpot(1, 70),
                        FlSpot(2, 50),
                        FlSpot(3, 90),
                      ],
                      isCurved: true,
                      colors: [Colors.blue],
                      dotData: FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 50),
                        FlSpot(1, 60),
                        FlSpot(2, 80),
                        FlSpot(3, 40),
                      ],
                      isCurved: true,
                      colors: [Colors.red],
                      dotData: FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 20),
                        FlSpot(1, 40),
                        FlSpot(2, 60),
                        FlSpot(3, 80),
                      ],
                      isCurved: true,
                      colors: [Colors.cyan],
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 170,
                      title: 'Time',
                      color: Colors.purple,
                    ),
                    PieChartSectionData(
                      value: 149,
                      title: 'Book',
                      color: Colors.blue,
                    ),
                    PieChartSectionData(
                      value: 211,
                      title: 'Reservation',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}