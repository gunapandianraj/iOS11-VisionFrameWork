//
//  ViewController.swift
//  VisionImageRequests
//
//  Created by Gunapandian on 25/06/17.
//  Copyright © 2017 Gunapandian. All rights reserved.
//

import UIKit
import Vision
import ImageIO

class ViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate  {

    //MARK - Variables
    @IBOutlet weak var originalImageView: UIImageView!
    @IBOutlet weak var analyzedImageView: UIImageView!
    @IBOutlet weak var loadingLbl: UILabel!
    
    var imageToAnalyis : CIImage?
    
    lazy var rectangleBoxRequest: VNDetectRectanglesRequest = {
        return VNDetectRectanglesRequest(completionHandler:self.handleRectangles)
    }()
    
    lazy var textRectangleRequest: VNDetectTextRectanglesRequest = {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.handleTextIdentifiaction)
        textRequest.reportCharacterBoxes = true
        return textRequest
    }()
    
    lazy var faceDetectionRequest : VNDetectFaceRectanglesRequest = {
        let faceRequest = VNDetectFaceRectanglesRequest(completionHandler:self.handleFaceDetection)
        return faceRequest
    }()
    
    
    //MARK - Action Methods
    @IBAction func addPhotos(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    
    //MARK - UIImage Picker Delegate Method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        
        guard let uiImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            else { fatalError("no image from image picker") }
        guard let ciImage = CIImage(image: uiImage)
            else { fatalError("can't create CIImage from UIImage") }
        
        imageToAnalyis = ciImage.applyingOrientation(Int32(uiImage.imageOrientation.rawValue))
        
        // Show the image in the UI.
        originalImageView.image = uiImage
        
        // Create vision image request
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: Int32(uiImage.imageOrientation.rawValue))
            self.loadingLbl.isHidden = false
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                //Try performing Individual request
                
//                 try handler.perform([self.rectangleBoxRequest])
//                 try handler.perform([self.textRectangleRequest])
//                 try handler.perform([self.faceDetectionRequest])
//                 try handler.perform([self.faceLandMarkRequest])
                
                //Stack Vision Request
                try handler.perform([self.textRectangleRequest,self.faceDetectionRequest,self.rectangleBoxRequest])
                
            } catch {
                print(error)
            }
        }
    }
    
    
    //MARK - Instance Methods
    func CreateBoxView(withColor : UIColor) -> UIView {
        let view = UIView()
        view.layer.borderColor = withColor.cgColor
        view.layer.borderWidth = 2
        view.backgroundColor = UIColor.clear
        return view
    }
    
    
    //Convert Vision Frame to UIKit Frame
    func transformRect(fromRect: CGRect , toViewRect :UIView) -> CGRect {
        
        var toRect = CGRect()
        toRect.size.width = fromRect.size.width * toViewRect.frame.size.width
        toRect.size.height = fromRect.size.height * toViewRect.frame.size.height
        toRect.origin.y =  (toViewRect.frame.height) - (toViewRect.frame.height * fromRect.origin.y )
        toRect.origin.y  = toRect.origin.y -  toRect.size.height
        toRect.origin.x =  fromRect.origin.x * toViewRect.frame.size.width
        
        return toRect
    }
    
    
    
    
    //MARK - Handle Vision Requests
    
    func handleTextIdentifiaction (request: VNRequest, error: Error?) {
        
        guard let observations = request.results as? [VNTextObservation]
            else { print("unexpected result type from VNTextObservation")
                return
            }
        guard observations.first != nil else {
            return
        }
        DispatchQueue.main.async {
            self.analyzedImageView.subviews.forEach({ (s) in
                s.removeFromSuperview()
            })
            for box in observations {
                guard let chars = box.characterBoxes else {
                    print("no char values found")
                    return
                }
                for char in chars
                {
                    let view = self.CreateBoxView(withColor: UIColor.green)
                    view.frame = self.transformRect(fromRect: char.boundingBox, toViewRect: self.analyzedImageView)
                    self.analyzedImageView.image = self.originalImageView.image
                    self.analyzedImageView.addSubview(view)
                    self.loadingLbl.isHidden = true
                }
            }
        }
        
    }
    
    
    func handleFaceDetection (request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNFaceObservation]
            else { print("unexpected result type from VNFaceObservation")
                return }
        guard observations.first != nil else {
            return
        }
        // Show the pre-processed image
        DispatchQueue.main.async {
            self.analyzedImageView.subviews.forEach({ (s) in
                s.removeFromSuperview()
            })
            for face in observations
            {
                let view = self.CreateBoxView(withColor: UIColor.red)
                view.frame = self.transformRect(fromRect: face.boundingBox, toViewRect: self.analyzedImageView)
                self.analyzedImageView.image = self.originalImageView.image
                self.analyzedImageView.addSubview(view)
                self.loadingLbl.isHidden = true
                
            }
        }
    }
    
    
    func handleRectangles(request: VNRequest, error: Error?) {
        
        guard let observations = request.results as? [VNRectangleObservation]
            else { print("unexpected result type from VNDetectRectanglesRequest")
                    return
        }
        guard observations.first != nil else {
            return
        }
        // Show the pre-processed image
        DispatchQueue.main.async {
            self.analyzedImageView.subviews.forEach({ (s) in
                s.removeFromSuperview()
            })
            for rect in observations
            {
                let view = self.CreateBoxView(withColor: UIColor.cyan)
                view.frame = self.transformRect(fromRect: rect.boundingBox, toViewRect: self.analyzedImageView)
                self.analyzedImageView.image = self.originalImageView.image
                self.analyzedImageView.addSubview(view)
                self.loadingLbl.isHidden = true
            }
        }
    }
    
    
    
    

}

