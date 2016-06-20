//
//  ViewController.swift
//  ResistAR
//
//  Created by Christopher Hatton on 18/08/2014.
//  Copyright (c) 2014 AppDelegate. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia

class ScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate
{
    let
        captureSession : AVCaptureSession,
        sampleQueue    : DispatchQueue
    
    @IBOutlet
    var cameraPreview : UIView?
    
    @IBOutlet
    var pixelBufferView : CVPixelBufferView?
    
    required init?(coder: NSCoder)
    {
        self.captureSession       = AVCaptureSession()
        self.sampleQueue          = DispatchQueue(label: "ImageProcessQueue",attributes: [])
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction
    func start()
    {
        print("Starting... ")
        
        let
            captureDevice      = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo),
            captureDeviceInput = try! AVCaptureDeviceInput(device:captureDevice),
            videoDataOutput    = AVCaptureVideoDataOutput()
        
        
        if captureSession.canAddInput(captureDeviceInput)
        {
            captureSession.addInput(captureDeviceInput)
            captureSession.addOutput(videoDataOutput)
            
            let previewLayer = AVCaptureVideoPreviewLayer(session:captureSession)
            previewLayer?.frame = cameraPreview!.bounds
            previewLayer?.contentsScale = 0.5
            cameraPreview!.layer.addSublayer(previewLayer!)
            
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            
            
            let videoSettings = [ kCVPixelBufferPixelFormatTypeKey as NSString : Int( kCVPixelFormatType_32BGRA ) ]
            videoDataOutput.videoSettings = videoSettings
            videoDataOutput.setSampleBufferDelegate(self, queue:sampleQueue)
            
            captureSession.sessionPreset = AVCaptureSessionPreset640x480
            captureSession.startRunning()
            
            print("Started");
        }
        else
        {
            print("Failed");
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!)
    {
        let
            reticuleProportionalWidth  : CGFloat = 0.2,
            reticuleProportionalHeight : CGFloat = 0.1

        let
            pixelBuffer    = CMSampleBufferGetImageBuffer(sampleBuffer)! as CVPixelBuffer,
            originalSize   = CVImageBufferGetEncodedSize(pixelBuffer),
            reticuleWidth  = reticuleProportionalWidth  * originalSize.width,
            reticuleHeight = reticuleProportionalHeight * originalSize.height,
            reticuleX      = (originalSize.width  - reticuleWidth )/2,
            reticuleY      = (originalSize.height - reticuleHeight)/2

        let croppedBuffer = pixelBuffer.cropArea(
            x:      Int(reticuleX),
            y:      Int(reticuleY),
            height: Int(reticuleHeight),
            width:  Int(reticuleWidth)
        )
        
        assert(croppedBuffer != nil, "Buffer failed to crop")
        
        pixelBufferView!.pixelBuffer = croppedBuffer
    }
}

