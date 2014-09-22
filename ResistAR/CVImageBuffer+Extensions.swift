//
//  CVImageBufferRef+Extensions.swift
//  ResistAR
//
//  Created by Christopher Hatton on 06/09/2014.
//  Copyright (c) 2014 AppDelegate. All rights reserved.
//

import Foundation
import CoreMedia
import CoreImage
import Accelerate

extension CVImageBuffer
{
    func getRGB(x: UInt, y: UInt) -> RGBPixel
    {
        assert( Int(CVPixelBufferGetPixelFormatType(self) ) == kCVPixelFormatType_32BGRA, "This function supports only 32BGRA formatted buffers")

        CVPixelBufferLockBaseAddress(self,0);

        let
            baseAddress   = CVPixelBufferGetBaseAddress(self),
            bytesPerRow   = CVPixelBufferGetBytesPerRow(self),
            width         = CVPixelBufferGetWidth(self),
            height        = CVPixelBufferGetHeight(self),
            bytesPerPixel = UInt(bytesPerRow/width)

        assert(bytesPerPixel == 4, "Expected 4 bytes per pixel")

        let
            pixelPointer = UnsafeMutablePointer<UInt8>(baseAddress),
            pixelOffset  = (y*UInt(bytesPerRow))+(x*UInt(bytesPerPixel))

        pixelPointer.advancedBy(Int(pixelOffset))
        let b = Double(pixelPointer.memory) / 255.0

        pixelPointer.advancedBy(1)
        let g = Double(pixelPointer.memory) / 255.0

        pixelPointer.advancedBy(1)
        let r = Double(pixelPointer.memory) / 255.0

        CVPixelBufferUnlockBaseAddress(self,0);

        return (r,g,b)
    }



    func getHSBArea(startX:UInt, startY:UInt, width:UInt, height:UInt) -> [[HSBPixel]]
    {
        var
            output : [[HSBPixel]] = [[HSBPixel]](),
            hsbPixel : HSBPixel

        let offset = UnsafeMutablePointer<UInt8>()
        var rgbPixel : RGBPixel
        
        for y in 0...height-1
        {
            for x in 0...(width-1)
            {
                rgbPixel = getRGB(startX+x, y: startY+y)
                
                output[Int(x)][Int(y)] = RGBtoHSV(rgbPixel)
            }
        }

        return output
    }

    func createCropped(cropX0: UInt, cropY0: UInt, cropHeight: UInt, cropWidth: UInt) -> CVPixelBuffer?
    {
        return createCroppedScaled(cropX0, cropY0: cropY0, cropHeight: cropHeight, cropWidth: cropWidth, outWidth: cropWidth, outHeight: cropHeight)
    }

    func createCroppedScaled(cropX0: UInt, cropY0: UInt, cropHeight: UInt, cropWidth: UInt, outWidth: UInt, outHeight: UInt) -> CVPixelBuffer?
    {
        assert( Int(CVPixelBufferGetPixelFormatType(self) ) == kCVPixelFormatType_32BGRA, "This function supports only 32BGRA formatted buffers")

        CVPixelBufferLockBaseAddress(self,0)

        let
            planeCount : UInt    = 4,
            baseAddress          = CVPixelBufferGetBaseAddress(self),
            bytesPerRowIn        = CVPixelBufferGetBytesPerRow(self),
            startPos             = cropY0*bytesPerRowIn+(planeCount*cropX0),
            bytesPerRowOut       = planeCount*outWidth,
            inBuff               = vImage_Buffer(data: baseAddress.advancedBy(Int(startPos)), height:cropHeight, width:cropWidth, rowBytes:bytesPerRowIn),
            outBuff              = vImage_Buffer(data: malloc(4*outWidth*outHeight),          height: outHeight, width: outWidth, rowBytes:bytesPerRowOut),
            nullPointer          = UnsafeMutablePointer<Void>(),
            flags : vImage_Flags = 0,
            imageInBufferPtr     = UnsafeMutablePointer<vImage_Buffer>(inBuff.data),
            imageOutBufferPtr    = UnsafeMutablePointer<vImage_Buffer>(outBuff.data),
            err                  = vImageScale_ARGB8888(imageInBufferPtr, imageOutBufferPtr, nil, flags)

        if (err != kvImageNoError)
        {
            println(" error %ld", err.description)
            return nil
        }
        else
        {
            var outImage : CVPixelBufferRef?
            
            let
                allocator             : CFAllocator!                                    = nil,
                width                 : UInt                                            = outWidth,
                height                : UInt                                            = outHeight,
                pixelFormatType       : OSType                                          = OSType(kCVPixelFormatType_32BGRA),
                baseAddress           : UnsafeMutablePointer<Void>                      = outBuff.data,
                bytesPerRow           : UInt                                            = size_t(bytesPerRowOut),
                releaseCallback       : CVPixelBufferReleaseBytesCallback               = nil,
                releaseRefCon         : UnsafeMutablePointer<Void>                      = nil,
                pixelBufferAttributes : CFDictionary!                                   = nil,
                pixelBufferOut        : UnsafeMutablePointer<Unmanaged<CVPixelBuffer>?> = nil
            
            CVPixelBufferCreateWithBytes(allocator,width,height,pixelFormatType,baseAddress,bytesPerRow,releaseCallback,releaseRefCon,pixelBufferAttributes,pixelBufferOut)

            return outImage
        }
    }
}