//
//  ContentView.swift
//  iot_framework
//
//  Created by Kawachi Shota on 2020/05/18.
//  Copyright © 2020 Kawachi Shota. All rights reserved.
//

import SwiftUI
import AWSDynamoDB

struct ContentView: View {
    
    //var dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
    @State private var mData : String! = "0.0"
    
    var body: some View {
        VStack(){
            Image("suiteki")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
            Text("水分量")
                .font(.largeTitle)
            Text("\(mData)")
                .font(.largeTitle)
                .frame(width: 340, height: 60, alignment: .center)
            Button(action: {
                print("Button Tapped")
                self.invokeDynamo()
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
        getItemInput?.tableName = "iot_framework_test_2"
        getItemInput?.projectionExpression = "moisture"
        //getItemInput?.filterExpression = "contains(0 ,:moisture)"

        dynamoDB.scan(getItemInput!).continueWith{ (task: AWSTask?) -> AnyObject? in
            if let error = task!.error {
                print("Error occurred: \(error)")
                return nil
            }
            
            let listItemOutput = task!.result!
            
            for itemName in listItemOutput.items! {
                print("\(itemName)")
                print("\(itemName["moisture"]!.s!)")
                data = itemName["moisture"]!.s!
            }
            
            self.dataTextChange(textData:data)
            
            return nil
        }
        
    }
    
    func dataTextChange(textData :String){
        mData = textData
    }
    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
