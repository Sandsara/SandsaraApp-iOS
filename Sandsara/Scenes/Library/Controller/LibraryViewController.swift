//
//  LibraryViewController.swift
//  Sandsara
//
//  Created by Tín Phan on 15/11/2020.
//

import UIKit
import BetterSegmentedControl
import RxSwift
import RxCocoa

// MARK: Custom segment to adapt Figma Design
class CustomSegmentControl: BetterSegmentedControl {
    private(set) var segmentSelected = BehaviorRelay<Int>(value: 0)

    func setStyle(font: UIFont?, titles: [String]) {
        segments = LabelSegment.segments(withTitles: titles,
                                         normalFont: font,
                                         normalTextColor: Asset.tertiary.color,
                                         selectedFont: font,
                                         selectedTextColor: Asset.primary.color)
        self.addTarget(self, action: #selector(segmentDidSelected), for: .valueChanged)
    }


    @objc
    private func segmentDidSelected() {
        segmentSelected.accept(index)
    }
}

// MARK: Library tab
class LibraryViewController: BaseViewController<NoInputParam> {
    
    // MARK: Outlet connections between swift file and xib/ storyboard file
    @IBOutlet weak var segmentControl: CustomSegmentControl!
    @IBOutlet weak var containerView: UIView!
    
    
    // MARK: Properties
    private let segmentIndexTrigger = BehaviorRelay<Int>(value: 0)
    private var allTrackVC: AllTrackViewController?
    private var playlistsVC: PlaylistViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        initControllers()
        setupSegment()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    /// Segment tab init for track and playlist
    private func setupSegment() {
        segmentControl.setStyle(font: FontFamily.Tinos.regular.font(size: 30), titles:  [L10n.tracks, L10n.playlists])

        segmentControl
            .segmentSelected
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] index in
                self?.updateControllersByIndex(i: index)
            }
            .disposed(by: disposeBag)
    }
    
    /// Init subcontrollers
    private func initControllers() {
        allTrackVC = storyboard?.instantiateViewController(withIdentifier: AllTrackViewController.identifier) as? AllTrackViewController

        playlistsVC = storyboard?.instantiateViewController(withIdentifier: PlaylistViewController.identifier) as? PlaylistViewController

        addChildViewController(controller: allTrackVC!, containerView: containerView, byConstraints: true)

    }
    
    
    /// Update controller when press on segment
    /// - Parameter i: User's selected controller index
    func updateControllersByIndex(i: Int) {
        self.removeAllChildViewController()
        if i == 0 {
            addChildViewController(controller: allTrackVC!, containerView: containerView, byConstraints: true)
            allTrackVC?.viewWillAppearTrigger.accept(())
        } else {
            addChildViewController(controller: playlistsVC!, containerView: containerView, byConstraints: true)
            playlistsVC?.viewWillAppearTrigger.accept(())
        }
    }
    
    /// Show Alert for user to retry API call again
    override func triggerAPIAgain() {
        self.showAlert(title: "Alert", message: "No Internet Connection", preferredStyle: .alert, actions:
                        UIAlertAction(title: "Try Again", style: .default, handler: { _ in
                            if self.segmentControl.segmentSelected.value == 0 {
                                self.allTrackVC?.viewWillAppearTrigger.accept(())
                            } else {
                                self.playlistsVC?.viewWillAppearTrigger.accept(())
                            }
                        }),
                       UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )
    }
}
