//
//  ImageGridItemView.swift
//  ImageGridView
//
//  Created by Miraan on 30/09/2017.
//

import UIKit

protocol ImageGridItemViewDelegate {
    func imageGridItemViewDidTapDelete(_ imageGridItemView: ImageGridItemView)
    func imageGridItemViewDidTapAddImage(_ imageGridItemView: ImageGridItemView)
    func imageGridItemViewDidStartDragging(_ imageGridItemView: ImageGridItemView)
    func imageGridItemView(_ imageGridItemView: ImageGridItemView, didDragBy translation: CGPoint)
    func imageGridItemViewDidEndDragging(_ imageGridItemView: ImageGridItemView)
}

protocol ImageGridItemViewDatasource {
    func imageGridItemViewImage(_ imageGridItemView: ImageGridItemView) -> UIImage?
}

class ImageGridItemView: UIView {
    
    var lastLocation: CGPoint = CGPoint(x: 0, y: 0)
    
    var delegate: ImageGridItemViewDelegate!
    var datasource: ImageGridItemViewDatasource!
    var index: Int!
    
    private var imageView: UIImageView!
    private var buttonImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ImageGridItemView.detectPan(recognizer:)))
        self.gestureRecognizers = [panRecognizer]
//        self.layer.borderColor = UIColor.lightGray.cgColor
//        self.layer.borderWidth = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func detectPan(recognizer: UIPanGestureRecognizer) {
//        if delegate == nil {
//            print("ImageGridItemView:detectPan() error: No delegate")
//            return
//        }
//        if imageView.image == nil {
//            return
//        }
//        
//        if recognizer.state == UIGestureRecognizer.State.began {
//            self.delegate.imageGridItemViewDidStartDragging(self)
//            return
//        }
//        
//        if recognizer.state == UIGestureRecognizer.State.ended {
//            self.delegate.imageGridItemViewDidEndDragging(self)
//            return
//        }
//        
//        let translation = recognizer.translation(in: self.superview!)
//        self.delegate.imageGridItemView(self, didDragBy: translation)
    }
    
    func reload() {
//        if delegate == nil {
//            print("ImageGridItemView:reload() error: delegate is nil")
//            return
//        }
        if datasource == nil {
            print("ImageGridItemView:reload() error: datasource is nil")
            return
        }
        
        if self.imageView != nil {
            self.imageView.removeFromSuperview()
            self.imageView = nil
        }
        self.imageView = UIImageView(frame: self.bounds)
        let image = datasource.imageGridItemViewImage(self)
        self.imageView.image = image
        self.imageView.contentMode = UIView.ContentMode.scaleAspectFill
        self.imageView.clipsToBounds = true
        self.addSubview(self.imageView)
        
        if self.buttonImageView != nil {
            self.buttonImageView.removeFromSuperview()
            self.buttonImageView = nil
        }
        var buttonFrame: CGRect!
        if image == nil {
            buttonFrame = CGRect(x: self.frame.width / 4, y: self.frame.height / 4, width: self.frame.width / 2, height: self.frame.height / 2)
        } else {
            let length: CGFloat = 20.0
            let padding: CGFloat = 10.0
            buttonFrame = CGRect(x: self.frame.width - (length + padding), y: self.frame.height - (length + padding), width: length, height: length)
        }
        self.buttonImageView = UIImageView(frame: buttonFrame)
        self.buttonImageView.image = UIImage(named: image == nil ? "PlusIcon.png" : "CrossIcon.png", in: Bundle(for: type(of: self)), compatibleWith: nil)
        self.buttonImageView.contentMode = UIView.ContentMode.scaleAspectFill
        self.buttonImageView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageGridItemView.didTapButton))
        tapRecognizer.numberOfTapsRequired = 1
        self.buttonImageView.addGestureRecognizer(tapRecognizer)
        self.addSubview(self.buttonImageView)
    }
    
    @objc func didTapButton() {
        
    }
    
}
