//
//  ColorSpace.swift
//  ResistAR
//
//  Created by Christopher Hatton on 06/09/2014.
//  Copyright (c) 2014 AppDelegate. All rights reserved.
//

import Foundation

func RGBtoHSV(rgb: RGBPixel) -> HSBPixel
{
    let
        r     : Double = rgb.red,
        g     : Double = rgb.green,
        b     : Double = rgb.blue
    
    var
        min   : Double,
        max   : Double,
        delta : Double,

        h     : Double,
        s     : Double,
        v     : Double
    
    min = r   < g ? r   : g
    min = min < b ? min : b
    
    max = r   > g ? r   : g
    max = max > b ? max : b
    
    v = max
    delta = max - min

    if( max > 0.0 )
    {
        s = delta / max
    }
    else
    {
        s = 0.0
        h = Double.NaN
    }
    
    if( r == max )
    {
        h = ( g - b ) / delta // between yellow & magenta
    }
    else if( g >= max )
    {
        h = 2.0 + ( b - r ) / delta // between cyan & yellow
    }
    else
    {
        h = 4.0 + ( r - g ) / delta // between magenta & cyan
    }
    
    h *= 60.0 // degrees
    
    if( h < 0.0 )
    {
        h += 360.0
    }
    
    return (h,s,v)
}
