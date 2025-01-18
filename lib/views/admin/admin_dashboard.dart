import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:library_management/services/statistics_service.dart';
import 'package:library_management/widgets/custom_drawer.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final StatisticsService _statisticsService = StatisticsService();
  late Future<Map<String, dynamic>> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _statisticsFuture = _fetchAllStatistics();
  }

  Future<Map<String, dynamic>> _fetchAllStatistics() async {
    try {
      final authors = await _statisticsService.fetchAuthorStatistics();
      final categories = await _statisticsService.fetchCategoryStatistics();
      return {
        'authors': authors,
        'categories': categories,
      };
    } catch (error) {
      throw Exception('Failed to fetch statistics: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Admin Dashboard'),
            Image.asset(
              'assets/images/logo.png',
              height: 20,
            ),
          ],
        ),
      ),
      drawer: const CustomDrawer(role: 'Admin'),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statisticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No statistics available.'));
          }

          final data = snapshot.data!;
          final authors = data['authors'];
          final categories = data['categories'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistics Overview',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildPieChart(categories),
                const SizedBox(height: 20),
                _buildLineChart(authors),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChart(Map<String, dynamic> categories) {
    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: categories.entries.map((entry) {
            return PieChartSectionData(
              color: _getCategoryColor(entry.key),
              value: entry.value.toDouble(),
              title: '${entry.value}%',
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLineChart(Map<String, dynamic> authors) {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              isStrokeCapRound: true,
              spots: authors.entries.map((entry) {
                return FlSpot(
                  authors.keys.toList().indexOf(entry.key).toDouble(),
                  entry.value.toDouble(),
                );
              }).toList(),
            ),
          ],
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Colors.black, width: 1),
              left: BorderSide(color: Colors.black, width: 1),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fiction':
        return Colors.blue;
      case 'non-fiction':
        return Colors.green;
      case 'science':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
