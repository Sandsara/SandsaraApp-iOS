//
//  ColorGradientView.swift
//  Sandsara
//
//  Created by Tín Phan on 02/12/2020.
//

import UIKit
import SnapKit
import Foundation
import CoreGraphics
import SnapKit
import UIKit.UIGestureRecognizerSubclass

func hexStringToData(string: String) -> Data {
    let stringArray = Array(string)
    var data: Data = Data()
    for i in stride(from: 0, to: string.count, by: 2) {
        let pair: String = String(stringArray[i]) + String(stringArray[i+1])
        if let byteNum = UInt8(pair, radix: 16) {
            let byte = Data([byteNum])
            data.append(byte)
        }
        else{
            fatalError()
        }
    }
    return data
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

enum PanDirection {
    case vertical
    case horizontal
}
// MARK: Pan gesture handler
class PanDirectionGestureRecognizer: UIPanGestureRecognizer {
    
    let direction: PanDirection
    
    init(direction: PanDirection, target: AnyObject, action: Selector) {
        self.direction = direction
        super.init(target: target, action: action)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        if state == .began {
            let vel = velocity(in: view)
            switch direction {
                case .horizontal where abs(vel.y) > abs(vel.x):
                    state = .cancelled
                case .vertical where abs(vel.x) > abs(vel.y):
                    state = .cancelled
                default:
                    break
            }
        }
    }
}

protocol ColorPointDragAble {
    func updateColor(atPoint: CGPoint)
    func showGradient(atPoint: CGPoint, color: UIColor)
}

class ColorPointView: UIView {
    var color: UIColor? {
        didSet {
            updateColor()
        }
    }
    var currentPoint: CGPoint?
    
    var leadingConstraint: Constraint!
    
    var minPoint: CGPoint?
    
    var maxPoint: CGPoint?
    
    var colorThumb: UIView?
    var lineView: UIView?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        lineView = UIView()
        colorThumb = UIView()
        addSubview(lineView!)
        lineView?.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalTo(11)
            $0.height.equalTo(14)
            $0.width.equalTo(2)
        }
        
        addSubview(colorThumb!)
        colorThumb?.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.top.equalTo(lineView!.snp.bottom)
            $0.leading.trailing.equalTo(0)
            $0.bottom.equalTo(-6)
        }
        
        
        colorThumb?.clipsToBounds = true
        
        updateColor()
    }
    
    override func awakeFromNib() {
    }
    
    override func draw(_ rect: CGRect) {
        colorThumb?.layer.cornerRadius = colorThumb!.bounds.size.width / 2
    }
    
    func updateColor() {
        //backgroundColor = color
        lineView?.backgroundColor = color
        colorThumb?.backgroundColor = color
        
        guard let color = color else { return }
        if color.hsba().brightness < 0.16 {
            lineView?.layer.borderWidth = 1
            lineView?.layer.borderColor = UIColor.white.cgColor
            colorThumb?.layer.borderWidth = 1
            colorThumb?.layer.borderColor = Asset.primary.color.cgColor
        } else {
            lineView?.layer.borderWidth = 0
            lineView?.layer.borderColor = UIColor.white.cgColor
            colorThumb?.layer.borderWidth = 0
            colorThumb?.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorThumb?.layer.cornerRadius = colorThumb!.bounds.size.width / 2
    }
}

protocol ColorGradientViewDelegate: class {
    func firstPointTouch(color: UIColor)
    func secondPointTouch(color: UIColor)
    func showGradient(atPoint: CGPoint, color: UIColor)
}

class ColorGradientView: UIView {
    
    var color: ColorModel = ColorModel(position: PredifinedColor.one.posistion.map {
        Int($0)
    }, colors: PredifinedColor.one.colors.map {
        $0.hexString()
    }) {
        didSet {
            selectColor()
        }
    }
    
    var colors: [UIColor] = [] {
        didSet {
            updateColor()
        }
    }
    
    var cachedGradients: [UIColor] = []
    
    var locations = [CGFloat]()
    
