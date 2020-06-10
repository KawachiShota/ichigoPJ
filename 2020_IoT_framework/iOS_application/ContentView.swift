//
//  ContentView.swift
//  iot_framework_ichigo
//
//  Created by Kawachi Shota on 2020/06/05.
//  Copyright © 2020 Kawachi Shota. All rights reserved.
//

import SwiftUI
import AWSDynamoDB

struct ContentView: View {
    
    //var dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
    @State private var mData : String! = "0.0"
    
    var body: some View {
        VStack(){
            Image("suiteki") //"suiteki.png"を表示する
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
            Text("水分量") //"水分量"テキストを表示する
                .font(.largeTitle)
            Text("\(mData)") //水分量データをテキストで表示する
                .font(.largeTitle)
                .frame(width: 340, height: 60, alignment: .center)
            Button(action: { //ボタンが押されとデータを更新する
                print("Button Tapped")
                self.invokeDynamo()
                self.reportDynamo()
            }){
                Text("データ更新")
                    .font(.largeTitle)
                    .frame(width: 340, height: 60, alignment: .center)
            }
        }
    }

    func invokeDynamo(){
        let dynamoDB = AWSDynamoDB.default()
        
        var data : String!
        
        let getItemInput = AWSDynamoDBScanInput()
        getItemInput?.tableName = "iot_framework_test_2" //テーブル名
        getItemInput?.projectionExpression = "moisture" //項目名

        dynamoDB.scan(getItemInput!).continueWith{ (task: AWSTask?) -> AnyObject? in
            if let error = task!.error {
                print("Error occurred: \(error)")
                return nil
            }
            
            let listItemOutput = task!.result!
            
            for itemName in listItemOutput.items! { //itemを一つずつ変数dataに格納する
                print("\(itemName)")
                print("\(itemName["moisture"]!.s!)")
                data = itemName["moisture"]!.s!
            }
            
            self.dataTextChange(textData:data)
            
            return nil
        }
        
    }
    
    func reportDynamo(){
        let dynamoDB = AWSDynamoDB.default()
        
        let hashAttribute1 = AWSDynamoDBAttributeValue()
        hashAttribute1?.s = "kawachi"
        
        let hashAttribute2 = AWSDynamoDBAttributeValue()
        hashAttribute2?.s = self.getDate()
        
        let putRequest = AWSDynamoDBPutRequest()
        putRequest?.item = ["name": hashAttribute1!,"time": hashAttribute2!]
        
        let writeRequest = AWSDynamoDBWriteRequest()
        writeRequest?.putRequest = putRequest
        
        let batchWriteRequest = AWSDynamoDBBatchWriteItemInput()
        batchWriteRequest?.requestItems = ["data_get_report": [writeRequest!]]

        dynamoDB.batchWriteItem(batchWriteRequest!).continueWith{ (task: AWSTask?) -> AnyObject? in
            if let error = task!.error {
                print("Error occurred: \(error)")
                return nil
            }
            
            let listItemOutput = task!.result!
            print(listItemOutput)
            
            return nil
        }
        
    }
    
    func dataTextChange(textData :String){ //表示テキストを最新の水分量データに更新する
        mData = textData
    }
    
    func getDate() -> String { //現在の日付、時刻を取得する(例：2100/1/1 12:00:00)
        let dt = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMdkHms", options: 0, locale: Locale(identifier: "ja_JP"))
        
        return dateFormatter.string(from: dt)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

