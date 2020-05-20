#! /usr/bin/env /usr/bin/python
# -*- coding: utf-8 -*-

import spidev
import time
import datetime
from dynamodb import Dynamodb

#インスタンス
dyna = Dynamodb()

spi = spidev.SpiDev() # SpiDev オブジェクトのインスタンスを生成

spi.open(0, 0) # ポート0、デバイス0のSPIをオープン

spi.max_speed_hz=1000000 # 最大クロックスピードを1MHzに設定

spi.bits_per_word=8 # 1ワードあたり8ビットに設定

dummy = 0xff # ダミーデータを設定(1111 1111)
start = 0x47 # スタートビットを設定(0100 0111)
sgl = 0x20 # シングルエンドモードを設定(0010 0000)
ch0 = 0x00 # ch0 を選択(0000 0000)

msbf = 0x08 # MSB ファーストモードを選択(0000 1000)

# IC からデータを取得する関数を定義
def measure(ch):
    # SPI インターフェイスでデータの送受信を行う
    ad = spi.xfer2( [ (start + sgl +ch + msbf), dummy ] )
    # 受信した2バイトのデータを10ビットデータにまとめる
    val = ( ( ( (ad[0] & 0x03) << 8) + ad[1] ) * 5.0 ) / 1023
    # 結果を返す
    return val
    
# 例外を検出
try:
    # 無限ループ
    while 1:
        t = datetime.datetime.now()
        t = t.strftime('%Y/%m/%d %H:%M:%S')
        
        # 関数を呼び出してch0のデータを取得
        mes_ch0 = measure(ch0)
        
        # 水分量を計算する
        mois = mes_ch0 * 100 / 4.2
        
        # 結果を表示
        print('%s' % t)
        print('ch0 = %2.2f' % mes_ch0, '[V]','moisture = %2.2f' % mois, '[%]')
        
        dyna.sendData(t, mois)
        
        # 0.5秒待つ
        time.sleep(2.0)
        
# キーボード例外を検出
except KeyboardInterrupt:
    # 何も処理をしない
    pass
    
# SPIを開放
spi.close() 