    var showPoint: CGPoint = CGPoint.zero
    
    var firstPoint: CGPoint = CGPoint(x: 24, y : 0)
    
    var secondPoint: CGPoint = CGPoint(x: UIScreen.main.bounds.size.width - 32 - 24, y: 0)
    
    var isFirst: Bool = false
    
    var isLast: Bool = false
    
    var addCustomPoint = false
    
    var updateCustomPoint = false
    
    var deleteCustomPoint = false
    
    var gradientView: GradientView?
    
    var firstPointView: ColorPointView?
    
    var secondPointView: ColorPointView?
    
    var pointViews: [ColorPointView] = []
    
    var pointConstraints: [Constraint] = []
    
    weak var delegate: ColorGradientViewDelegate?
    
    // MARK: UI Setup and Constraints
    override func awakeFromNib() {
        super.awakeFromNib()
        gradientView = GradientView()
        gradientView?.mode = .linear
        gradientView?.direction = .horizontal
        
        addSubview(gradientView!)
        
        gradientView?.snp.makeConstraints {
            $0.left.equalTo(11)
            $0.right.equalTo(-11)
            $0.top.equalToSuperview()
            $0.height.equalTo(43)
        }
        
        firstPointView = ColorPointView()
        addSubview(firstPointView!)
        
        firstPointView?.snp.makeConstraints {
            $0.top.equalTo(43)
            $0.leading.equalToSuperview()
            $0.width.equalTo(24)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview()
        }
        
        secondPointView = ColorPointView()
        addSubview(secondPointView!)
        
        secondPointView?.snp.makeConstraints {
            $0.top.equalTo(43)
            $0.trailing.equalToSuperview()
            $0.width.equalTo(24)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview()
        }
        
        firstPointView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showFirstPoint)))
        secondPointView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSecondPoint)))
        gradientView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showGradientGesture(_:))))
    }
    
    override func draw(_ rect: CGRect) {
        selectColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        secondPoint.x = gradientView?.frame.size.width ?? 0
    }
    
    // MARK: Function to execute after user select a color on Color grid view
    func selectColor() {
        if addCustomPoint {
            return;
        }
        
        if updateCustomPoint {
            return;
        }
        
        gradientView?.locations = color.position.map {
            CGFloat($0) / 255.0
        }
        
        locations = color.position.map {
            CGFloat($0) / 255.0
        }
        
        for view in pointViews {
            view.removeFromSuperview()
        }
        
        pointViews.removeAll()
        
        
        var drawColors = color.colors.map { UIColor(hexString: $0) }
        var drawPositons = color.position.map {
            convertGradientPointToSystemPoint(x: CGFloat($0))
        }
        
        if drawColors.count > 2 {
            drawColors.removeFirst()
            drawColors.removeLast()
        }
        
        if drawPositons.count > 2 {
            drawPositons.removeFirst()
            drawPositons.removeLast()
            
            guard drawColors.count == drawPositons.count else { return }
            for i in 0 ..< drawColors.count {
                addPoint(color: drawColors[i], xPoint: drawPositons[i])
            }
        }
       
        
        gradientView?.colors = color.colors.map { UIColor(hexString: $0) }
        gradientView?.locations = locations
        firstPointView?.color = color.colors.map { UIColor(hexString: $0) }.first
        secondPointView?.color = color.colors.map { UIColor(hexString: $0) }.last
        cachedGradients = color.colors.map { UIColor(hexString: $0) }
    }
    
    func updateColor() {
        cachedGradients = colors
        gradientView?.colors = cachedGradients
        gradientView?.locations = locations
        firstPointView?.color = cachedGradients.first
        secondPointView?.color = cachedGradients.last
        colorCommand()
    }
    
    func showColorThumb(colorThumbView: ColorPointView, isShow: Bool) {
        colorThumbView.isHidden = !isShow
        colorThumbView.alpha = isShow ? 1: 0
    }
    
    // MARK: First point of gradient view touch
    @objc func showFirstPoint() {
        cleanup(isShowAll: false)
        isFirst = true
        delegate?.firstPointTouch(color: cachedGradients.first ?? .clear)
    }
    
    // MARK: Second point of gradient view touch
    @objc func showSecondPoint() {
        cleanup(isShowAll: false)
        isLast = true
        delegate?.secondPointTouch(color: cachedGradients.last ?? .clear)
    }
    
    // MARK: Gradient point touch gesture
    @objc func showGradientGesture(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: gradientView)
        debugPrint("Touch point \(point.x), \(point.y)")
        var isAddAble = false
        for i in 0 ..< pointViews.count {
            let maxOffset: CGFloat = 12
            let minOffset: CGFloat = i == 0 ? 12 : 36
            if point.x + maxOffset <= (pointViews[i].maxPoint?.x ?? 0)  && point.x - minOffset >= (pointViews[i].minPoint?.x ?? 0) {
                isAddAble = true
            } else {
                continue
            }
        }
        
        if pointViews.isEmpty {
            isAddAble = true
        }
        
        if isAddAble {
            cleanup(isShowAll: false)
            showPoint = point
            addCustomPoint = true
            delegate?.showGradient(atPoint: showPoint, color: getPixelColor(atPosition: showPoint))
        }
    }
    
    // MARK: Function to reset all the flags after user edit an old color or add new color point
    func cleanup(isShowAll: Bool) {
        isFirst = false
        isLast = false
        addCustomPoint = false
        updateCustomPoint = false
        deleteCustomPoint = false
        showPoint = .zero
        for subview in subviews {
            if let subview = subview as? ColorPointView {
                showColorThumb(colorThumbView: subview, isShow: isShowAll)
            }
        }
    }
    
    // MARK: Update first point color after user edit a color on First point
    func updateFirstColor(color: UIColor) {
        var colors = self.cachedGradients
        colors.removeFirst()
        colors.insert(color, at: 0)
        self.colors = colors
        firstPointView?.color = color
        cachedGradients = colors
        cleanup(isShowAll: true)
    }
    
    // MARK: Update second point color after user edit a color on First point
    func updateSecondColor(color: UIColor) {
        var colors = self.cachedGradients
        colors.removeLast()
        colors.insert(color, at: colors.count)
        
        self.colors = colors
        secondPointView?.color = color
        cachedGradients = colors
        cleanup(isShowAll: true)
    }
    
    // MARK: Calculate point arrays and locations of gradient after we add the new color to our gradients
    func addColor(color: UIColor) {
        addPoint(color: color, xPoint: showPoint.x)
        var updatedColors = cachedGradients
        
        var index = 0
        
        // update point after add
        for i in 0 ..< pointViews.count {
            if pointViews[i].currentPoint?.x == showPoint.x {
                index = i
                break
            }
        }
        
        // update
        updatedColors.insert(color, at: index + 1)
        locations.insert(showPoint.x / secondPoint.x, at: index + 1)
        
        locations = [
            0
        ] + self.pointViews.map {
            CGFloat($0.currentPoint?.x ?? 0) / (self.secondPoint.x)
        } + [1]
        
        colors = updatedColors
        cachedGradients = updatedColors
        cleanup(isShowAll: true)
    }
    
    // MARK: Update user's selected color point ( except First and Second point)
    func updatePointColor(color: UIColor) {
        var updatedColors = cachedGradients
        for i in 0 ..< pointViews.count {
            if pointViews[i].currentPoint?.x == showPoint.x {
                pointViews[i].color = color
                updatedColors[i + 1] = color
                break
            }
        }
        
        colors = updatedColors
        
        cachedGradients = updatedColors
        
        cleanup(isShowAll: true)
    }
    
    // MARK: Remove user's selected color point ( except First and Second point)
    func removeColor(color: UIColor) {
        var updatedColors = cachedGradients
        /// Recalculate locations and colors on gradients
        for i in 0 ..< pointViews.count {
            if pointViews[i].currentPoint?.x == showPoint.x {
                pointViews[i].removeFromSuperview()
                pointViews.remove(at: i)
                updatedColors.remove(at: i + 1)
                locations.remove(at: i + 1)
                break
            }
        }
        
        recalculatePoint()
        
        colors = updatedColors
        
        cachedGradients = updatedColors
        
        cleanup(isShowAll: true)
    }
    
    func getPixelColor(atPosition:CGPoint) -> UIColor{
        var pixel:[CUnsignedChar] = [0, 0, 0, 0];
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let bitmapInfo = CGBitmapInfo(rawValue:    CGImageAlphaInfo.premultipliedLast.rawValue);
        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue);
        
        context!.translateBy(x: -atPosition.x, y: -atPosition.y);
        layer.render(in: context!);
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0,
                                    green: CGFloat(pixel[1])/255.0,
                                    blue: CGFloat(pixel[2])/255.0,
                                    alpha: CGFloat(pixel[3])/255.0);
        
        return color;
        
    }
    var initialPoint = CGPoint()
    
    // MARK: Drag gesture handler
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let pointView = gestureRecognizer.view as? ColorPointView, let currentPoint = pointView.currentPoint else { return }
        let translation = gestureRecognizer.translation(in: pointView.superview)
        //var leadingConstraint: Constraint!
        // follow the pan
        if gestureRecognizer.state == .began {
            initialPoint = pointView.center
        }
        
        if gestureRecognizer.state != .cancelled {
            let amount = initialPoint.x + translation.x
            let newCenter = CGPoint(x: amount, y: 65.0)
            
            let index = pointViews.firstIndex(of: pointView) ?? 0
            
            let maxOffset: CGFloat = 12
            
            let minOffset: CGFloat = index == 0 ? 12 : 36
            
            // gestureRecognizer.setTranslation(.zero, in: pointView.superview)
            
            if amount + maxOffset <= (pointView.maxPoint?.x ?? 0)  && amount - minOffset >= (pointView.minPoint?.x ?? 0) {
                pointView.center = newCenter
                
                for view in pointViews where currentPoint == view.currentPoint {
                    view.currentPoint = CGPoint(x: pointView.center.x - 12, y: pointView.center.y)
                }
                
                recalculatePoint()
                
                if gestureRecognizer.state == .ended {
                    colorCommand()
                }
                cleanup(isShowAll: true)
            }
        }
    }
    
    // MARK: Color mapping function
    func convertGradientPointToSystemPoint(x: CGFloat) -> CGFloat {
        return x * secondPoint.x / 255
    }
    
    func convertSystemPointToGradientPoint(x: CGFloat) -> CGFloat {
        return x * 255 / secondPoint.x
    }
    
    func pointToLocation(x: Float) -> Float {
        return x / 1.0
    }
    
    // MARK: Add point function
    
    /// Add point function
    /// - Parameters:
    ///   - color: color want to add
    ///   - xPoint: the positon to add , by x coordinate
    private func addPoint(color: UIColor, xPoint: CGFloat) {
        let pointView = ColorPointView()
        addSubview(pointView)
        var leadingConstraint: Constraint!
        pointView.snp.makeConstraints {
            $0.top.equalTo(43)
            leadingConstraint = $0.leading.equalTo(xPoint).constraint
            $0.width.equalTo(24)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview()
        }
        pointView.leadingConstraint = leadingConstraint
        pointView.currentPoint = CGPoint(x: xPoint, y: 30.0)
        pointView.color = color
        
        pointViews.append(pointView)
        // TODO : check condtion here
        pointView.tag = pointViews.firstIndex(of: pointView) ?? 0
        
        recalculatePoint()
        
        
        let panGestureRecognizer = PanDirectionGestureRecognizer(direction: .horizontal,
                                                                 target: self,
                                                                 action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.cancelsTouchesInView = false
        pointView.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(handleTapGesture(_:)))
        pointView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: Handle tap gesture to edit a point
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        let point = (sender.view as? ColorPointView)?.currentPoint ?? .zero
        debugPrint("Touch point \(point.x), \(point.y)")
        
        showPoint = point
        updateCustomPoint = true
        delegate?.showGradient(atPoint: showPoint, color: getPixelColor(atPosition: showPoint))
    }
    
    // MARK: Send color patteles function
    func colorCommand() {
        
        let position = Data(locations.map { $0 * 255 }.map { UInt8($0) })
        print(position)
        let red = Data(cachedGradients.map {
            UInt8($0.rgba().red * 255)
        })
        print(red)
        let blue = Data(cachedGradients.map {
            UInt8($0.rgba().blue * 255)
        })
        print(blue)
        let green = Data(cachedGradients.map {
            UInt8($0.rgba().green * 255)
        })
        print(green)
        let colorString = [Data([UInt8(cachedGradients.count)]), position, red, green, blue].combined
        print(colorString)
        
        bluejay.write(to: LedStripService.uploadCustomPalette, value: colorString) { result in
            switch result {
            case .success:
                print("write success")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        var colorModel = ColorModel()
        var reds = [Float]()
        var blues = [Float]()
        var greens = [Float]()
        var positions = [Int]()
        reds = cachedGradients.map {
            $0.rgba().red * 255
        }.map { Float($0) }
        blues = cachedGradients.map {
            $0.rgba().blue * 255
        }.map { Float($0) }
        greens = cachedGradients.map {
            $0.rgba().green * 255
        }.map { Float($0) }
        positions = locations.map { $0 * 255 }.map { Int($0) }
        
        let colorsTest = zip3(reds, greens, blues).map {
            RGBA(red: CGFloat($0.0) / 255, green: CGFloat($0.1) / 255, blue: CGFloat($0.2) / 255).color().hexString()
        }
        if positions.count == 1 {
            colorModel.position = [0, 255]
            if let color = colorsTest.first {
                colorModel.colors = [color, color]
            }
        } else {
            colorModel.position = positions
            colorModel.colors = colorsTest
        }
        DeviceServiceImpl.shared.runningColor.accept(colorModel)
    }
    
    // MARK: Recalculate function after the Color point is dragged / removed or added to Color points array
    private func recalculatePoint() {
        pointViews.sort(by: {
            ($0.currentPoint?.x ?? 0) < ($1.currentPoint?.x ?? 0)
        })
        if pointViews.count > 1 {
            for i in 0 ..< pointViews.count {
                if i == 0 {
                    pointViews[i].maxPoint = CGPoint(x: (pointViews[i + 1].currentPoint?.x ?? 0), y: 30)
                    pointViews[i].minPoint = CGPoint(x: firstPoint.x, y: 30)
                }
                else if i == pointViews.count - 1 {
                    pointViews[i].maxPoint = CGPoint(x: secondPoint.x, y: 30)
                    pointViews[i].minPoint = CGPoint(x: (pointViews[i - 1].currentPoint?.x ?? 0 + 24), y: 30)
                } else {
                    pointViews[i].maxPoint = CGPoint(x: pointViews[i + 1].currentPoint?.x ?? 0 , y: 30)
                    pointViews[i].minPoint = CGPoint(x: (pointViews[i - 1].currentPoint?.x ?? 0 + 24), y: 30)
                }
            }
        } else if !pointViews.isEmpty {
            pointViews[0].maxPoint = CGPoint(x: secondPoint.x, y: 30)
            pointViews[0].minPoint = CGPoint(x: firstPoint.x, y: 30)
        }
        
        locations = [
            0
        ] + self.pointViews.map {
            CGFloat($0.currentPoint?.x ?? 0) / (self.secondPoint.x)
        } + [1]
        
        gradientView?.colors = cachedGradients
        gradientView?.locations = locations
        firstPointView?.color = cachedGradients.first
        secondPointView?.color = cachedGradients.last
        
    }
}

//extension StringProtocol {
//    var data: Data { .init(utf8) }
//    var bytes: [UInt8] { .init(utf8) }
//}

extension Array where Element == Data {
    /**
     * Combines data
     * ## Examples:
     * [Data(),Data()].combined
     */
    var combined: Data {
        reduce(.init(), +)
    }
}
