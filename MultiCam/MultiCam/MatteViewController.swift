//
//  MatteViewController.swift
//  MultiCam
//
//  Created by Leppard on 2020/4/10.
//  Copyright © 2020 Leppard. All rights reserved.
//

import UIKit

class MatteViewController: UIViewController {
    
    @IBOutlet var hairView: UIImageView!
    @IBOutlet var toothView: UIImageView!
    @IBOutlet var skinView: UIImageView!
    @IBAction func hairDidTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        hairView.isHidden = !sender.isSelected
    }
    
    @IBAction func toothDidTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        toothView.isHidden = !sender.isSelected
    }
    @IBAction func skinDidTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        skinView.isHidden = !sender.isSelected
    }
    
    var hairImage = UIImage()
    var toothImage = UIImage()
    var skinImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hairView.image = hairImage
        toothView.image = toothImage
        skinView.image = skinImage
    }
}
