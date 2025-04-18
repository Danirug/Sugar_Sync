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
  Map<String, double> _dailySugar = {}; // Store daily sugar data (e.g., {"2025-03-26": 20.0})
  List<double> _weeklySugarList = List.filled(7, 0.0); // Aggregated weekly sugar (Mon-Sun)
  List<Map<String, dynamic>> _productLogs = [];
  double? _targetSugar;
  String _firstName = "User";
  String _lastName = "";

  // Initialize state and load data
  @override
  void initState() {
    super.initState();
    _loadSugarData();
    _loadProductLogs();
  }

  // Load product logs from Firestore
  Future<void> _loadProductLogs()async{
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      final logsRef = FirebaseFirestore.instance
          .collection('product_logs')
          .doc(user.uid)
          .collection('logs')
          .orderBy('timestamp', descending: true);// Sort by latest first

      final querySnapshot = await logsRef.get();
      setState(() {
        _productLogs = querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  }

// Load sugar data from Firestore
  Future<void> _loadSugarData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _dailySugar = Map<String, double>.from(data['dailySugar'] ?? {});
          _targetSugar = data['targetSugar']?.toDouble();
          _firstName = data['firstName'] ?? "User";
          _lastName = data['lastName'] ?? "";
          _aggregateWeeklySugar(); // Process daily data into weekly format
        });
      }
    }
  }

  // Aggregate daily sugar into weekly format
  void _aggregateWeeklySugar() {
    // Reset weekly sugar list
    _weeklySugarList = List.filled(7, 0.0);// Reset weekly list

    // Get the start of the current week (Monday)
    final now = DateTime.now();
    final daysSinceMonday = now.weekday - 1; // Calculate days from Monday
    final startOfWeek = now.subtract(Duration(days: daysSinceMonday));

    // Aggregate sugar for each day of the current week
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dateString = date.toIso8601String().split('T')[0]; // e.g., "2025-03-26"
      if (_dailySugar.containsKey(dateString)) {
        _weeklySugarList[i] = _dailySugar[dateString] ?? 0.0;
      }
    }
  }

  //Build the UI
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$_firstName $_lastName",
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
                              getTitlesWidget: (value, meta) {
                                if (value == 0 || value % 10 == 0) {
                                  return Text(
                                    '${value.toInt()}g',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
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
                                      fontWeight: FontWeight.w500,
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
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final sugarValue = rod.toY;
                              String tooltipText = '${sugarValue.toStringAsFixed(1)}g';
                              if (_targetSugar != null && sugarValue > _targetSugar!) {
                                final excess = sugarValue - _targetSugar!;
                                tooltipText += '\nOver: ${excess.toStringAsFixed(1)}g';
                              }
                              return BarTooltipItem(
                                tooltipText,
                                TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
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
                    "Product Logs",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                    ),
                  ),
                  SizedBox(height: 10),
                  _productLogs.isEmpty
                    ?Center(
                      child: Text(
                        "No products Logs available.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black
                        ),
                      )
                  )
                  :Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _productLogs.length,
                      itemBuilder: (context, index){
                        final log = _productLogs[index];
                        final productName = log['productName'] ?? 'Unknown Product';
                        final sugarAmount = log['sugarAmount']?.toDouble() ?? 0.0;
                        final date = log['date'] ?? 'Unknown Date';
                        return ListTile(
                          title: Text(
                            productName,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        subtitle: Text(
                        "Sugar: ${sugarAmount.toStringAsFixed(1)}g | Date: $date",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        );
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  List<BarChartGroupData> _getBarGroups() {
    return List.generate(7, (index) {
      final sugarValue = _weeklySugarList[index]; // Use aggregated weekly data
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: sugarValue,
            color: _targetSugar != null && sugarValue > _targetSugar!
                ? Colors.red // red if over target
                : Colors.purple[300], //purple otherwise
            width: 20,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 150, // background bar height
              color: Colors.grey[200],
            ),
          ),
        ],
      );
    });
  }
}