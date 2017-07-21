//
//  ScoreClient.swift
//  TestAccessScoreService
//
//  Created by Tom Patterson on 7/20/17.
//  Copyright © 2017 Tom Patterson. All rights reserved.
//
//  https://medium.com/swift-programming/http-in-swift-693b3a7bf086
//
//  Ug! - just use Swifty FFS
//

import Foundation


public class ScoreClient {
    
    let SERVICE_URL = "https://tph3djc4zl.execute-api.us-west-2.amazonaws.com/test"
    
    public init() {
    }
    
    public func getHighscores(userId: String, gameId: String, scoresCallback: @escaping ([Score]) -> Void) {
        let jsonRequestPayload: [String: Any] = [ "userId": userId, "gameId": gameId]
        
        HTTPPostJSON(url: SERVICE_URL+"/highscores", jsonObj: jsonRequestPayload as AnyObject) { (jsonResponse: Dictionary<String, AnyObject>) in
            scoresCallback(self.parseScores(json: jsonResponse))
        }
    }
    
    public func submitScore(userId: String, gameId: String, score: Int, scoresCallback: @escaping ([Score]) -> Void) {
        let jsonRequestPayload: [String: Any] = [ "userId": userId, "gameId": gameId, "score": score]
        
        HTTPPostJSON(url: SERVICE_URL+"/submitscore", jsonObj: jsonRequestPayload as AnyObject) { (jsonResponse: Dictionary<String, AnyObject>) in
            scoresCallback(self.parseScores(json: jsonResponse))
        }
    }
    
    private func parseScores(json: Dictionary<String, AnyObject>) -> [Score] {
        var scoreList: [Score] = []
        
        if let scores = json["highScores"] as? [[String: Any]] {
            for score in (scores) {
                if let player = score["userId"] as? String,
                    let score = score["highScore"] as? Int {
                    scoreList.append(Score(id: player, score:score))
                }
            }
        }
        return scoreList
    }
    
    
    // TODO: Move all this stuff to a utility class (or just use Swifty or similar)
    
    
    private func HTTPPostJSON(url: String,
                              jsonObj: AnyObject,
                              callback: @escaping (Dictionary<String, AnyObject>) -> Void) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonString = JSONStringify(value: jsonObj)
        let data: Data = jsonString.data(
            using: String.Encoding.utf8)!
        request.httpBody = data
        HTTPsendRequest(request: request, callback: callback)
    }
    
    private func JSONStringify(value: AnyObject, prettyPrinted: Bool = true) -> String {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : nil
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: options!)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }  catch {
                print("Error in generating JSON String from object!")
                return ""
            }
        }
        return ""
    }
    
    private func JSONParseDict(jsonString:String) -> Dictionary<String, AnyObject> {
        
        if let data: Data = jsonString.data(
            using: String.Encoding.utf8){
            
            do{
                if let jsonObj = try JSONSerialization.jsonObject(
                    with: data,
                    options: JSONSerialization.ReadingOptions(rawValue: 0)) as? Dictionary<String, AnyObject> {
                    return jsonObj
                }
            }catch{
                print("Error parsing JSON from \(jsonString)")
            }
        }
        return [String: AnyObject]()
    }
    
    private func HTTPsendRequest(request: URLRequest, callback: @escaping (Dictionary<String, AnyObject>) -> Void) {
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print("Error:" + (error?.localizedDescription)! )
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)!
            
            print("responseString = \(responseString)")
            
            callback(self.JSONParseDict(jsonString: responseString))
        }
        task.resume()
    }
    
    
    
    
}
