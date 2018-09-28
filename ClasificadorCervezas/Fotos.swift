//
//  Fotos.swift
//  ClasificadorCervezas
//
//  Created by Alejandro on 9/27/18.
//  Copyright © 2018 com.AlexStudios. ClasificadorCervezas. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class Fotos: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate
{


    
    let semaphore = DispatchSemaphore(value: 1)
    var labelNames : [String] = []
    var colores : [UIColor] = []
    var lastExecution = Date()
    var screenHeight: Double?
     let imagePicker = UIImagePickerController()
    var screenWidth: Double?
    
    @IBOutlet weak var imagen: UIImageView!
   let ssdPostProcessor = SSDPostProcessor(numAnchors: 1917, numClasses: 13)
    var visionModel:VNCoreMLModel?
    
    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.hd1280x720
        
        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera)
            else { return session }
        session.addInput(input)
        return session
    }()
    
    let numBoxes = 100
    var boundingBoxes: [BoundingBox] = []
    let multiClass = true
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let path = Bundle.main.path(forResource: "labels", ofType: "txt") // file path for file "data.txt"
        
        do {
            // Read an entire text file into an NSString.
            let contents = try NSString(contentsOfFile: path ?? "",
                                        encoding: String.Encoding.ascii.rawValue)
            
            // Print all lines.
            contents.enumerateLines({ (line, stop) -> () in
                self.labelNames.append(line)
            })
        }catch
        {
            
        }
        
        for i in labelNames
        {
            let red = CGFloat.random(in: 0..<255)
            let green = CGFloat.random(in: 0..<255)
            let blue = CGFloat.random(in: 0..<255)
            
            let color = UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 0.9)
            colores.append(color)
            
        }
        self.view.backgroundColor = UIColor.black

