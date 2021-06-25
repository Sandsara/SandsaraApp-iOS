//
//  ProgressButtonView.swift
//  Sandsara
//
//  Created by Tín Phan on 19/12/2020.
//

import UIKit

enum ProgressUseCase {
    case downloadTrack
    case syncTrack
}

class ProgressButtonUIView: UIView {

    var title: String?
    var inProgressTitle: String?

    var touchEvent: (() -> ())?

    private var vStack: UIStackView!
    private var button: LoadingButton!
    var progressBar: UIProgressView!

    var isTaskRunning: Bool = false {
        didSet {
            if isTaskRunning {
                isUserInteractionEnabled = false
                progressBar.isHidden = false
                button.setTitle(inProgressTitle, for: .normal)
                vStack.spacing = 10.0
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        vStackInit()
        buttonInit()
        progressBarInit()
    }

    func setupUI(title: String, image: UIImage?, font: UIFont?, inProgressTitle: String, color: UIColor?) {
        self.title = title
        self.inProgressTitle = inProgressTitle
        button.setImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = font
        button.tintColor = color
        button.setTitleColor(color, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        progressBar.progressTintColor = color
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    private func vStackInit() {
        vStack = UIStackView()
        vStack.axis = .vertical
        vStack.alignment = .fill
        vStack.distribution = .equalSpacing
        addSubview(vStack)
        vStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func buttonInit() {
        button = LoadingButton(type: .system)
        button.addTarget(self, action: #selector(bthTouch(_:)), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        button.contentVerticalAlignment = .center
        vStack.addArrangedSubview(button)

        button.snp.makeConstraints {
            $0.height.equalTo(30)
        }
    }

    private func progressBarInit() {
        progressBar = UIProgressView()
        progressBar.trackTintColor = .clear

        vStack.addArrangedSubview(progressBar)
        progressBar.snp.makeConstraints {
            $0.height.equalTo(3)
        }
    }

    @objc func bthTouch(_ sender: UIButton) {
        isTaskRunning = true
        button.showLoading()
        touchEvent?()
    }

    func updateProgress(progress: Float) {
        progressBar.progress = progress
    }

    private func updateRunningTask() {
        isUserInteractionEnabled = false
        progressBar.isHidden = false
        button.setTitle(inProgressTitle, for: .normal)
        button.showLoading()
    }
}
