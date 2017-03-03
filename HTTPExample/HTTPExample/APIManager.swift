//
//  APIManager.swift
//  HTTPExample
//
//  Created by JerryWang on 2017/2/28.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import Foundation

class APIManager: NSObject{
    
    var downloadCompletionBlock: ((_ data: Data) -> Void)?
    
    func requestWithURL(urlString: String, parameters: [String: Any], completion: @escaping (Data) -> Void){
        
        var urlComponents = URLComponents(string: urlString)!
        urlComponents.queryItems = []
        
        for (key, value) in parameters{
            guard let value = value as? String else{return}
            urlComponents.queryItems?.append(URLQueryItem(name: key, value: value))
        }
        
        guard let queryedURL = urlComponents.url else{return}
        
        let request = URLRequest(url: queryedURL)
        
        fetchedDataByDataTask(from: request, completion: completion)
    }
    
    func requestWithHeader(urlString: String, parameters: [String: String], completion: @escaping (Data) -> Void){
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        for (key, value) in parameters{
            request.addValue(value, forHTTPHeaderField: key)
        }
        fetchedDataByDataTask(from: request, completion: completion)
        
    }
    
    func requestWithJSONBody(urlString: String, parameters: [String: Any], completion: @escaping (Data) -> Void){
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
        }catch let error{
            print(error)
        }
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        fetchedDataByDataTask(from: request, completion: completion)
    }
    
    func requestWithUrlencodedBody(urlString: String, parameters: String, completion: @escaping (Data) -> Void){
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpBody = parameters.data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        fetchedDataByDataTask(from: request, completion: completion)
        
    }
    
    func requestWithFormData(urlString: String, parameters: [String: Any], dataPath: [String: Data], completion: @escaping (Data) -> Void){
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary+\(arc4random())\(arc4random())"
        var body = Data()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        for (key, value) in parameters {
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString(string: "\(value)\r\n")
        }
        
        for (key, value) in dataPath {
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(arc4random())\"\r\n") //此處放入file name，以隨機數代替，可自行放入
            body.appendString(string: "Content-Type: image/png\r\n\r\n") //image/png 可改為其他檔案類型 ex:jpeg
            body.append(value)
            body.appendString(string: "\r\n")
        }
        
        body.appendString(string: "--\(boundary)--\r\n")
        request.httpBody = body
        
        fetchedDataByDataTask(from: request, completion: completion)
        
    }
    
    func downloadByDownloadTask(urlString: String, completion: @escaping (Data) -> Void){
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        let configiguration = URLSessionConfiguration.default
        configiguration.timeoutIntervalForRequest = .infinity
        
        let urlSession = URLSession(configuration: configiguration, delegate: self, delegateQueue: OperationQueue.main)
        
        let task = urlSession.downloadTask(with: request)
        
        downloadCompletionBlock = completion
        
        task.resume()
    }
    
    private func fetchedDataByDataTask(from request: URLRequest, completion: @escaping (Data) -> Void){
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil{
                print(error as Any)
            }else{
                guard let data = data else{return}
                completion(data)
            }
        }
        task.resume()
    }
    
}

extension APIManager: URLSessionDownloadDelegate{
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let data = try! Data(contentsOf: location)
        if let block = downloadCompletionBlock {
            block(data)
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print(progress)
    }
    
}
