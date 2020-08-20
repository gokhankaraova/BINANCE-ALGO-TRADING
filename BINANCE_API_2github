import os
from binance.client import Client
from binance.websockets import BinanceSocketManager
from twisted.internet import reactor
import time
from datetime import timedelta, datetime
from dateutil import parser
import numpy as np
from binance.exceptions import BinanceAPIException, BinanceOrderException

binance_api='key'
binance_secret='secret'

client = Client(api_key=binance_api, api_secret=binance_secret)

def topup_bnb(min_balance: float, topup: float):
    ''' Top up BNB balance if it drops below minimum specified balance '''
    bnb_balance = client.get_asset_balance(asset='BNB')
    bnb_balance = float(bnb_balance['free'])
    if bnb_balance < min_balance:
        qty = round(topup - bnb_balance, 5)
        order = client.order_market_buy(symbol='BNBUSDT', quantity=qty)
        return order
    return False
    
f=open("buy_prices.txt","r")
buy_price=f.read()
f.close()
buy_price=eval(buy_price)

f=open("buy_xs.txt","r")
buy_x=f.read()
f.close()
buy_x=eval(buy_x)

f=open("transactions.txt","r")
transactions=f.read()
f.close()
transactions=eval(transactions)


    
print("Start")
while True :
        
    klines = client.get_historical_klines("BTCUSDT", Client.KLINE_INTERVAL_1MINUTE, "4 min ago UTC")

    t_3 = np.array(klines[0])
    t_2 = np.array(klines[1])
    t_1 = np.array(klines[2])
    t_0 = np.array(klines[3])

    opens= np.array([t_3[1],t_2[1],t_1[1],t_0[1]])
    highs= np.array([t_3[2],t_2[2],t_1[2],t_0[2]])
    lows=  np.array([t_3[3],t_2[3],t_1[3],t_0[3]])
    closes=np.array([t_3[4],t_2[4],t_1[4],t_0[4]])

    high_olds= np.array([t_3[2],t_2[2],t_1[2]])
    high_max_olds = max(high_olds)
    opens3_str=opens[3]
    opens3_flt= opens3_str.astype(np.float)
    closes3_str=closes[3]
    closes3_flt= closes3_str.astype(np.float)
    highs3_str=highs[3]
    highs3_flt= highs3_str.astype(np.float)
    lows3_str=lows[3]
    lows3_flt= lows3_str.astype(np.float)
    
    assetsUSDT = client.get_asset_balance(asset='USDT')
    currentUSDT_balance=float(assetsUSDT["free"])
    
    assetsBTC = client.get_asset_balance(asset='BTC')
    currentBTC_balance=float(assetsBTC["free"])
    
    
    if currentUSDT_balance > 30:
        min_balance = 0.1
        topup = 0.5
        order = topup_bnb(min_balance, topup)
        
    
    # buy
    if currentUSDT_balance > 13:
        if highs3_str < high_max_olds:
            if opens3_str < closes3_str:
                if np.subtract(opens3_flt, lows3_flt) > np.subtract(closes3_flt, opens3_flt) or np.subtract(highs3_flt, closes3_flt) > np.subtract(closes3_flt, opens3_flt):
                    precision = 5
                    price = 0.001
                    price_str = '{:0.0{}f}'.format(price, precision)
                    market_order = client.order_market_buy(symbol='BTCUSDT', quantity=price)
                    transactions += 1
                    buy_priceData = client.get_symbol_ticker(symbol="BTCUSDT")
                    buy_price.append(float(buy_priceData["price"]))
                    buy_x.append(np.subtract(opens3_flt,lows3_flt))
                    
                    f=open("buy_prices.txt","w")
                    f.write(str(buy_price))
                    f.close()
                    
                    f=open("buy_xs.txt","w")
                    f.write(str(buy_x))
                    f.close()
                    
                    f=open("transactions.txt","w")
                    f.write(str(transactions))
                    f.close()
                    
            if opens3_str > closes3_str:
                if np.subtract(closes3_flt, lows3_flt) > np.subtract(opens3_flt, closes3_flt) or np.subtract(highs3_flt, opens3_flt) > np.subtract(opens3_flt, closes3_flt):
                    precision = 5
                    price = 0.001
                    price_str = '{:0.0{}f}'.format(price, precision)
                    market_order = client.order_market_buy(symbol='BTCUSDT', quantity=price)
                    transactions += 1
                    buy_priceData = client.get_symbol_ticker(symbol="BTCUSDT")
                    buy_price.append(float(buy_priceData["price"]))
                    buy_x.append(np.subtract(closes3_flt,lows3_flt))
                    
                    f=open("buy_prices.txt","w")
                    f.write(str(buy_price))
                    f.close()
                    
                    f=open("buy_xs.txt","w")
                    f.write(str(buy_x))
                    f.close()
                     
                    f=open("transactions.txt","w")
                    f.write(str(transactions))
                    f.close()
                    
    current_priceData = client.get_symbol_ticker(symbol="BTCUSDT")
    current_price=float(current_priceData["price"])
    # sell
    if transactions > 0:
    
        
        for sales_count in range(transactions):
            if currentBTC_balance > 0.001:
                if  np.subtract(current_price,buy_price[sales_count]) > np.multiply(20,buy_x[sales_count]):
                    precision = 5
                    price = 0.001
                    price_str = '{:0.0{}f}'.format(price, precision)
                    market_order = client.order_market_sell(symbol='BTCUSDT', quantity=price)
                    print("Bought at ", buy_price[sales_count])
                    print("Sold at ", current_price)
                    assetsBTC_NEW = client.get_asset_balance(asset='BTC')
                    currentBTC_balance_NEW=float(assetsBTC_NEW["free"])
                    assetsUSDT_NEW = client.get_asset_balance(asset='USDT')
                    currentUSDT_balance_NEW=float(assetsUSDT_NEW["free"])
                    print("Current total USDT ", currentUSDT_balance_NEW+current_price*currentBTC_balance_NEW)
                    buy_price[sales_count] = 20000
                    
                    f=open("buy_prices.txt","w")
                    f.write(str(buy_price))
                    f.close()
                    
    time.sleep(60)
