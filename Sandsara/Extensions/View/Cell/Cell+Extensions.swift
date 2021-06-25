//
//  Cell+Extensions.swift
//  Sandsara
//
//  Created by Tín Phan on 22/11/2020.
//

import UIKit

extension UITableViewCell {
    /// Returns the String describing self.
    static var identifier: String { return String(describing: self) }
    /// Returns the UINib with nibName matching the cell's identifier.
    static var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
}

extension UICollectionViewCell {
    /// Returns the String describing self.
    static var identifier: String { return String(describing: self) }
    /// Returns the UINib with nibName matching the cell's identifier.
    static var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
}


@IBDesignable extension UITableViewCell {
    @IBInspectable var selectedColor: UIColor? {
        get { return selectedBackgroundView?.backgroundColor }
        set {
            if let color = newValue {
                selectedBackgroundView = UIView()
                selectedBackgroundView?.backgroundColor = color
            } else {
                selectedBackgroundView = nil
            }
        }
    }
}

extension UITableViewHeaderFooterView {
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }

    func backgroundView(color: UIColor) {
        let bgView = UIView(frame: self.bounds)
        bgView.backgroundColor = color
        insertSubview(bgView, at: 0)
    }
}

extension UIColor {
    convenience init(hexFromString: String, alpha: CGFloat = 1.0) {
        var cString: String = hexFromString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue: UInt32 = 10066329 //color #999999 if string has wrong format

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) == 6) {
            Scanner(string: cString).scanHexInt32(&rgbValue)
        }

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
