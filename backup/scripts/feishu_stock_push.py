#!/usr/bin/env python3
# =============================================================================
# 飞书股票行情推送 - 实时股价查询并发送到飞书
# 功能：查询股票行情并发送到飞书机器人
# =============================================================================

import requests
import sys
from datetime import datetime

# 股票行情查询 (新浪财经 API)
def get_stock_price(stock_code):
    """查询 A 股实时行情"""
    if stock_code.startswith('6'):
        market = 'sh'
    else:
        market = 'sz'
    
    url = f"http://hq.sinajs.cn/list={market}{stock_code}"
    
    try:
        response = requests.get(url, timeout=5)
        response.encoding = 'gbk'
        data = response.text.strip()
        
        if data:
            elements = data.split('"')[1].split(',')
            if len(elements) >= 32:
                return {
                    'name': elements[0],
                    'current': float(elements[3]),
                    'change': round(float(elements[3]) - float(elements[2]), 2),
                    'change_percent': round(((float(elements[3]) - float(elements[2])) / float(elements[2])) * 100, 2),
                    'high': float(elements[4]),
                    'low': float(elements[5]),
                    'volume': float(elements[8]),
                    'amount': float(elements[9]),
                    'time': f"{elements[30]} {elements[31]}"
                }
        return None
    except Exception as e:
        print(f"❌ 查询失败：{e}")
        return None

# 发送飞书消息
def send_feishu_message(webhook_url, message):
    """发送消息到飞书"""
    headers = {'Content-Type': 'application/json'}
    payload = {
        "msg_type": "text",
        "content": {
            "text": message
        }
    }
    
    try:
        response = requests.post(webhook_url, json=payload, headers=headers, timeout=10)
        if response.status_code == 200:
            return True
        return False
    except Exception as e:
        print(f"❌ 发送失败：{e}")
        return False

# 主函数
if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("用法：python3 feishu_stock_push.py <股票代码> <飞书 webhook>")
        print("示例：python3 feishu_stock_push.py 002837 https://open.feishu.cn/open-apis/bot/v2/hook/xxx")
        sys.exit(1)
    
    stock_code = sys.argv[1]
    webhook_url = sys.argv[2]
    
    # 查询股价
    print(f"🔍 查询 {stock_code} 实时行情...")
    stock_data = get_stock_price(stock_code)
    
    if not stock_data:
        print("❌ 获取股价失败")
        sys.exit(1)
    
    # 构建消息
    change_emoji = "📈" if stock_data['change'] >= 0 else "📉"
    message = f"""{change_emoji} 股票行情 ({stock_code})

名称：{stock_data['name']}
现价：{stock_data['current']} 元
涨跌：{stock_data['change']} 元 ({stock_data['change_percent']}%)
最高：{stock_data['high']} 元
最低：{stock_data['low']} 元
成交量：{stock_data['volume']/10000:.2f} 万手
成交额：{stock_data['amount']/100000000:.2f} 亿元
时间：{stock_data['time']}

数据来源：新浪财经"""
    
    # 发送到飞书
    print("📤 发送到飞书...")
    if send_feishu_message(webhook_url, message):
        print("✅ 发送成功")
    else:
        print("❌ 发送失败")
        sys.exit(1)
