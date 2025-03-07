import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({Key? key}) : super(key: key);

  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  final TextEditingController _tickerController = TextEditingController();
  String _selectedPeriod = '1mo';
  bool _isLoading = false;
  List<FlSpot> _priceData = [];
  double _minY = 0;
  double _maxY = 0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tickerController.text = 'AAPL'; // Default ticker
    _fetchStockData();
  }

  Future<void> _fetchStockData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final ticker = _tickerController.text.trim().toUpperCase();
      if (ticker.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter a valid ticker symbol';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/api/price/stock-history/$ticker?period=$_selectedPeriod'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final history = data['history'] as List<dynamic>;

        if (history.isEmpty) {
          setState(() {
            _errorMessage = 'No data available for $ticker';
            _priceData = [];
          });
          return;
        }

        final spots = <FlSpot>[];
        for (int i = 0; i < history.length; i++) {
          final price = history[i]['Close'] as double;
          spots.add(FlSpot(i.toDouble(), price));
        }

        setState(() {
          _priceData = spots;
          _minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) *
              0.95;
          _maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) *
              1.05;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch data: ${response.statusCode}';
          _priceData = [];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _priceData = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Charts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tickerController,
                    decoration: const InputDecoration(
                      labelText: 'Ticker Symbol',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  items: ['1d', '5d', '1mo', '3mo', '6mo', '1y', '5y', 'max']
                      .map((period) => DropdownMenuItem(
                            value: period,
                            child: Text(period),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                    }
                  },
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _fetchStockData,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Fetch'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_priceData.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      minX: 0,
                      maxX: _priceData.length.toDouble() - 1,
                      minY: _minY,
                      maxY: _maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _priceData,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (!_isLoading && _errorMessage.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Enter a ticker symbol and fetch data to display chart',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }
}
