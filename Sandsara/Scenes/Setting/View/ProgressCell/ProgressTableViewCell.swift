//
//  ProgressTableViewCell.swift
//  Sandsara
//
//  Created by Tín Phan on 11/11/20.
//

import UIKit
import RxSwift
import RxCocoa

class ProgressTableViewCell: BaseTableViewCell<ProgressCellViewModel> {
    @IBOutlet private weak var progressNameLabel: UILabel!
    @IBOutlet private weak var progressSlider: CustomSlider!

    // MARK: UI Setup
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        progressNameLabel.font = FontFamily.OpenSans.regular.font(size: 18)
        progressNameLabel.textColor = Asset.primary.color
        progressSlider.isContinuous = false
        for state: UIControl.State in [.normal, .selected, .application, .reserved] {
            progressSlider.setThumbImage(Asset.thumbs.image, for: state)
        }
    }
    
    // MARK: UI Binding function with ProgressCellViewModel
    override func bindViewModel() {
        
        // MARK: Max and Min value setup for different kind of Slider type. For the type, please look at SettingItemType -> sliderValue
        /// sliderValue.0 stand for min range, sliderValue.1 stand for max range
        progressSlider.maximumValue = viewModel.inputs.type.sliderValue.1
        progressSlider.minimumValue = viewModel.inputs.type.sliderValue.0
 
        
        /// Cell Title base on SettingItemType
        viewModel
            .outputs
            .title
            .drive(progressNameLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel
            .outputs
            .progress
            .drive(progressSlider.rx.value)
            .disposed(by: disposeBag)

        // MARK: Slider gestures function
        progressSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(sliderTouchUpInside), for: [.touchUpInside])
        progressSlider.addTarget(self, action: #selector(sliderTouchUpInside), for: [.touchUpOutside])
        progressSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:))))
    }
    
    // MARK: User tap gesture on slider . After the touch gesture is ended, we will send the latest value to Sandsara
    @objc func sliderTapped(_ gestureRecognizer: UIGestureRecognizer) {
        guard let slider = gestureRecognizer.view as? UISlider else { return }
        let pointTapped = gestureRecognizer.location(in: slider)

        let positionOfSlider = slider.bounds.origin
        let widthOfSlider = slider.bounds.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(slider.maximumValue) / widthOfSlider)
        slider.setValue(Float(newValue), animated: true)
        viewModel.inputs.progress.accept(Float(newValue).rounded())
    }
    
    // MARK: User touch gesture tracking. After the finger drag is end, we will send the latest value to Sandsara
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
                case .began:
                // handle drag began
                print("drag began")
                case .moved:
                // handle drag moved
                print("drag moved")
                  //  viewModel.inputs.progress.accept(slider.value.rounded())
                case .ended:
                // handle drag ended
                print("drag ended")
                    viewModel.inputs.progress.accept(slider.value.rounded())
                default:
                    break
            }
        }
    }
    
    @objc func sliderTouchUpInside() {
        print("drag ended")
    }
}
