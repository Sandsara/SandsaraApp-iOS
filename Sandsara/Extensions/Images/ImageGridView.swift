//
//  ImageGridView.swift
//  ImageGridView
//
//  Created by Miraan on 30/09/2017.
//

import UIKit

public protocol ImageGridViewDelegate {
    func imageGridView(_ imageGridView: ImageGridView, didTapDeleteForImage index: Int)
    func imageGridViewDidTapAddImage(_ imageGridView: ImageGridView)
    func imageGridView(_ imageGridView: ImageGridView, didMoveImage fromIndex: Int, toIndex: Int)
}

public protocol ImageGridViewDatasource {
    func imageGridViewImages(_ imageGridView: ImageGridView) -> [UIImage]
}

public class ImageGridView: UIView {
    
    let itemPadding: CGFloat = 0.0
    var overlapThreshold: CGFloat = 0.0
    
    public var delegate: ImageGridViewDelegate!
    public var datasource: ImageGridViewDatasource!
    public var maxCapacity: Int = 8
    
    var itemViews: [ImageGridItemView] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        if frame.size.width != frame.size.height {
            print("ImageGridView:init(frame:) error: Width and height are not the same")
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
      //  fatalError("init(coder:) has not been implemented")
    }
    
    public func reload() {
//        if delegate == nil {
//            print("ImageGridView:reload() error: No delegate")
//            return
//        }
        if datasource == nil {
            print("ImageGridView:reload() error: No datasource")
        }
        for itemView in self.itemViews {
            itemView.removeFromSuperview()
        }
        self.itemViews = []
        let images = datasource.imageGridViewImages(self)
        var size = 2
        while images.count >= size * size {
            size = size + 1
        }
        let totalPadding = CGFloat(size - 1) * itemPadding
        let itemSize = (frame.size.width - totalPadding) / CGFloat(size)
        self.overlapThreshold = itemSize / 2
        outerLoop: for row in 0...size-1 {
            for col in 0...size-1 {
                let index = (row * size) + col
                if index >= maxCapacity {
                    break outerLoop
                }
                let x = (CGFloat(col) * itemSize) + (CGFloat(col) * itemPadding)
                let y = (CGFloat(row) * itemSize) + (CGFloat(row) * itemPadding)
                let itemView = ImageGridItemView(frame: CGRect(x: x, y: y, width: itemSize, height: itemSize))
                itemView.index = index
              //  itemView.delegate = self
                itemView.datasource = self
                self.itemViews.append(itemView)
                self.addSubview(itemView)
                itemView.reload()
            }
        }
    }
    
}

extension ImageGridView: ImageGridItemViewDelegate {
    
    func imageGridItemViewDidStartDragging(_ imageGridItemView: ImageGridItemView) {
        self.bringSubviewToFront(imageGridItemView)
        imageGridItemView.lastLocation = imageGridItemView.center
    }
    
    func imageGridItemView(_ imageGridItemView: ImageGridItemView, didDragBy translation: CGPoint) {
        imageGridItemView.center = CGPoint(x: imageGridItemView.lastLocation.x + translation.x, y: imageGridItemView.lastLocation.y + translation.y)
    }
    
    func imageGridItemViewDidEndDragging(_ imageGridItemView: ImageGridItemView) {
        for itemView in self.itemViews {
            if itemView != imageGridItemView {
                if let overlapRect = getOverlapRect(itemA: itemView, itemB: imageGridItemView) {
                    if overlapRect.width > self.overlapThreshold && overlapRect.height > self.overlapThreshold {
                        delegate.imageGridView(self, didMoveImage: imageGridItemView.index, toIndex: itemView.index)
                        return
                    }
                }
            }
        }
        
        imageGridItemView.center = imageGridItemView.lastLocation
    }
    
    func imageGridItemViewDidTapDelete(_ imageGridItemView: ImageGridItemView) {
        delegate.imageGridView(self, didTapDeleteForImage: imageGridItemView.index)
    }
    
    func imageGridItemViewDidTapAddImage(_ imageGridItemView: ImageGridItemView) {
        delegate.imageGridViewDidTapAddImage(self)
    }
    
    func getOverlapRect(itemA: ImageGridItemView, itemB: ImageGridItemView) -> CGRect? {
        let topLeftX = max(itemA.frame.minX, itemB.frame.minX)
        let topLeftY = max(itemA.frame.minY, itemB.frame.minY)
        let bottomRightX = min(itemA.frame.maxX, itemB.frame.maxX)
        let bottomRightY = min(itemA.frame.maxY, itemB.frame.maxY)
        
        if topLeftX > bottomRightX || topLeftY > bottomRightY {
            return nil // No overlap
        }
        
        return CGRect(x: topLeftX, y: topLeftY, width: bottomRightX - topLeftX, height: bottomRightY - topLeftY)
    }
    
}

extension ImageGridView: ImageGridItemViewDatasource {
    
    func imageGridItemViewImage(_ imageGridItemView: ImageGridItemView) -> UIImage? {
        let images = self.datasource.imageGridViewImages(self)
        guard let index = imageGridItemView.index else {
            print("ImageGridView:imageGridItemViewImage() error: imageGridItemView.index is nil")
            return nil
        }
        return index < images.count ? images[index] : nil
    }
    
}
