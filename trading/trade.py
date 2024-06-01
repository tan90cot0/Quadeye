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

session_end_time = [15, 27, 0]
interval = 0.21

session_tm = session_end_time[0]*60*60 + session_end_time[1]*60 + session_end_time[2] - 1
compare_tm = session_tm - 2
total_money = 4925927

initial_buys = [0 for i in range(10)]
initial_sells = [0 for i in range(10)]
volume_change_buys = [0 for i in range(10)]
volume_change_sells = [0 for i in range(10)]
volume_change = [0 for i in range(10)]
buy_margin = [0 for i in range(10)]
sell_margin = [0 for i in range(10)]
populated = False

def get_margins(data):
    for i in range(len(order_book["data"])):
        total_buys = 0
        for j in range(len(data[i]["buy_orders"])):
            total_buys+=data[i]["buy_orders"][j]["quantity"]
        volume_change_buys[i] = total_buys - initial_buys[i]

        total_sells = 0
        for j in range(len(data[i]["sell_orders"])):
            total_sells+=data[i]["sell_orders"][j]["quantity"]
        volume_change_sells[i] = total_sells - initial_sells[i]
    
        volume_change[i] = volume_change_buys[i] - volume_change_sells[i]

        buy_margin[i] = (80*(total_buys+4850-total_sells))/(total_buys+4850+total_sells)
        sell_margin[i] = (80*(total_buys-4850-total_sells))/(total_buys+4850+total_sells)
        if buy_margin[i]>0:
            buy_margin[i] = 0
        if sell_margin[i]<0:
            sell_margin[i] = 0

def get_best_stock():
    best_buy = np.argmin(np.array(buy_margin))
    best_sell = np.argmax(np.array(sell_margin))
    highest_buy_shift = np.argmax(np.array(volume_change))
    highest_sell_shift = np.argmin(np.array(volume_change))

    if volume_change[highest_buy_shift] > 30000:
        price = max(1000 + sell_margin[highest_buy_shift]//2 - 1, 1001)
        payload = {
            'order_type': "SELL",
            'price': price,
            'quantity': total_money//price,
            'symbol': data[highest_buy_shift]['symbol']
        }
        return payload
    elif volume_change[highest_sell_shift] < -30000:
        price = min(1000 + buy_margin[highest_sell_shift]//2 + 2, 999)
        payload = {
            'order_type': "BUY",
            'price': price,
            'quantity': total_money//price,
            'symbol': data[highest_sell_shift]['symbol']
        }
        return payload
    elif sell_margin[best_sell] > abs(buy_margin[best_buy]):
        price = max(1000 + sell_margin[best_sell]//2 - 1, 1001)
        payload = {
            'order_type': "SELL",
            'price': price,
            'quantity': total_money//price,
            'symbol': data[best_sell]['symbol']
        }
    elif sell_margin[best_sell] < abs(buy_margin[best_buy]):
        price = min(1000 + buy_margin[best_buy]//2 + 2, 999)
        payload = {
            'order_type': "BUY",
            'price': price,
            'quantity': total_money//price,
            'symbol': data[best_buy]['symbol']
        }
    else:
        for i in range(len(order_book["data"])):
            total_buys = 0
            for j in range(len(data[i]["buy_orders"])):
                total_buys+=data[i]["buy_orders"][j]["quantity"]

            total_sells = 0
            for j in range(len(data[i]["sell_orders"])):
                total_sells+=data[i]["sell_orders"][j]["quantity"]
        
            buy_margin[i] = (80*(total_buys+4850-total_sells))/(total_buys+4850+total_sells)
            sell_margin[i] = (80*(total_buys-4850-total_sells))/(total_buys+4850+total_sells)

            if buy_margin[i]>0:
                buy_margin[i] = 0
            if sell_margin[i]<0:
                sell_margin[i] = 0

        best_buy = np.argmin(np.array(buy_margin))
        best_sell = np.argmax(np.array(sell_margin))

        if sell_margin[best_sell] > abs(buy_margin[best_buy]):
            price = max(1000 + sell_margin[best_sell]//2, 1001)
            payload = {
                'order_type': "SELL",
                'price': price,
                'quantity': 4850,
                'symbol': data[best_sell]['symbol']
            }
        elif sell_margin[best_sell] < abs(buy_margin[best_buy]):
            price = min(1000 + buy_margin[best_buy]//2 + 1, 999)
            payload = {
                'order_type': "BUY",
                'price': price,
                'quantity': 4850,
                'symbol': data[best_buy]['symbol']
            }
        else:
            for i in range(len(order_book["data"])):
                total_buys = 0
                for j in range(len(data[i]["buy_orders"])):
                    total_buys+=data[i]["buy_orders"][j]["quantity"]

                total_sells = 0
                for j in range(len(data[i]["sell_orders"])):
                    total_sells+=data[i]["sell_orders"][j]["quantity"]
            
                buy_margin[i] = (80*(total_buys+2500-total_sells))/(total_buys+2500+total_sells)
                sell_margin[i] = (80*(total_buys-2500-total_sells))/(total_buys+2500+total_sells)

                if buy_margin[i]>0:
                    buy_margin[i] = 0
                if sell_margin[i]<0:
                    sell_margin[i] = 0

            best_buy = np.argmin(np.array(buy_margin))
            best_sell = np.argmax(np.array(sell_margin))

            if sell_margin[best_sell] > abs(buy_margin[best_buy]):
                price = max(1000 + sell_margin[best_sell]//2, 1001)
                payload = {
                    'order_type': "SELL",
                    'price': price,
                    'quantity': 2500,
                    'symbol': data[best_sell]['symbol']
                }
            else:
                price = min(1000 + buy_margin[best_buy]//2 + 1, 999)
                payload = {
                    'order_type': "BUY",
                    'price': price,
                    'quantity': 2500,
                    'symbol': data[best_buy]['symbol']
                }

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
    # print(curr_tm//60//60, curr_tm//60%60, curr_tm%60)

    if curr_tm >= compare_tm:
        if populated==False:
            for i in range(len(order_book["data"])):
                for j in range(len(data[i]["buy_orders"])):
                    initial_buys[i]+=data[i]["buy_orders"][j]["quantity"]

                for j in range(len(data[i]["sell_orders"])):
                    initial_sells[i]+=data[i]["sell_orders"][j]["quantity"]
            # initial buys and sells are populated
            populated = True
            print('started')

        if curr_tm >= session_tm:
            # volume difference is populated
            get_margins(data)
            payload = get_best_stock()
            # print(payload)
            x = requests.post(post_url, headers=header, json=payload)
            print(x.text)
            if (x.text[11:16]).startswith('true'):
                break
    
    time.sleep(interval)
