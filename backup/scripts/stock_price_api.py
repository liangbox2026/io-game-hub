#!/usr/bin/env python3
# =============================================================================
# 股票实时行情查询 - 腾讯财经 API (稳定)
# =============================================================================

import requests

def get_stock_price(stock_code):
    """查询 A 股实时行情 - 腾讯财经 API"""
    
    # 根据股票代码判断市场
    if stock_code.startswith('6'):
        market = 'sh'
    else:
        market = 'sz'
    
    # 腾讯财经行情 API
    url = f"http://qt.gtimg.cn/q={market}{stock_code}"
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Referer': 'http://stockapp.finance.qq.com/'
    }
    
    try:
        response = requests.get(url, headers=headers, timeout=5)
        response.encoding = 'gbk'
        
        if response.status_code == 200:
            data = response.text.strip()
            
            if data and '=' in data:
                # 解析：v_sh600406="51~~~..."
                content = data.split('"')[1]
                elements = content.split('~')
                
                if len(elements) >= 50:
                    return {
                        'code': stock_code,
                        'name': elements[1],
                        'current': float(elements[3]),      # 现价 (元)
                        'pre_close': float(elements[4]),    # 昨收
                        'open': float(elements[5]),         # 开盘
                        'volume': float(elements[6]),       # 成交量 (手)
                        'amount': float(elements[7]),       # 成交额 (万元)
                        'high': float(elements[33]),        # 最高
                        'low': float(elements[34]),         # 最低
                        'change': float(elements[31]),      # 涨跌额
                        'change_percent': float(elements[32]),  # 涨跌幅
                        'pe': float(elements[39]),          # 市盈率
                        'pb': float(elements[46]),          # 市净率
                        'total_market_cap': float(elements[45]),  # 总市值 (亿)
                        'float_market_cap': float(elements[44]),  # 流通市值 (亿)
                    }
        return None
    except Exception as e:
        print(f"❌ 查询失败：{e}")
        return None

def print_stock_info(stock_data):
    """格式化打印股票信息"""
    if not stock_data:
        print("❌ 未获取到数据")
        return
    
    change_emoji = "📈" if stock_data['change'] >= 0 else "📉"
    
    print(f"\n{change_emoji} {stock_data['name']} ({stock_data['code']})")
    print(f"━━━━━━━━━━━━━━━━━━━")
    print(f"现价：   {stock_data['current']:.2f} 元")
    print(f"涨跌：   {stock_data['change']:.2f} 元 ({stock_data['change_percent']:.2f}%)")
    print(f"开盘：   {stock_data['open']:.2f} 元")
    print(f"最高：   {stock_data['high']:.2f} 元")
    print(f"最低：   {stock_data['low']:.2f} 元")
    print(f"昨收：   {stock_data['pre_close']:.2f} 元")
    print(f"市盈率： {stock_data['pe']:.2f}")
    print(f"市净率： {stock_data['pb']:.2f}")
    print(f"成交量： {stock_data['volume']:.2f} 手")
    print(f"成交额： {stock_data['amount']:.2f} 万元")
    print(f"总市值： {stock_data['total_market_cap']:.2f} 亿")
    print(f"流通值： {stock_data['float_market_cap']:.2f} 亿")
    print(f"━━━━━━━━━━━━━━━━━━━\n")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("用法：python3 stock_price.py <股票代码>")
        sys.exit(1)
    
    stock_code = sys.argv[1]
    print(f"🔍 查询 {stock_code} 实时行情...")
    
    data = get_stock_price(stock_code)
    print_stock_info(data)