//        self.cameraView?.bringSubviewToFront(self.frameLabel)
//        self.frameLabel.textAlignment = .left
//        let videoOutput = AVCaptureVideoDataOutput()
//        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
//        self.captureSession.addOutput(videoOutput)
//        self.captureSession.startRunning()
        setupVision()
        
        setupBoxes()
        
        screenWidth = Double(view.frame.width)
        screenHeight = Double(view.frame.height)
       
        imagePicker.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    func setupVision() {
        
        let tabber  = tabBarController as! Tabulador
        
        print(tabber.model)
        
        switch tabber.model {
        case "ssd_mobilenet.mlmodel":
            guard let visionModel = try? VNCoreMLModel(for: ssd_mobilenet().model)
                else { fatalError("Can't load VisionML model") }
            self.visionModel = visionModel
            break
        case "ssd_mobilenet_2.mlmodel":
            guard let visionModel = try? VNCoreMLModel(for: ssd_mobilenet_2().model)
                else { fatalError("Can't load VisionML model") }
            self.visionModel = visionModel
            break
        case "ssd_mobilenet_3.mlmodel":
            guard let visionModel = try? VNCoreMLModel(for: ssd_mobilenet_3().model)
                else { fatalError("Can't load VisionML model") }
            self.visionModel = visionModel
            break
        case "ssd_mobilenet_4.mlmodel":
            guard let visionModel = try? VNCoreMLModel(for: ssd_mobilenet_4().model)
                else { fatalError("Can't load VisionML model") }
            self.visionModel = visionModel
            break
        case "ssd_mobilenet_5.mlmodel":
            guard let visionModel = try? VNCoreMLModel(for: ssd_mobilenet_5().model)
                else { fatalError("Can't load VisionML model") }
            self.visionModel = visionModel
            break
        case "ssd_mobilenet_6.mlmodel":
            guard let visionModel = try? VNCoreMLModel(for: ssd_mobilenet_6().model)
                else { fatalError("Can't load VisionML model") }
            self.visionModel = visionModel
            break
        case "ssd_mobilenet_7.mlmodel":
            guard let visionModel = try? VNCoreMLModel(for: ssd_mobilenet_7().model)
                else { fatalError("Can't load VisionML model") }
            self.visionModel = visionModel
            break
        case "ssd_mobilenet_8.mlmodel":
            guard let visionModel = try? VNCoreMLModel(for: ssd_mobilenet_8().model)
                else { fatalError("Can't load VisionML model") }
            self.visionModel = visionModel
            break
        case "ssd_mobilenet_9.mlmodel":
            guard let visionModel = try? VNCoreMLModel(for: ssd_mobilenet_9().model)
                else { fatalError("Can't load VisionML model") }
            self.visionModel = visionModel
            break
            
        default:
            guard let visionModel = try? VNCoreMLModel(for: ssd_mobilenet_4().model)
                else { fatalError("Can't load VisionML model") }
            self.visionModel = visionModel
            break
        }
         print(visionModel?.description)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

            picker.dismiss(animated: true)
        
        
        print("did cancel")
    }
    
    
    @IBAction func take(_ sender: Any) {
       
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
        
            imagePicker.delegate = self
           
            imagen.contentMode = .scaleToFill
            imagen.image = pickedImage
              var requestOptions:[VNImageOption : Any] = [:]
            let tabber  = tabBarController as! Tabulador
            
        
            
//            switch tabber.model {
//            case "ssd_mobilenet.mlmodel":
//                guard let model = try? VNCoreMLModel(for: ssd_mobilenet().model)
//                    else { fatalError("Can't load VisionML model") }
//
//                break
//            case "ssd_mobilenet_2.mlmodel":
//                guard let model = try? VNCoreMLModel(for: ssd_mobilenet_2().model)
//                    else { fatalError("Can't load VisionML model") }
//
//                break
//            case "ssd_mobilenet_3.mlmodel":
//                guard let model = try? VNCoreMLModel(for: ssd_mobilenet_3().model)
//                    else { fatalError("Can't load VisionML model") }
//
//                break
//            case "ssd_mobilenet_4.mlmodel":
//                guard let model = try? VNCoreMLModel(for: ssd_mobilenet_4().model)
//                    else { fatalError("Can't load VisionML model") }
//
//                break
//            case "ssd_mobilenet_5.mlmodel":
//                guard let model = try? VNCoreMLModel(for: ssd_mobilenet_5().model)
//                    else { fatalError("Can't load VisionML model") }
//
//                break
//            case "ssd_mobilenet_6.mlmodel":
//                guard let model = try? VNCoreMLModel(for: ssd_mobilenet_6().model)
//                    else { fatalError("Can't load VisionML model") }
//
//                break
//            case "ssd_mobilenet_7.mlmodel":
//                guard let model = try? VNCoreMLModel(for: ssd_mobilenet_7().model)
//                    else { fatalError("Can't load VisionML model") }
//
//                break
//            case "ssd_mobilenet_8.mlmodel":
//                guard let model = try? VNCoreMLModel(for: ssd_mobilenet_8().model)
//                    else { fatalError("Can't load VisionML model") }
//
//                break
//
//            default:
//                guard let model = try? VNCoreMLModel(for: ssd_mobilenet_4().model)
//                    else { fatalError("Can't load VisionML model") }
//
//                break
//            }
           
            
          
            
          
             print(visionModel?.description)
            let request = VNCoreMLRequest(model: self.visionModel!, completionHandler: { [weak self] request, error in
                guard let predictions = self?.processClassifications(for: request, error: error) else { return }
                print(predictions)
                self?.drawBoxes(predictions: predictions)
              
                
            })
          
            guard let ciImage = CIImage(image: pickedImage)
            else
            {
                fatalError("No puedo leer la imagen")
            }
            request.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
            
            self.semaphore.wait()
            do {
                let imageRequestHandler = VNImageRequestHandler(cgImage: convertCIImageToCGImage(inputImage: ciImage), options: requestOptions)
                try imageRequestHandler.perform([request])
            } catch {
                print(error)
                self.semaphore.signal()
                
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func drawBoxes(predictions: [Prediction]) {
        
        for (index, prediction) in predictions.enumerated() {
           
            if let classNames = self.ssdPostProcessor.classNames {
                print("Class: \(classNames[prediction.detectedClass])")
                if(classNames[prediction.detectedClass].count != 0)
                {
                   
                }else
                {
                 
                }
                
                
                let textColor: UIColor
                let textLabel = String(format: "%.2f - %@", self.sigmoid(prediction.score), classNames[prediction.detectedClass])
                
                textColor = UIColor.black
                let rect = prediction.finalPrediction.toCGRect(imgWidth: self.screenWidth!, imgHeight: self.screenWidth!, xOffset: 0, yOffset: (self.screenHeight! - self.screenWidth!)/2)
                
                self.boundingBoxes[index].show(frame: rect,
                                               label: textLabel,
                                               color: UIColor.red, textColor: textColor, colors : colores, names: labelNames)
            }
            
        }
        for index in predictions.count..<self.numBoxes {
            self.boundingBoxes[index].hide()
        }
    }
    
    @IBAction func foto(_ sender: Any) {
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    func setupBoxes() {
        // Create shape layers for the bounding boxes.
        for _ in 0..<numBoxes {
            let box = BoundingBox()
            box.addToLayer(view.layer)
            self.boundingBoxes.append(box)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
      
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    func processClassifications(for request: VNRequest, error: Error?) -> [Prediction]? {
        let thisExecution = Date()
        let executionTime = thisExecution.timeIntervalSince(lastExecution)
        let framesPerSecond:Double = 1/executionTime
        lastExecution = thisExecution
        guard let results = request.results as? [VNCoreMLFeatureValueObservation] else {
            return nil
        }
        //        print(results.count)
        guard results.count == 2 else {
            return nil
        }
        
        guard let boxPredictions = results[1].featureValue.multiArrayValue,
            let classPredictions = results[0].featureValue.multiArrayValue else {
                return nil
        }
        
        
       
        
        let predictions = self.ssdPostProcessor.postprocess(boxPredictions: boxPredictions, classPredictions: classPredictions)
        return predictions
    }
    
    @IBAction func opciones(_ sender: Any) {
        let action = UIAlertController(title: "Opciones", message: nil, preferredStyle: .actionSheet)
        let take = UIAlertAction(title: "Tomar foto", style: .default, handler: ( {(UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
            {
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
                
            }
        }))
        let library = UIAlertAction(title: "Carrete", style: .default, handler: ( {(UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)
            {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                imagePicker.allowsEditing = false
                self.present(imagePicker,animated: true, completion:  nil)
            }
        }))
        
        
        let borrar = UIAlertAction(title: "Borrar foto", style: .destructive, handler: ( {(UIAlertAction) in
           self.imagen.image = nil
        }))
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        action.addAction(take)
        action.addAction(library)
        action.addAction(borrar)
        action.addAction(cancel)
        
        self.present(action, animated: true, completion: nil)
    }
    
//    func drawBoxes(predictions: [Prediction]) {
//
//        for (index, prediction) in predictions.enumerated() {
//            print(prediction)
//            print(index)
//            if let classNames = self.ssdPostProcessor.classNames {
//                print("Class: \(classNames[prediction.detectedClass])")
////                if(classNames[prediction.detectedClass].count != 0)
////                {
////                    self.mP.text = classNames[prediction.detectedClass]
////                }else
////                {
////                    self.mP.text = "..."
////                }
//
//
//                let textColor: UIColor
//                let textLabel = String(format: "%.2f - %@", self.sigmoid(prediction.score), classNames[prediction.detectedClass])
//
//                textColor = UIColor.black
//                let rect = prediction.finalPrediction.toCGRect(imgWidth: self.screenWidth!, imgHeight: self.screenWidth!, xOffset: 0, yOffset: (self.screenHeight! - self.screenWidth!)/2)
//
//                self.boundingBoxes[index].show(frame: rect,
//                                               label: textLabel,
//                                               color: UIColor.red, textColor: textColor, colors : colores, names: labelNames)
//            }
//
//        }
//        for index in predictions.count..<self.numBoxes {
//            self.boundingBoxes[index].hide()
//        }
//    }
//
    
    
    @IBAction func borrar(_ sender: Any) {
        self.imagen.image = nil
    }
    func sigmoid(_ val:Double) -> Double {
        return 1.0/(1.0 + exp(-val))
    }
    
    func softmax(_ values:[Double]) -> [Double] {
        if values.count == 1 { return [1.0]}
        guard let maxValue = values.max() else {
            fatalError("Softmax error")
        }
        let expValues = values.map { exp($0 - maxValue)}
        let expSum = expValues.reduce(0, +)
        return expValues.map({$0/expSum})
    }
    
    
    
    enum EXIFOrientation : Int32 {
        case topLeft = 1
        case topRight
        case bottomRight
        case bottomLeft
        case leftTop
        case rightTop
        case rightBottom
        case leftBottom
        
        var isReflect:Bool {
            switch self {
            case .topLeft,.bottomRight,.rightTop,.leftBottom: return false
            default: return true
            }
        }
    }
    
    
    func compensatingEXIFOrientation(deviceOrientation:UIDeviceOrientation) -> EXIFOrientation
    {
        switch (deviceOrientation) {
        case (.landscapeRight): return .bottomRight
        case (.landscapeLeft): return .topLeft
        case (.portrait): return .rightTop
        case (.portraitUpsideDown): return .leftBottom
            
        case (.faceUp): return .rightTop
        case (.faceDown): return .rightTop
        case (_): fallthrough
        default:
            NSLog("Called in unrecognized orientation")
            
            return .rightTop
        }
    }
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        if context != nil {
            return context.createCGImage(inputImage, from: inputImage.extent)
        }
        return nil
    }
 
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    
}
