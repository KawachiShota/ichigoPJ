#! /usr/bin/env /usr/bin/python
# -*- coding: utf-8 -*-

import logging
import getopt
import time
import json
import datetime
import sys
sys.path.append('usr/local/lib/.......')
from AWSIoTPythonSDK.MQTTLib import AWSIoTMQTTClient

class Dynamodb:
    myMQTTClient = AWSIoTMQTTClient("testIoTPySDK") 
    
    def __init__(self):
        self.myMQTTClient.configureEndpoint("au87va42i39z0-ats.iot.us-east-1.amazonaws.com",8883) #8883はポート
        self.myMQTTClient.configureCredentials('AmazonRootCA1.pem','33eefb28da-private.pem.key','33eefb28da-certificate.pem.crt') #証明書3つ、同じフォルダ内に置いてます
        self.myMQTTClient.configureOfflinePublishQueueing(-1)
        self.myMQTTClient.configureDrainingFrequency(2)
        self.myMQTTClient.configureConnectDisconnectTimeout(10)
        self.myMQTTClient.configureMQTTOperationTimeout(5)
        self.myMQTTClient.connect()

    def customCallback(self, client, userdata, message):
        print('Received new message')
        print(message.payload)
        print('from Topic')
        print(message.topic)
        print('--------\n\n')
        
    def sendData(self, t, m):
        sending_msg = json.dumps({"time_in":t,"mois_in":'{:.2f}'.format(m),"sentmessage":"this is a test from RasPi1"})
        
        self.myMQTTClient.subscribe("RaspberryPi/topic_test", 1, self.customCallback)
        self.myMQTTClient.publish("RaspberryPi/topic_test", sending_msg, 1)
