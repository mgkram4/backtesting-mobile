import datetime
from venv import logger

import numpy as np
import pandas as pd
from flask import Flask, jsonify, request

app = Flask(__name__)

class Backtesting:
    def __init__(self, ):
        self.initial_capital = 100000
        self.reset()
        
    def reset(self):
        self.cash = self.initial_capital
        self.postitions = {}
        self.trades =  []
        self.equity_history = []
        
    def calculate(self, equity_curve):
        try: 
            equity_series = pd.Series(equity_curve)
            returns = equity_series.pct_change().dropna()
            
            total_return = ((equity_series.iloc[-1]/ equity_series.iloc[0]) - 1) * 100
            if len(returns) > 1:
                sharpe_ratio = np.sqrt(252) * (returns.mean() / returns.std())
            else:
                sharpe_ratio = 0 
                
            rolling_max = equity_series.expanding().max()
            drawdowns = (equity_series - rolling_max) / rolling_max * 100
            max_drawdown = abs(drawdowns.min())
            
            profitable_trades = sum(1 for trade in self.trades if trade['pnl'] > 0)
            win_rate = (profitable_trades / len())
        
            return {
                "total_return": round(total_return, 2),
                "sharpe_ratio" : round(sharpe_ratio, 2),
                "max_drawdown": round(max_drawdown, 2),
                "win_rate": round(win_rate, 2)
            }
            
        except Exception as e:
            logger.error(f"Error calculating metrics:")
            return {
                'total_return' : 0.0,
                'sharpe_ratio' : 0.0,
                'max_drawdown' : 0.0,
                'win_rate' : 0.0,
            }
            
    def run_backtest(self, data, strategy_func):
        self.reset()
        
        if isinstance(data, pd.DataFrame):
            data_dict = {
                'close': data['close'].values.tolist(),
                'open': data['open'].values.tolist(),
                'high': data['high'].values.tolist(),
                "low": data['low'].values.tolist(),
                "volume": data["volume"].values.tolist()
            }
        else:
            data_dict = data
            
        for i in range(len(data_dict['close'])):
            hist_data = {k: v[:i+1] for k, v in data_dict.items()}
            current_position = self.postitions.get("BACKTEST", 0 )
            signals = strategy_func(hist_data, current_position)
            current_price = data_dict['close'][i]
            for signal in signals:
                side, quanity = signal
                
                if side == "BUY":
                    cost = quanity * current_price
                    if self.cash >= cost:
                        self.cash -= cost
                        self.postitions["BACKTEST"] = self.postitions.get('BACKTEST', 0 ) + quanitty
                        self.trades.append({
                            'date' : i,
                            'side': "BUY",
                            'price' : current_price,
                            'quantity' : quanity,
                            "pnl": 0
                        })

@app.route("/backtesting", METHODS= ["POST"])
def backtesting():
    try:
        data = request.json
        stragegy_name = data.get('strategy')
        symbol = data.get("symbol")
        start_date = datetime.strptime(data.get('start_date'), '%Y-%m-%d')
        end_date = datetime.strptime(data.get('end_date'), '%Y-%m-%d')
        logger.info(f"Running backtest for {symbol} from {start_date} to {end_date}")
        
        if historical_data is None:
            return jsonify({'error' : 'Failed to fetch historical data'}), 400
        
        engine = Backtesting(initial_capital=100000)
        
        strategy_map = {
            'ema': ema_strategy
        }
        
        stragegy_func = strategy_map.get(stragegy_name)
        if not stragegy_func:
            return jsonify({'error': 'Invalid strategy name'}), 400
        
        result = engine.run_backtest(historical_data, strategy_func)
        
        response = {
            'equity_curve': 
                [
                    {
                        'date': str(start_date + datetime.timedelta(days=i)),
                        'equity': float(value)
                    }
                    for i, value in enumerate(result['equity_curve'])
                ],
                'metrics' : {
                    'total_return' : result['metrics'].get('total_return', 0.0),
                    'sharpe_ratio' : result['metrics'].get('sharpe_ratio', 0.0),
                    'max_drawdown' : result['metrics'].get('max_drawdown', 0.0),
                    'win_rate' : result['metrics'].get('win_rate', 0.0),
                    'total_trades' : result['metrics'].get('total_trades', 0.0),
                    'avg_trade_pnl' : result['metrics'].get('avg_trade_pnl', 0.0),
                },
                'trades' : [
                    {
                        'date': str(trade.get('date', '')),
                        'side': trade.get('side', ''),
                        'price': float(trade.get('price', 0.0)),
                        'quantity': int(trade.get("quantity", 0)),
                        "pnl" : float(trade.get("pnl", 0.0))
                    }
                    for trade in result['trades']
                ]
        }
        
        return jsonify(response)
    
    except Exception as e:
        logger.error(f"Backtest error: {str(e)}")
        return jsonify({
            'error': str(e),
            'metrics': {
                "total_return": 0.0,
                "sharpe_ratio": 0.0,
                "max_drawdown": 0.0,
                "win_rate": 0.0,
                "total_trades": 0.0,
                "avg_trade_pnl": 0.0,
            },
            'equity_curve': [],
            'trades': []
        }),500
        