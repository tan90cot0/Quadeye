import requests
import time
import pandas as pd
import numpy as np

import os

token = '8cdfc3c45e4ead2ee5042a2556c66dedee9bab25'
get_order_url = 'https://itrade.quadeye.com/backend/v1/trading_terminal/get_order_book/'
post_url = 'https://itrade.quadeye.com/backend/v1/trading_terminal/create_order/'
header = {
    "Content-Type": "application/json",
    "Authorization": f'Token {token}'
}

session_end_time = [19, 2, 0]
interval = 0.21

session_tm = session_end_time[0]*60*60 + session_end_time[1]*60 + session_end_time[2] - 1
compare_tm = session_tm - 2
total_money = 11076113

def get_margins(data):
    buy_margin = [0 for i in range(10)]
    sell_margin = [0 for i in range(10)]
    for i in range(len(order_book["data"])):
        total_buys = 0
        for j in range(len(data[i]["buy_orders"])):
            total_buys+=data[i]["buy_orders"][j]["quantity"]

        total_sells = 0
        for j in range(len(data[i]["sell_orders"])):
            total_sells+=data[i]["sell_orders"][j]["quantity"]

        buy_margin[i] = (80*(total_buys+10701-total_sells))/(total_buys+10701+total_sells)
        sell_margin[i] = (80*(total_buys-10701-total_sells))/(total_buys+10701+total_sells)
        if buy_margin[i]>0:
            buy_margin[i] = 0
        if sell_margin[i]<0:
            sell_margin[i] = 0
    return buy_margin, sell_margin

def get_best_stock(buy_margin, sell_margin):
    best_buy = np.argmin(np.array(buy_margin))
    best_sell = np.argmax(np.array(sell_margin))

    if sell_margin[best_sell] > abs(buy_margin[best_buy]):
        price = 1000 + sell_margin[best_sell]//2
        payload = {
            'order_type': "SELL",
            'price': price,
            'quantity': total_money//price,
            'symbol': data[best_sell]['symbol']
        }
    else:
        price = 1000 + buy_margin[best_buy]//2 + 1
        payload = {
            'order_type': "BUY",
            'price': price,
            'quantity': total_money//price,
            'symbol': data[best_buy]['symbol']
        }

    print("Best buy: " + data[best_buy]['symbol'] + " " + str(1000 + buy_margin[best_buy]))
    print("Best sell: " + data[best_sell]['symbol'] + " " + str(1000 + sell_margin[best_sell]))
    print()

    return payload

while True:
    try:
        response = requests.get(get_order_url, headers=header)
        order_book = response.json()
        tm = response.headers['Date'][-12:-3].split(':')
        tm = int(tm[0])*60*60 + int(tm[1])*60 + int(tm[2])
        curr_tm = tm + 5*60*60 + 30*60
    except:
        time.sleep(interval)
        continue

    data = order_book['data']
    buy_margin, sell_margin = get_margins(data)
    payload = get_best_stock(buy_margin, sell_margin)

    print(payload)
    if curr_tm >= session_tm:
        x = requests.post(post_url, headers=header, json=payload)
        if (x.text[11:16]).startswith('true'):
            break
        print(x.text)

    print("BUY")
    for i in range(10):
        print(data[i]['symbol'] + " " + str(1000 + buy_margin[i]))
    print()
    print("SELL")
    for i in range(10):
        print(data[i]['symbol'] + " " + str(1000 + sell_margin[i]))
    print()
    print()
    
    time.sleep(interval)
