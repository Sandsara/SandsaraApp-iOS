//
//  UIColor+Temperature.swift
//  Sandsara
//
//  Created by Tín Phan on 07/12/2020.
//

import Foundation
import UIKit

/*

 Algorithm taken from Tanner Helland's post: http://www.tannerhelland.com/4435/convert-temperature-rgb-algorithm-code/

 */

extension UIColor
{
    
    /// Generate color from color temp
    /// - Parameter temperature: Tempature to generate color
    convenience init(temperature : CGFloat)
    {
        let red, green, blue : CGFloat

        let percentKelvin = temperature / 100;

        red = clamp(value: percentKelvin <= 66 ? 255 : (329.698727446 * pow(percentKelvin - 60, -0.1332047592)));

        green = clamp(value: percentKelvin <= 66 ? (99.4708025861 * log(percentKelvin) - 161.1195681661) : 288.1221695283 * pow(percentKelvin, -0.0755148492));

        blue = clamp(value: percentKelvin >= 66 ? 255 : (percentKelvin <= 19 ? 0 : 138.5177312231 * log(percentKelvin - 10) - 305.0447927307));

        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
}

private func clamp (value : CGFloat) -> CGFloat
{
    return value > 255 ? 255 : (value < 0 ? 0 : value);
}
