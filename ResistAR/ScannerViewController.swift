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

class ScannerViewController: UIViewController
{
    let
        captureSession       : AVCaptureSession,
        sampleQueue          : dispatch_queue_t,
        sampleBufferDelegate : AVCaptureVideoDataOutputSampleBufferDelegate
    
    @IBOutlet
    var previewLayerView : UIView?
    
    @IBOutlet
    var cutoutImageView : UIImageView?
    
    required init(coder: NSCoder)
    {
        self.captureSession       = AVCaptureSession()
        self.sampleQueue          = dispatch_queue_create("ImageProcessQueue",nil)
        self.sampleBufferDelegate = SampleBufferDelegate()
        
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
        print("Starting... ");
        
        var error : NSErrorPointer = nil
        
        let
            captureDevice      = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo),
            captureDeviceInput = AVCaptureDeviceInput(device:captureDevice, error:error),
            videoDataOutput    = AVCaptureVideoDataOutput()
        
        if captureSession.canAddInput(captureDeviceInput)
        {
            captureSession.addInput(captureDeviceInput)
            captureSession.addOutput(videoDataOutput)
            
            let previewLayer = AVCaptureVideoPreviewLayer(session:captureSession)
            previewLayer.frame = previewLayerView!.bounds
            previewLayer.contentsScale = 0.5
            previewLayerView!.layer.addSublayer(previewLayer)
            
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [ kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA ]
            videoDataOutput.setSampleBufferDelegate(sampleBufferDelegate, queue:sampleQueue)
            
            captureSession.sessionPreset = AVCaptureSessionPreset640x480
            captureSession.startRunning()
            
            println("Started");
        }
        else
        {
            println("Failed");
        }
    }
    
    
    
    class SampleBufferDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate
    {
        func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!)
        {
            let
                reticuleProportionalWidth  : CGFloat = 0.2,
                reticuleProportionalHeight : CGFloat = 0.1
            
            let
                pixelBuffer    = CMSampleBufferGetImageBuffer(sampleBuffer) as CVPixelBuffer,
                originalSize   = CVImageBufferGetEncodedSize(pixelBuffer),
                reticuleWidth  = reticuleProportionalWidth  * originalSize.width,
                reticuleHeight = reticuleProportionalHeight * originalSize.height,
                reticuleSize   = CGSizeMake(reticuleWidth, reticuleHeight),
                reticuleX      = (originalSize.width  - reticuleWidth )/2,
                reticuleY      = (originalSize.height - reticuleHeight)/2
            
            let croppedBuffer = pixelBuffer.createCropped(UInt(reticuleX), cropY0: UInt(reticuleY), cropHeight: UInt(reticuleHeight), cropWidth: UInt(reticuleWidth))
            
            if(croppedBuffer)
            {
                pixelBuffer.getHSBArea(<#startX: UInt#>, startY: <#UInt#>, width: <#UInt#>, height: <#UInt#>)
            }
            else
            {
                println("Buffer failed to crop")
            }
        }
    }
}

