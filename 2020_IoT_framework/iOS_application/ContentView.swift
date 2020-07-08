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
    @State private var vData : String! = "0.0"
    
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
            Text("電圧") //"電圧"テキストを表示する
                .font(.largeTitle)
            Text("\(vData)") //水分量データをテキストで表示する
                .font(.largeTitle)
                .frame(width: 340, height: 60, alignment: .center)
            
            Button(action: { //ボタンが押されとデータを更新する
                print("Button Tapped")
                self.invokeDynamo(type: "moisture")
                self.invokeDynamo(type: "volt")
                self.reportDynamo()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.postSlack()
                }
            }){
                Text("データ更新")
                    .font(.largeTitle)
                    .frame(width: 340, height: 60, alignment: .center)
            }
        }
    }
    
    func invokeDynamo(type :String){
        let dynamoDB = AWSDynamoDB.default()
        
        var data : String!
        
        let getItemInput = AWSDynamoDBScanInput()
        getItemInput?.tableName = "ichigo_table_kawachi" //テーブル名
        switch type {
        case "moisture":
            getItemInput?.projectionExpression = "moisture" //項目名
        case "volt":
            getItemInput?.projectionExpression = "volt" //項目名
        default:
            self.dataTextChange(type:"error", textData:"0.0")
        }

        dynamoDB.scan(getItemInput!).continueWith{ (task: AWSTask?) -> AnyObject? in
            if let error = task!.error {
                print("Error occurred: \(error)")
                return nil
            }
            
            let listItemOutput = task!.result!
            
            for itemName in listItemOutput.items! { //itemを一つずつ変数dataに格納する
                print("\(itemName)")
                print("\(itemName[type]!.s!)")
                data = itemName[type]!.s!
            }
            
            self.dataTextChange(type :type, textData :data)
            
            return nil
        }
    }
    
    func dataTextChange(type :String,textData :String){ //表示テキストを最新の電圧データに更新する
        switch type {
        case "moisture":
            mData = textData
        case "volt":
            vData = textData
        default:
            mData = "0.0"
            vData = "0.0"
        }
    }
    
    func reportDynamo(){ //DynamoDBにデータを送信する
        //クラスAWSDynamoDBのインスタンスを作成する
        let dynamoDB = AWSDynamoDB.default()
        
        //クラスAWSDynamoDBAttributeValueの変数sにセットする
        //var s: String?
        let hashAttribute1 = AWSDynamoDBAttributeValue()
        hashAttribute1?.s = "kawachi"
        
        let hashAttribute2 = AWSDynamoDBAttributeValue()
        hashAttribute2?.s = self.getDate()
        
        //クラスAWSDynamoDBPutRequestの変数itemに値をセットする
        //var item: [String : AWSDynamoDBAttributeValue]?
        let putRequest = AWSDynamoDBPutRequest()
        putRequest?.item = ["name": hashAttribute1!,"time": hashAttribute2!]
        
        //クラスAWSDynamoDBWriteRequestの変数putRequestに値をセットする
        //var putRequest: AWSDynamoDBPutRequest?
        let writeRequest = AWSDynamoDBWriteRequest()
        writeRequest?.putRequest = putRequest
        
        //クラスAWSDynamoDBBatchWriteItemInputの変数requestItemsに値をセットする
        //var requestItems: [String : [AWSDynamoDBWriteRequest]]?
        let batchWriteRequest = AWSDynamoDBBatchWriteItemInput()
        batchWriteRequest?.requestItems = ["data_get_report": [writeRequest!]]

        //クラスAWSDynamoDBの関数batchWriteItemでDynamoDBにデータを送信する
        //func batchWriteItem(_ request: AWSDynamoDBBatchWriteItemInput) -> Any!
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
    
    func getDate() -> String { //現在の日付、時刻を取得する(例：2100/1/1 12:00:00)
        let dt = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMdkHms", options: 0, locale: Locale(identifier: "ja_JP"))
        
        return dateFormatter.string(from: dt)
    }
    
    func postSlack(){ //slackにデータを送信する
        
        // URLリクエストを作成する
        let urlString = "https://hooks.slack.com/services/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"
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)

        // 変数httpMethodに値をセットする
        request.httpMethod = "POST"
        // 変数addValueに値をセットする
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // 変数httpBodyに値をセットする
        let params: [String: String] = [
            "text": "テストです。水分量：\(mData!), 電圧：\(vData!)",
            "icon_emoji": "icon",
            "username": "kawachi"
        ]
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        }catch{
            print(error.localizedDescription)
        }

        // NSURLSessionDataTaskを使う
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            if (error == nil) {
                let result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                print(result)
            } else {
                print(error)
            }
        })
        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

