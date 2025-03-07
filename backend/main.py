import time

import yfinance as yf
from flask import Flask, jsonify
from flask_cors import CORS
from routes.backtesting import backtesting_bp
from routes.price import price_bp

app = Flask(__name__)
CORS(app)

# Register blueprints
app.register_blueprint(price_bp, url_prefix='/api/price')
app.register_blueprint(backtesting_bp, url_prefix='/api/backtesting')

@app.route("/")
def health():
    return "alive"

if __name__ == "__main__":
    app.run(debug=True)