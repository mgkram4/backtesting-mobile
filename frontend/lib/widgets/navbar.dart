import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Stock Backtesting',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'user@example.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildNavItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            route: '/dashboard',
          ),
          _buildNavItem(
            context,
            icon: Icons.show_chart,
            title: 'Charts',
            route: '/charts',
          ),
          _buildNavItem(
            context,
            icon: Icons.attach_money,
            title: 'Fetch Prices',
            route: '/fetch_prices',
          ),
          _buildNavItem(
            context,
            icon: Icons.visibility,
            title: 'Watchlist',
            route: '/watchlist',
          ),
          const Divider(),
          _buildNavItem(
            context,
            icon: Icons.science,
            title: 'Backtesting',
            onTap: () {
              Navigator.pop(context);
              _showBacktestingOptions(context);
            },
          ),
          _buildNavItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            route: '/settings',
          ),
          const Divider(),
          _buildNavItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            route: '/login',
            replacement: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    bool replacement = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap ??
          () {
            Navigator.pop(context);
            if (route != null) {
              if (replacement) {
                Navigator.pushReplacementNamed(context, route);
              } else {
                Navigator.pushNamed(context, route);
              }
            }
          },
    );
  }

  void _showBacktestingOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Algorithm'),
        children: [
          _buildAlgorithmOption(context, 'Moving Average Crossover'),
          _buildAlgorithmOption(context, 'RSI Strategy'),
          _buildAlgorithmOption(context, 'Pattern Recognition'),
          _buildAlgorithmOption(context, 'CNN Model'),
          _buildAlgorithmOption(context, 'RNN Model'),
          _buildAlgorithmOption(context, 'NLP Sentiment'),
          _buildAlgorithmOption(context, 'Ensemble Model'),
        ],
      ),
    );
  }

  Widget _buildAlgorithmOption(BuildContext context, String algorithm) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected $algorithm for backtesting'),
          ),
        );
      },
      child: Text(algorithm),
    );
  }
}
