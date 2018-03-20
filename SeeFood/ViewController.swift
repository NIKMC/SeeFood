//
//  ViewController.swift
//  SeeFood
//
//  Created by Ivan Nikitin on 20/03/2018.
//  Copyright © 2018 Иван Никитин. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {fatalError("Couldn't convert to CIImage")}
            
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
   
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {fatalError("Loading CoreML Model Failed")}
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {fatalError("model failed to process image.")}
            
            if let firstResult = results.first {
                self.navigationItem.title = "\(firstResult.identifier) \(firstResult.confidence.description)"
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
         try handler.perform([request])
        } catch {
            print("error perform request \(error)")
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    

}

