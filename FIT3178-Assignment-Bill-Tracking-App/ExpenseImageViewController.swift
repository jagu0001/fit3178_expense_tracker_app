//
//  ExpenseImageViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/6/21.
//

import UIKit

class ExpenseImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var filename: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImageData()
    }
    
    func loadImageData() {
        let paths = FileManager.default.urls(for: .documentDirectory,
         in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        let imageURL = documentsDirectory.appendingPathComponent(filename!)
        let image = UIImage(contentsOfFile: imageURL.path)
        
        // Set image in imageView
        imageView.image = image
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
