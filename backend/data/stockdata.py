import yfinance as yf

data = yf.Ticker("MSFT")

print(data.info)
print(data.calendar)
print(data.analyst_price_targets)
print(data.quarterly_income_stmt)
print(data.history(period="1mo"))
# print(data.option_chain(data.options))

spy = yf.Ticker('SPY').funds_data
print(spy.description)
print(spy.top_holdings)