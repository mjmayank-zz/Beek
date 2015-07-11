//
//  DetailView.swift
//  
//
//  Created by Mayank Jain on 7/9/15.
//
//

import Foundation
import UIKit

class DetailViewController : UIViewController {
    
    var detailObject : PostModel!

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = detailObject.title
        bodyLabel.text = detailObject.body
    }
    
}