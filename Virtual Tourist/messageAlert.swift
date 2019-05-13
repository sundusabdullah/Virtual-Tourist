//
//  massage.swift
//  Virtual Tourist
//
//  Created by sundus on 04/09/1440 AH.
//  Copyright © 1440 sundus. All rights reserved.
//

import UIKit

extension UIViewController {



func messageAlert(massage: String){
    DispatchQueue.main.async {
        let alert = UIAlertController(title: "Error", message: massage, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(alertAction)
        
    }
}
}
