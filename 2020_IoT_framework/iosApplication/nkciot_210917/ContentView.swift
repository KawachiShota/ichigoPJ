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
            Button(action: { //ボタンが押されとデータを更新する
                print("Button Tapped")
                self.invokeDynamo(type: "moisture")
            }){
                Text("データ更新")
                    .font(.largeTitle)
                    .frame(width: 340, height: 60, alignment: .center)
            }
        }
    }
    
    //DynamoDBからデータを受信する
    func invokeDynamo(type :String){
        let dynamoDB = AWSDynamoDB.default()
        
        var data : String!
        
        let getItemInput = AWSDynamoDBScanInput()
        getItemInput?.tableName = "ichigo_table_nakanishi" //テーブル名
        getItemInput?.projectionExpression = "moisture" //項目名

        dynamoDB.scan(getItemInput!).continueWith{ (task: AWSTask?) -> AnyObject? in
            if let error = task!.error {
                print("Error occurred: \(error)")
                return nil
            }
            
            let listItemOutput = task!.result!
            
            for itemName in listItemOutput.items! { //itemを一つずつ変数dataに格納する
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

