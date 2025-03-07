import 'package:flutter/material.dart';

import '../widgets/chart.dart';
import '../widgets/navbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Sample data for demonstration
  final List<Map<String, dynamic>> backtestResults = [
    {
      'strategy': 'Moving Average Crossover',
      'asset': 'BTC/USD',
      'return': 12.5,
      'period': '3 months',
    },
    {
      'strategy': 'RSI Strategy',
      'asset': 'AAPL',
      'return': 8.2,
      'period': '6 months',
    },
    {
      'strategy': 'Pattern Recognition',
      'asset': 'ETH/USD',
      'return': -3.7,
      'period': '1 month',
    },
    {
      'strategy': 'Ensemble Model',
      'asset': 'TSLA',
      'return': 15.3,
      'period': '1 year',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      drawer: const NavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: SimpleChart(
                title: 'Strategy Performance',
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Recent Backtests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: backtestResults.length,
              itemBuilder: (context, index) {
                final result = backtestResults[index];
                final isPositive = result['return'] >= 0;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(result['strategy']),
                    subtitle: Text('${result['asset']} - ${result['period']}'),
                    trailing: Text(
                      '${isPositive ? '+' : ''}${result['return']}%',
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      // Navigate to detailed backtest results
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Viewing details for ${result['strategy']}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('New Backtest'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              onPressed: () {
                // Navigate to create new backtest
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Algorithm'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        'Moving Average Crossover',
                        'RSI Strategy',
                        'Pattern Recognition',
                        'CNN Model',
                        'RNN Model',
                        'NLP Sentiment',
                        'Ensemble Model',
                      ]
                          .map((strategy) => ListTile(
                                title: Text(strategy),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Creating new $strategy backtest'),
                                    ),
                                  );
                                },
                              ))
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/watchlist'),
        tooltip: 'Watchlist',
        child: const Icon(Icons.visibility),
      ),
    );
  }
}
