//
//  AboutVC.swift
//  MakeMePopular
//
//  Created by Mac on 03/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {
    
    @IBOutlet weak var back: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "gradient_bg"))
        
        setUpView()
        
    }
    
    func setUpView(){
        let utils = Utils()
        back.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 40, height: 45))
        
        let singleTap2 = UITapGestureRecognizer(target: self, action: #selector(AboutVC.didBackTapDetected))
        singleTap2.numberOfTapsRequired = 1 // you can change this value
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(singleTap2)
    }
    
    func didBackTapDetected() {
        
        self.dismiss(animated: true, completion: {})
        
    }
    
        
}

