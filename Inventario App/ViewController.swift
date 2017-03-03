//
//  ViewController.swift
//  Inventario App
//
//  Created by Ramses Miramontes Meza on 02/02/17.
//  Copyright © 2017 Ramses Miramontes Meza. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var lightButton: UIButton!
    @IBOutlet weak var CodeLabel: UILabel!
    @IBOutlet weak var ScanView: UIView!
    var audioPlayer = AVAudioPlayer()
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var CodeFrameView:UIView?
    var Data:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set audio file
        let beepSound = Bundle.main.path(forResource: "beep", ofType: "mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: beepSound! ))
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch{
            print(error)
        }
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code]
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession?.startRunning()
        
        // Move the message label to the top view
        view.bringSubview(toFront: CodeLabel)
        view.bringSubview(toFront: lightButton)
        
        // Initialize Code Frame to highlight the code
        CodeFrameView = UIView()
        CodeFrameView?.layer.borderColor = UIColor.green.cgColor
        CodeFrameView?.layer.borderWidth = 2
        view.addSubview(CodeFrameView!)
        view.bringSubview(toFront: CodeFrameView!)
    }
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            CodeFrameView?.frame = CGRect.zero
            CodeLabel.text = "Escanea el Codigo"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeEAN13Code {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            
            let CodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            CodeFrameView?.frame = CodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                captureSession?.stopRunning()
                CodeLabel.text = metadataObj.stringValue
                audioPlayer.play()
                let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
                if (device?.hasTorch)! {
                    do {
                        try device?.lockForConfiguration()
                        if (device?.torchMode == AVCaptureTorchMode.on) {
                            device?.torchMode = AVCaptureTorchMode.off
                            self.lightButton.setTitle("Encender Luz", for: .normal)
                        }
                        device?.unlockForConfiguration()
                    } catch {
                        print(error)
                    }
                }
                self.performSegue(withIdentifier: "detallesSegue", sender: self)
                //qrData=metadataObj.stringValue
            }
        }
    }
    
    @IBAction func lightButton(_ sender: Any) {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureTorchMode.on) {
                    device?.torchMode = AVCaptureTorchMode.off
                    self.lightButton.setTitle("Encender Luz", for: .normal)
                } else {
                    try device?.setTorchModeOnWithLevel(1.0)
                    self.lightButton.setTitle("Apagar Luz", for: .normal)
                }
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
        
    }
 
    override func viewWillAppear(_ animated: Bool) {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureTorchMode.on) {
                    self.lightButton.setTitle("Apagar Luz", for: .normal)
                } else {
                    self.lightButton.setTitle("Encender Luz", for: .normal)
                }
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
        captureSession?.startRunning()
        super.viewWillAppear(animated)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detallesSegue" {
            let vc : CodigoDetallesViewController = segue.destination as! CodigoDetallesViewController
            vc.codigo = CodeLabel.text
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

