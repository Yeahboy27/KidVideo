//
//  Extension + UIColor.swift
//  Youtube
//
//  Created by MAC on 8/27/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit

extension UIColor {
    var redValue: CGFloat {
        return CIColor(color: self).red
    }
    var greenValue: CGFloat {
        return CIColor(color: self).green
    }
    var blueValue: CGFloat {
        return CIColor(color: self).blue
    }
    var alphaValue: CGFloat {
        return CIColor(color: self).alpha
    }
}

extension UIColor {
    public convenience init?(hexString: String) {
        var cString:String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.characters.count) != 6) {
            return nil
        }
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: CGFloat(1.0))
    }
}
