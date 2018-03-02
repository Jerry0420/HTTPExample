//
//  ViewController.swift
//  HTTPExample
//
//  Created by JerryWang on 2017/2/27.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit

let baseGetURL = "https://httpbin.org/get"
let basePostURL = "https://httpbin.org/post"

let getParameters = ["para1":"value1","para2":"value2"]
let getHeaders = ["header1":"value1","header2":"value2"]
let postJSON = ["para1":"value1","para2":"value2"]
let postURLencoded = "para1=value1&para2%5Bvalue21%5D=value22"
let postFormData = ["para1":"value1"]

let downLoadURL = "https://upload.wikimedia.org/wikipedia/en/9/99/MarioSMBW.png"

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let dataArray = ["Get","Get Header","Post JSON","Post urlencoded","Post formData","Download"]
    var response : String?
    var data : Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initResponse()
    }
    
    func initResponse() {
        data = nil
        response = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showData"{
            if let showDataVC = segue.destination as? ShowDataViewController{
                showDataVC.data = data
                showDataVC.response = response
            }
        }
    }
    
    func processData(data: Data){
        let fetchedDictionary = data.parseData()
        self.response = fetchedDictionary.description
        self.activityIndicator.stopAnimating()
        self.performSegue(withIdentifier: "showData", sender: self)
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //做請求
        let image = UIImage(named: "MAGNIFYING")
        let uploadData = UIImageJPEGRepresentation(image!, 0.1)
        activityIndicator.startAnimating()
        
        switch indexPath.row {
        case 0:
            APIManager().requestWithURL(urlString: baseGetURL, parameters: getParameters, completion: { (data) in
                DispatchQueue.main.async {
                    self.processData(data: data)
                }
            })
        case 1:
            APIManager().requestWithHeader(urlString: baseGetURL, parameters: getHeaders, completion: { (data) in
                DispatchQueue.main.async {
                    self.processData(data: data)
                }
            })
        case 2:
            APIManager().requestWithJSONBody(urlString: basePostURL, parameters: postJSON, completion: { (data) in
                DispatchQueue.main.async {
                    self.processData(data: data)
                }
            })
        case 3:
            APIManager().requestWithUrlencodedBody(urlString: basePostURL, parameters: postURLencoded, completion: { (data) in
                DispatchQueue.main.async {
                    self.processData(data: data)
                }
            })
        case 4:
            let dataPath = ["file":uploadData!]
            APIManager().requestWithFormData(urlString: basePostURL, parameters: postFormData, dataPath: dataPath, completion: { (data) in
                DispatchQueue.main.async {
                    self.processData(data: data)
                }
            })
        case 5:
            APIManager().downloadByDownloadTask(urlString: downLoadURL, completion: { (data) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.data = data
                    self.performSegue(withIdentifier: "showData", sender: self)
                }
            })
        default:
            activityIndicator.stopAnimating()
            break
        }
        
        
    }
}

extension Data{
    func parseData() -> NSDictionary{
        
        let dataDict = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers) as! NSDictionary
        
        return dataDict!
    }
    
    mutating func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
