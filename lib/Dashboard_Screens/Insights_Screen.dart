import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  _InsightsScreenState createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  Map<String, double> _weeklySugar = {}; // Store weekly sugar data
  double ? _targetSugar;

  @override
  void initState() {
    super.initState();
    _loadWeeklySugarData();
  }

  Future<void> _loadWeeklySugarData() async{
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _weeklySugar = Map<String, double>.from(data['weeklySugar'] ?? {});
          _targetSugar = data['targetSugar']?.toDouble();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCCF4E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
         title: Text(
          "Insights",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding:EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Stefani Wong",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.blue[100],
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.deepOrange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Graph Card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Average Sugar Intake",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        barGroups: _getBarGroups(),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: 50,
                                getTitlesWidget: (value, meta){
                                  if(value == 0 || value % 10 == 0){
                                    return Text(
                                      '${value.toInt()}g',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12
                                      ),
                                    );
                                  }
                                  return SizedBox.shrink();
                                },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                List<String> days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
                                return Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    days[value.toInt()],
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) => Colors.blue,
                            getTooltipItem: (group, groupIndex, rod, rodIndex){
                              final sugarValue = rod.toY;
                              String tooltipText = '${sugarValue.toStringAsFixed(1)}g';
                              if (_targetSugar != null && sugarValue > _targetSugar!) {
                                final excess = sugarValue - _targetSugar!;
                                tooltipText += '\nOver: ${excess.toStringAsFixed(1)}g';
                              }
                              return BarTooltipItem(
                                tooltipText,
                                TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 14),
                              );
                            }
                          )
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(7, (index) {
      final sugarValue = _weeklySugar[index.toString()] ?? 0.0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: sugarValue,
            color: _targetSugar !=null && sugarValue > _targetSugar!
              ? Colors.red
              : Colors.purple[300],
            width: 20,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 150,
              color: Colors.grey[200],
            )
          ),
        ],
      );
    });
  }
}


