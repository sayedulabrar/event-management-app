import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/event.dart';

class EventLevelChart extends StatefulWidget {
  @override
  _EventLevelChartState createState() => _EventLevelChartState();
}

class _EventLevelChartState extends State<EventLevelChart> {
  late Future<Map<String, int>> eventCountsFuture;

  @override
  void initState() {
    super.initState();
    eventCountsFuture = fetchEventCounts();
  }

  Future<Map<String, int>> fetchEventCounts() async {
    final eventCounts = {
      'Div level': 0,
      'Bde level': 0,
      'Unit level': 0,
    };

    final querySnapshot = await FirebaseFirestore.instance.collection('events').get();

    for (var doc in querySnapshot.docs) {
      final event = Event.fromFirestore(doc);
      if (eventCounts.containsKey(event.level)) {
        eventCounts[event.level] = eventCounts[event.level]! + 1;
      }
    }

    return eventCounts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Summary')),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: eventCountsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }

          final eventCounts = snapshot.data!;
          final chartData = [
            _ChartData('Div level', eventCounts['Div level']!),
            _ChartData('Bde level', eventCounts['Bde level']!),
            _ChartData('Unit level', eventCounts['Unit level']!),
          ];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(
                minimum: 0,
                isVisible: false,
              ),
              series: <CartesianSeries<_ChartData, String>>[
                BarSeries<_ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (data, _) => data.level,
                  yValueMapper: (data, _) => data.count,
                  color: Colors.blue,
                  width: 0.5,
                  borderRadius: BorderRadius.circular(4),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(color: Colors.white),
                    labelAlignment: ChartDataLabelAlignment.top,
                  ),
                ),
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: '',
                format: 'point.x: point.y',
                textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                color: Colors.blueAccent,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.level, this.count);
  final String level;
  final int count;
}
