# iOS-Vision Framework - Intro


![N|Solid](https://media.giphy.com/media/GPyUU4Qri9o0E/giphy.gif)  ![N|Solid](https://media.giphy.com/media/5Gz3hfaC4XIaY/giphy.gif)  ![N|Solid](https://media.giphy.com/media/YOaydcsOzdxNm/giphy.gif) 

## Intro To Vision :

Vision was introduced in 2017 WWDC along with list of other machine learning frameworks apple released (Core ML,NLP).Vision  can be used on both image as well as sequences of image (videos).We can also integrate vision with Core ML Models 
for example it can used to give Core ML required input parameters example for MINST image classification we can detect numbers as rect in image using vision and send it Core ML model for prediction. Check the WWDC Video

## Vision Main Features

- Face Detection and Recognition
- Machine Learning Image Analysis
- Barcode Detection
- Image Alignment Analysis
- Text Detection
- Horizon Detection
- Object Detection and Tracking


### Project Overview

In this project we are gonna look into simple image analysis techniques like marking Rectangle objects,faces ,text boxes,Char  on texts 

For performing any image analysis operation we need follow this three step process 

- Create a Vision Image Request

- Create a Image Request Handler 

- Assigning Image Requests To Request handler

------------------
### Face Detection
------------------

![N|Solid](https://image.ibb.co/e2fV2k/Faces_1.png)                 ![N|Solid](https://image.ibb.co/bMBsF5/Faces_2.png)


- Creating face detection request

``` swift
   lazy var faceDetectionRequest : VNDetectFaceRectanglesRequest = {
        let faceRequest = VNDetectFaceRectanglesRequest(completionHandler:self.handleFaceDetection)
        return faceRequest
    }()
```

- Create a image request handler

``` swift
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: Int32(uiImage.imageOrientation.rawValue))
```

- Assigning image requests to request handler

``` swift
     try handler.perform([self.faceDetectionRequest])
```

- Handler code 

``` swift
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
```
- Converting vision rect to uikit rect

  one main thing to keep in mind that vision rect values are different from others
 
  Vision:
  origin ---> bottom left 
  
  Size   ---> Max value of 1
  
  UIkit :
  origin ---> top left 
  
  Size   ---> UIVIEW bounds
  
  ``` swift
  
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
    
  ```

- Box view

For drawing rectangle box around our detection

``` swift
      func CreateBoxView(withColor : UIColor) -> UIView {
        let view = UIView()
        view.layer.borderColor = withColor.cgColor
        view.layer.borderWidth = 2
        view.backgroundColor = UIColor.clear
        return view
    }
```


------------------
### CHAR DETECTION
------------------
![N|Solid](https://image.ibb.co/e8rsF5/Chara_1.png)                      ![N|Solid](https://image.ibb.co/mqrETQ/Chara_2.png)

- Creating char detection request

  ``` swift
        lazy var textRectangleRequest: VNDetectTextRectanglesRequest = {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.handleTextIdentifiaction)
        textRequest.reportCharacterBoxes = true
        return textRequest
    }()
  ```
- Create a image request handler

  ``` swift
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: Int32(uiImage.imageOrientation.rawValue))
  ```
- Assigning image requests to request handler

   ``` swift
        try handler.perform([self.textRectangleRequest])
   ```
- Handler code 

    ``` swift
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
     ```

 -----------------------    
 ### RECTANGLE DETECTION
 -----------------------
 
  ![N|Solid](https://image.ibb.co/dJXXF5/Rect_1.png)

 - Creating rectangle detection request

  ``` swift
         lazy var rectangleBoxRequest: VNDetectRectanglesRequest = {
        return VNDetectRectanglesRequest(completionHandler:self.handleRectangles)
    }()
  ```
- Create a image request handler 

  ``` swift
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: Int32(uiImage.imageOrientation.rawValue))
  ```
- Assigning image requests to request handler

   ``` swift
         try handler.perform([self.rectangleBoxRequest])
   ```
- Handler code 

    ``` swift
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
     ```
----------------------------------------------------
### You can also group Requests and Perform analysis
----------------------------------------------------

 ``` swift
     handler.perform([self.textRectangleRequest,self.faceDetectionRequest,self.rectangleBoxRequest])
   ```
   
   Here am performing text,face and rectangle box analysis on a single input
 
