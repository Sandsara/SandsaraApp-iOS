//
//  CustomSlider.swift
//  Sandsara
//
//  Created by Tín Phan on 04/02/2021.
//

import UIKit

class CustomSlider: UISlider {
    
    private var toolTip: ToolTipPopupView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initToolTip()
    }
    
    private func initToolTip() {
        toolTip = ToolTipPopupView.init(frame: CGRect.zero)
        toolTip?.backgroundColor = UIColor.clear
        toolTip?.draw(CGRect.zero)
        self.addSubview(toolTip!)
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        
        let knobRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        
        let popupRect = knobRect.offsetBy(dx: 0, dy: -(knobRect.size.height))
        toolTip?.frame = popupRect.offsetBy(dx: 0, dy: 0)
        toolTip?.setValue(value: self.value)
        
        return knobRect
    }
}

class ToolTipPopupView: UIView {
    
    private var toolTipValue: NSString?
    
    override func draw(_ rect: CGRect) {
        
        if toolTipValue != nil {
            
            let paraStyle = NSMutableParagraphStyle.init()
            paraStyle.lineBreakMode = .byWordWrapping
            paraStyle.alignment = .center
            
            let textAttributes = [NSAttributedString.Key.font: FontFamily.OpenSans.regular.font(size: 12), NSAttributedString.Key.paragraphStyle: paraStyle, NSAttributedString.Key.foregroundColor: UIColor.white]
            
            if let s: CGSize = toolTipValue?.size(withAttributes: textAttributes) {
                let yOffset = s.height + 5
                let textRect = CGRect.init(x: self.bounds.origin.x, y: yOffset, width: self.bounds.size.width, height: s.height)
                
                
                toolTipValue?.draw(in: textRect, withAttributes: textAttributes)
            }
        }
    }
    
    func setValue(value: Float) {
        toolTipValue = NSString.init(format: "%d", Int(value))
        self.setNeedsDisplay()
    }
}
