//
//  ViewController.swift
//  SmartCamera
//
//  Created by Alejandro on 21/05/18.
//  Copyright © 2018 com.Alejandro. All rights reserved.
//
//

import UIKit
import CoreML
import Vision
import AVFoundation
import Accelerate


struct Box {
    let x : Double
    let y : Double
    let width : Double
    let height : Double
    let objClass : Double
    var probability : Double
}
class ViewControllerCamara: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var mP: UILabel!
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var frameLabel: UILabel!
    
    let semaphore = DispatchSemaphore(value: 1)
    var labelNames : [String] = []
    var colores : [UIColor] = []
    var lastExecution = Date()
    var screenHeight: Double?
    var screenWidth: Double?
    
    //    IMPORTANT CHANGE ME TO THE CORRECT NUMBER OF CLASSES
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
        self.cameraView?.layer.addSublayer(self.cameraLayer)
        self.cameraView?.bringSubviewToFront(self.frameLabel)
        self.frameLabel.textAlignment = .left
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)
        self.captureSession.startRunning()
        setupVision()
        
        setupBoxes()
        
        screenWidth = Double(view.frame.width)
        screenHeight = Double(view.frame.height)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraLayer.frame = cameraView.layer.bounds
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
        self.cameraLayer.frame = self.cameraView?.bounds ?? .zero
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
 
        
        
        DispatchQueue.main.async {
            
            self.frameLabel.text = "FPS: \(framesPerSecond.format(f: ".3"))"
        }
        
        let predictions = self.ssdPostProcessor.postprocess(boxPredictions: boxPredictions, classPredictions: classPredictions)
        return predictions
    }
    
    func drawBoxes(predictions: [Prediction]) {
        
        for (index, prediction) in predictions.enumerated() {
            print(prediction)
            print(index)
            if let classNames = self.ssdPostProcessor.classNames {
                print("Class: \(classNames[prediction.detectedClass])")
                if(classNames[prediction.detectedClass].count != 0)
                {
                    self.mP.text = classNames[prediction.detectedClass]
                }else
                {
                    self.mP.text = "..."
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
    
   
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let tabber = tabBarController as! Tabulador
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
        
        var requestOptions:[VNImageOption : Any] = [:]
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics:cameraIntrinsicData]
        }
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(EXIFOrientation.rightTop.rawValue))
        
        let trackingRequest = VNCoreMLRequest(model: self.visionModel!) { (request, error) in
        
            guard let predictions = self.processClassifications(for: request, error: error) else { return }
            DispatchQueue.main.async {
                self.drawBoxes(predictions: predictions)
              //  print(predictions)
            }
            self.semaphore.signal()
        }
        trackingRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        
        
        self.semaphore.wait()
        do {
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation!, options: requestOptions)
            try imageRequestHandler.perform([trackingRequest])
        } catch {
            print(error)
            self.semaphore.signal()
            
        }
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
    
    public static func softmax2(_ x: [Double]) -> [Double] {
        var x:[Float] = x.flatMap{Float($0)}
        let len = vDSP_Length(x.count)
        
        // Find the maximum value in the input array.
        var max: Float = 0
        vDSP_maxv(x, 1, &max, len)
        
        // Subtract the maximum from all the elements in the array.
        // Now the highest value in the array is 0.
        max = -max
        vDSP_vsadd(x, 1, &max, &x, 1, len)
        
        // Exponentiate all the elements in the array.
        var count = Int32(x.count)
        vvexpf(&x, x, &count)
        
        // Compute the sum of all exponentiated values.
        var sum: Float = 0
        vDSP_sve(x, 1, &sum, len)
        
        // Divide each element by the sum. This normalizes the array contents
        // so that they all add up to 1.
        vDSP_vsdiv(x, 1, &sum, &x, 1, len)
        
        let y:[Double] = x.flatMap{Double($0)}
        return y
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
    @IBAction func foto(_ sender: Any) {
        if(self.captureSession.isRunning)
        {
            self.captureSession.stopRunning()
        }else
        {
            self.captureSession.startRunning()
        }
    }
    
}
    
    

