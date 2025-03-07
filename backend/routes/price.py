# this route will be used to compute the price analyusiys with NN 

from datetime import datetime

import pandas as pd
import yfinance as yf
from flask import Blueprint, jsonify, request

# Create a Blueprint for price routes
price_bp = Blueprint('price', __name__)

@price_bp.route('/stock-info/<ticker>', methods=['GET'])
def get_stock_info(ticker):
    """Get basic information about a stock."""
    try:
        data = yf.Ticker(ticker)
        return jsonify({
            'info': data.info,
            'calendar': data.calendar.to_dict() if hasattr(data.calendar, 'to_dict') else None,
            'analyst_price_targets': data.analyst_price_targets.to_dict() if hasattr(data.analyst_price_targets, 'to_dict') else None
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@price_bp.route('/stock-financials/<ticker>', methods=['GET'])
def get_stock_financials(ticker):
    """Get financial statements for a stock."""
    try:
        data = yf.Ticker(ticker)
        return jsonify({
            'quarterly_income_stmt': data.quarterly_income_stmt.to_dict() if hasattr(data.quarterly_income_stmt, 'to_dict') else None
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@price_bp.route('/stock-history/<ticker>', methods=['GET'])
def get_stock_history(ticker):
    """Get historical price data for a stock."""
    try:
        period = request.args.get('period', '1mo')
        data = yf.Ticker(ticker)
        history = data.history(period=period)
        return jsonify({
            'history': history.to_dict('records') if hasattr(history, 'to_dict') else None
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@price_bp.route('/fund-data/<ticker>', methods=['GET'])
def get_fund_data(ticker):
    """Get fund data for ETFs like SPY."""
    try:
        data = yf.Ticker(ticker)
        funds_data = data.funds_data
        
        response = {}
        if hasattr(funds_data, 'description'):
            response['description'] = funds_data.description
        if hasattr(funds_data, 'top_holdings'):
            response['top_holdings'] = funds_data.top_holdings.to_dict() if hasattr(funds_data.top_holdings, 'to_dict') else None
        
        return jsonify(response)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@price_bp.route('/historical-data/<ticker>', methods=['GET'])
def get_historical_data(ticker):
    """Get historical data for backtesting."""
    try:
        start_date = request.args.get('start_date')
        end_date = request.args.get('end_date')
        interval = request.args.get('interval', '1d')
        
        # Validate dates
        if start_date:
            start_date = datetime.strptime(start_date, '%Y-%m-%d')
        if end_date:
            end_date = datetime.strptime(end_date, '%Y-%m-%d')
            
        # Get historical data
        data = yf.Ticker(ticker)
        history = data.history(start=start_date, end=end_date, interval=interval)
        
        # Format for backtesting
        formatted_data = {
            'close': history['Close'].values.tolist(),
            'open': history['Open'].values.tolist(),
            'high': history['High'].values.tolist(),
            'low': history['Low'].values.tolist(),
            'volume': history['Volume'].values.tolist(),
            'dates': history.index.strftime('%Y-%m-%d').tolist()
        }
        
        return jsonify(formatted_data)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Helper function that can be imported by other modules
def fetch_historical_data(ticker, start_date, end_date, interval='1d'):
    """
    Fetch historical data for a ticker that can be used by the backtesting module.
    
    Args:
        ticker (str): The ticker symbol
        start_date (str or datetime): Start date in 'YYYY-MM-DD' format or datetime object
        end_date (str or datetime): End date in 'YYYY-MM-DD' format or datetime object
        interval (str): Data interval (1d, 1wk, 1mo, etc.)
        
    Returns:
        pandas.DataFrame: Historical data
    """
    try:
        data = yf.Ticker(ticker)
        history = data.history(start=start_date, end=end_date, interval=interval)
        return history
    except Exception as e:
        print(f"Error fetching historical data: {str(e)}")
        return None 