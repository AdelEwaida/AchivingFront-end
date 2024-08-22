// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class HorizontalBarchart extends StatefulWidget {
//   const HorizontalBarchart({super.key});

//   @override
//   State<HorizontalBarchart> createState() => _HorizontalBarchartState();
// }

// class _HorizontalBarchartState extends State<HorizontalBarchart> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: BarChart(
//         BarChartData(
//           alignment: BarChartAlignment.spaceAround,
//           maxY: 20, // Adjust according to your data
//           barTouchData: BarTouchData(enabled: false),
//           titlesData: FlTitlesData(
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (value, meta) {
//                   switch (value.toInt()) {
//                     case 0:
//                       return Text('Option A');
//                     case 1:
//                       return const Text('Option B');
//                     case 2:
//                       return Text('Option C');
//                     default:
//                       return Text('');
//                   }
//                 },
//               ),
//             ),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (value, meta) {
//                   return Text(value.toInt().toString());
//                 },
//               ),
//             ),
//             topTitles: const AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: false,
//               ),
//             ),
//             rightTitles: const AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: false,
//               ),
//             ),
//           ),
//           barGroups: [
//             BarChartGroupData(
//               x: 0,
//               barRods: [
//                 BarChartRodData(
//                   toX: 8,
//                   color: Colors.blue,
//                   width: 20,
//                   borderRadius: BorderRadius.circular(0),
//                 ),
//               ],
//             ),
//             BarChartGroupData(
//               x: 1,
//               barRods: [
//                 BarChartRodData(
//                   toX: 12,
//                   color: Colors.green,
//                   width: 20,
//                   borderRadius: BorderRadius.circular(0),
//                 ),
//               ],
//             ),
//             BarChartGroupData(
//               x: 2,
//               barRods: [
//                 BarChartRodData(
//                   toX: 6,
//                   color: Colors.red,
//                   width: 20,
//                   borderRadius: BorderRadius.circular(0),
//                 ),
//               ],
//             ),
//           ],
//           gridData: FlGridData(show: false),
//           borderData: FlBorderData(show: false),
//         ),
//       ),
//     );
//   }
// }
