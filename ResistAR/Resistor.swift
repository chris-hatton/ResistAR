//
//  Resistor.swift
//  ResistAR
//
//  Created by Christopher Hatton on 18/08/2014.
//  Copyright (c) 2014 AppDelegate. All rights reserved.
//

import Foundation

public class Resistor
{
    enum ResistorFormatException : ErrorProtocol
    {
        case bandFormat
    }
    
    var
        value:     Int?   = nil,
        tolerance: Float? = nil
    
    private var _bands = [Band]()
    
    init()
    {
    }
    
    func bands() -> [Band]
    {
        return _bands;
    }
    
    func setBands(_ bands:[Band]) throws
    {
        try interpretBands(bands, value:&self.value, tolerance:&self.tolerance);
    }
    
    private func interpretBands(_ bands:[Band], value:inout Int?, tolerance:inout Float?) throws
    {
        let defaultTolerance : Float = 0.2
        
        switch bands.count
        {
            case 3:
            if bands[0].value == nil || bands[1].value == nil
            {
                value     = nil
                tolerance = nil
                throw ResistorFormatException.bandFormat
            }
            else
            {
                let
                    band1Value : Int = bands[0].value!,
                    band2Value : Int = bands[1].value!,
                    multiplier : Float = pow(10,(Float)(bands[2].multiplier!))
                
                value = Int( ( Float( band1Value ) * 10.0 ) + Float( band2Value ) * multiplier )
                tolerance = 0.2;
                return
            }
            
            case 4,5:
            value     = nil
            let specifiedTolerance : Float? = bands.last!.tolerance
            tolerance = specifiedTolerance ?? defaultTolerance
            throw ResistorFormatException.bandFormat
            
            default:
            value     = nil
            tolerance = nil
            throw ResistorFormatException.bandFormat
        }
    }
    
    public class Band
    {
        public let
            value:      Int?,
            multiplier: Int?,
            tolerance:  Float?
        
        init(value: Int?, multiplier:Int?, tolerance:Float?)
        {
            self.value      = value;
            self.multiplier = multiplier
            self.tolerance  = tolerance
        }
        
        let
            Black   = Band(value: 0,   multiplier: 0, tolerance: nil),
            Brown   = Band(value: 1,   multiplier: 1, tolerance: 0.01),
            Red     = Band(value: 2,   multiplier: 2, tolerance: 0.02),
            Orange  = Band(value: 3,   multiplier: 3, tolerance: nil),
            Yellow  = Band(value: 4,   multiplier: 4, tolerance: 0.05),
            Green   = Band(value: 5,   multiplier: 5, tolerance: 0.005),
            Blue    = Band(value: 6,   multiplier: 6, tolerance: 0.0025),
            Violet  = Band(value: 7,   multiplier: 7, tolerance: 0.001),
            Grey    = Band(value: 8,   multiplier: 8, tolerance: 0.1),
            White   = Band(value: 9,   multiplier: 9, tolerance: nil),
            Gold    = Band(value: nil, multiplier:-1, tolerance: 0.05),
            Silver  = Band(value: nil, multiplier:-2, tolerance: 0.1)
        
        func isValidToleranceBand() -> Bool
        {
            return self.tolerance != nil
        }
    }
}
