//
//  ViewController.swift
//  Adrress
//
//  Created by sunlantao on 2019/9/4.
//  Copyright © 2019 sunlantao. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let textfield = UITextField()
        textfield.placeholder = "选择地址"
        textfield.frame = CGRect(x: 50, y: 100, width: 200, height: 30)
        textfield.tintColor = .clear
        textfield.delegate = self
        let picker = CCAddressPicker.picker(textfield)
        weak var wt = textfield
        picker.pickOver = {arr in
            var a = ""
            for o in arr{
                a.append(o.name ?? "")
            }
            wt?.text = a
            wt?.resignFirstResponder()
        }
        textfield.inputView = picker
        
        self.view.addSubview(textfield)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        return false
    }
    
}

