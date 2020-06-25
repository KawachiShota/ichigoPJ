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
                //self.invokeDynamo1()
                //self.invokeDynamo2()
                self.invokeDynamo(type: "moisture")
                self.invokeDynamo(type: "volt")
            }){
                Text("データ更新")
                    .font(.largeTitle)
                    .frame(width: 340, height: 60, alignment: .center)
            }
        }
    }

    func invokeDynamo1(){ //DynamoDBから水分量のデータを受信する
        let dynamoDB = AWSDynamoDB.default()
        
        var data : String!
        
        let getItemInput = AWSDynamoDBScanInput()
        getItemInput?.tableName = "ichigo_table_kawachi" //テーブル名
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
            
            self.dataTextChange1(textData:data)
            
            return nil
        }
        
    }
    
    func invokeDynamo2(){ //DynamoDBから電圧のデータを受信する
        let dynamoDB = AWSDynamoDB.default()
        
        var data : String!
        
        let getItemInput = AWSDynamoDBScanInput()
        getItemInput?.tableName = "ichigo_table_kawachi" //テーブル名
        getItemInput?.projectionExpression = "volt" //項目名

        dynamoDB.scan(getItemInput!).continueWith{ (task: AWSTask?) -> AnyObject? in
            if let error = task!.error {
                print("Error occurred: \(error)")
                return nil
            }
            
            let listItemOutput = task!.result!
            
            for itemName in listItemOutput.items! { //itemを一つずつ変数dataに格納する
                print("\(itemName)")
                print("\(itemName["volt"]!.s!)")
                data = itemName["volt"]!.s!
            }
            
            self.dataTextChange2(textData:data)
            
            return nil
        }
        
    }
    
    func dataTextChange1(textData :String){ //表示テキストを最新の水分量データに更新する
        mData = textData
    }
    
    func dataTextChange2(textData :String){ //表示テキストを最新の電圧データに更新する
        vData = textData
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
    
    func getDate() -> String { //現在の日付、時刻を取得する(例：2100/1/1 12:00:00)
        let dt = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMdkHms", options: 0, locale: Locale(identifier: "ja_JP"))
        
        return dateFormatter.string(from: dt)
    }
    
    func postSlack(){
        
        // create the url-request
        let urlString = "https://hooks.slack.com/services/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"
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)

        // set the method(HTTP-POST)
        request.httpMethod = "POST"
        // set the header(s)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // set the request-body(JSON)
        let params: [String: String] = [
            "text": "アプリからslackに送るテストです",
            "icon_emoji": "icon",
            "username": "kawachi"
        ]
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        }catch{
            print(error.localizedDescription)
        }

        // use NSURLSessionDataTask
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

