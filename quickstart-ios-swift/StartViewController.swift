//
//  StartViewController.swift
//  quickstart-ios-swift
//
//  Created by Matej Trbara on 01/09/2020.
//  Copyright © 2020 Lara Vertlberg. All rights reserved.
//

import Foundation
import UIKit


class StartViewController : UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func goToDeepAR(_ sender: Any) {
        
       if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        {
            present(vc, animated: true, completion: nil)
        }
    }
    
}
