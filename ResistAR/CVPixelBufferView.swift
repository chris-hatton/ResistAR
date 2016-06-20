//
//  CVPixelBufferView.swift
//  ResistAR
//
//  Created by Christopher Hatton on 26/09/2014.
//  Copyright (c) 2014 AppDelegate. All rights reserved.
//

import Foundation
import UIKit

class CVPixelBufferView : UIView
{
    var pixelBuffer : CVPixelBuffer? = nil
    {
        willSet
        {
            if newValue != nil
            {
                assert( CVPixelBufferGetPixelFormatType(newValue!) == OSType(kCVPixelFormatType_32BGRA), "\(self.dynamicType) only supports kCVPixelFormatType_32BGRA formatted CVPixelBuffers")
            }
        }
        
        didSet
        {
            if pixelBuffer != nil
            {
                width  = UInt( CVPixelBufferGetWidth (pixelBuffer!) )
                height = UInt( CVPixelBufferGetHeight(pixelBuffer!) )
            
                self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: CGFloat(width), height: CGFloat(height))
            }
        }
    }
    
    private var
        width  : UInt = 0,
        height : UInt = 0
    
    override func draw(_ rect: CGRect)
    {
        if pixelBuffer != nil
        {
            let
                context     = UIGraphicsGetCurrentContext(),
                contextData = context?.data,
                pixelData   = CVPixelBufferGetBaseAddress(pixelBuffer!)
            
            CVPixelBufferLockBaseAddress(pixelBuffer!, 0)
            memcpy(contextData, pixelData, Int( 4 * width * height ) )
            CVPixelBufferUnlockBaseAddress(pixelBuffer!, 0)
        }
    }
}
