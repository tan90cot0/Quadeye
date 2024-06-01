import requests

url = 'https://itrade.quadeye.com/backend/v1/trading_terminal/'
token = '54d076fcce0023963e228b27cae771e341a82d93'
payload = {
    'order_type': "SELL",
    'price': 1001,
    'quantity': 10000,
    'symbol': "CSK"
}
header = {
    "Content-Type": "application/json",
    "Authorization": f'Token {token}'
}
# x = requests.post(url, headers=header, json=payload)
# print(x.text)

def get_order_book(url, header):
    url += 'get_order_book/'
    order_book = requests.get(url, headers=header).json()
    data = order_book['data']
    print(order_book)
    max_earning = 0
    func_symbol = ""
    for i in range(len(order_book["data"])):
        best_bid_size = data[i]["buy_orders"][0]["quantity"]
        best_ask_size = data[i]["sell_orders"][0]["quantity"]
        total_bid_size = 0
        for j in range(len(data[i]["buy_orders"])):
            total_bid_size += data[i]["buy_orders"][j]["quantity"]
        total_ask_size = 0
        for j in range(len(data[i]["sell_orders"])):
            total_ask_size += data[i]["sell_orders"][j]["quantity"]
        ratio = total_bid_size/total_ask_size
        print(f"Symbol: {data[i]['symbol']}")
        print(f"Best Bid Size: {best_bid_size}")
        print(f"Best Ask Size: {best_ask_size}")
        print(f"Total Bid Size: {total_bid_size}")
        ##parse the data and pprint the best bid amount
        ##'best_bid': 'Best bid : 999, Total Bid Size: 9402', 'best_ask': 'Best offer : 1004, Total Ask Size: 1100'
        best_bid_text = data[i]['best_bid'].split(',')
        best_bid = best_bid_text[0].split(': ')[1]
        print(f"Best Bid: {best_bid}")
        best_ask_text = data[i]['best_ask'].split(',')
        best_ask = best_ask_text[0].split(': ')[1]
        best_ask = int(best_ask)
        best_bid = int(best_bid)
        print(f"Best Ask: {best_ask}")
        ##now, calculate how much profit can be made using the following rules
        mid_price = round((int(best_bid) + int(best_ask))/2)
        spread = int(best_ask) - int(best_bid)
        auction_price = round(mid_price + 20 * spread * (total_bid_size - total_ask_size) / (total_bid_size + total_ask_size))
        auction_price_if_bid = round(mid_price + 20 * spread * (total_bid_size - total_ask_size + 10000) / (total_bid_size + total_ask_size + 10000))
        auction_price_if_ask = round(mid_price + 20 * spread * (total_bid_size - total_ask_size - 10000) / (total_bid_size + total_ask_size + 10000))
        if(auction_price_if_ask >= best_ask):
            print(f"Symbol: {data[i]['symbol']}")
            print(f"Profit: {auction_price_if_ask - best_ask}")
        elif(auction_price_if_bid <= best_bid):
            print(f"Symbol: {data[i]['symbol']}")
            print(f"Profit: {best_bid - auction_price_if_bid}")
        else:
            print(f"Symbol: {data[i]['symbol']}")
            print(f"Profit: 0") 
print(round(3.5))
get_order_book(url, header)