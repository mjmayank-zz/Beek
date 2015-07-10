//
//  DetailView.swift
//  
//
//  Created by Mayank Jain on 7/9/15.
//
//

import Foundation
import UIKit
import Parse

class DetailViewController : UIViewController {
    
    var detailObject : PFObject!

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = detailObject.objectForKey("title") as? String
        bodyLabel.text = detailObject.objectForKey("body") as? String
    }
    
}