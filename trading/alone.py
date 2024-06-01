import requests

symbol_list = ["CSK", "RCB", "MI", "DC", "SRH", "RR", "PBKS", "GT", "KKR", "LSG"]
total_money = 6215566
def create_order(payload):
    url = "https://itrade.quadeye.com/backend/v1/trading_terminal/create_order/"
    headers = {
        'Accept': 'application/json, text/plain, */*',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Accept-Language': 'en-US,en;q=0.9',
        'Authorization': 'Token 8cdfc3c45e4ead2ee5042a2556c66dedee9bab25',
        'Connection': 'keep-alive',
        'Content-Type': 'application/json',
        'Cookie': 'access_token=8cdfc3c45e4ead2ee5042a2556c66dedee9bab25',
        'Host': 'itrade.quadeye.com',
        'Origin': 'https://itrade.quadeye.com',
        'Referer': 'https://itrade.quadeye.com/trading_terminal',
        'Sec-Ch-Ua': '"Google Chrome";v="123", "Not:A-Brand";v="8", "Chromium";v="123"',
        'Sec-Ch-Ua-Mobile': '?0',
        'Sec-Ch-Ua-Platform': '"macOS"',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-origin',
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36'
    }
    
    response = requests.post(url, headers = headers, json = payload)
    return response.json()


def get_order_book():
    url = "https://itrade.quadeye.com/backend/v1/trading_terminal/get_order_book/"
    headers = {
        'Accept': 'application/json, text/plain, */*',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Accept-Language': 'en-US,en;q=0.9',
        'Authorization': 'Token 8cdfc3c45e4ead2ee5042a2556c66dedee9bab25',
        'Connection': 'keep-alive',
        'Cookie': 'access_token=8cdfc3c45e4ead2ee5042a2556c66dedee9bab25',
        'Host': 'itrade.quadeye.com',
        'Referer': 'https://itrade.quadeye.com/trading_terminal',
        'Sec-Ch-Ua': '"Google Chrome";v="123", "Not:A-Brand";v="8", "Chromium";v="123"',
        'Sec-Ch-Ua-Mobile': '?0',
        'Sec-Ch-Ua-Platform': '"macOS"',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-origin',
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36'
    }
    
    response = requests.get(url, headers=headers)
    print(response)
    return response.json()

def calculate_order_totals(data):
    if data.get('success'):
        ap = []
        val=[]
        for symbol_data in data['data']:
            buy_orders = symbol_data['buy_orders']
            sell_orders = symbol_data['sell_orders']
            mag=0
            pr=0
            for order in buy_orders:
                if order['price']<=993 and order['quantity']>mag:
                    mag=order['quantity']
                    pr=order['price']

            for order in sell_orders:
                if order['price']>=1007:
                    mag=order['quantity']
                    pr=order['price']

            ap.append(mag)
            val.append(pr)
        
        
        max_index = ap.index(max(ap))
        ot=""
        price=val[max_index]
        if val[max_index]<1000:
            ot="BUY"
            price=max(price+4,990)
        else:
            ot="SELL"
            price=min(price-4,1010)
        price = int(price)
        max_payload = {
            "order_type": ot,
            "price": price,
            "quantity": total_money//price,
            "symbol": symbol_list[max_index]
        }
        
        print(create_order(max_payload))
        print("Maximum AP Symbol Payload:", max_payload)

    else:
        print("Failed to fetch data.")
        if data.get('errors'):
            print(f"Errors: {data['errors']}")

# Fetch and calculate order totals
order_book_data = get_order_book()
calculate_order_totals(order_book_data)
