//
//  ShowDataSViewController.swift
//  HTTPExample
//
//  Created by JerryWang on 2017/2/27.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit

class ShowDataViewController: UIViewController {

    var response : String?
    var data : Data?
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageView.image = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if data != nil{
            imageView.image = UIImage(data: data!)
        }
        textView.text = response
    }

}
