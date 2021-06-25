//
//  SearchViewController.swift
//  Sandsara
//
//  Created by Tín Phan on 07/01/2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchViewController: BaseViewController<NoInputParam>, UISearchControllerDelegate {
    
    //MARK: Outlet connection
    @IBOutlet weak var segmentControl: CustomSegmentControl!
    @IBOutlet weak var containerView: UIView!

    //MARK: Properties
    private let sc = UISearchController(searchResultsController: nil)
    
    //MARK: Subcontrollers for tracks and playlist
    private var allTrackVC: BrowseTrackViewController?
    private var playlistsVC: BrowsePlaylistViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchBar()
        initControllers()
        setupSegment()
        navigationItem.hidesBackButton = true
        sc.delegate = self
        sc.isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    private func setUpSearchBar() {
        sc.dimsBackgroundDuringPresentation = false
        searchBarStyle(sc.searchBar)
        navigationItem.searchController = sc
        
        
        // MARK: Search bar text changed handler
        sc.searchBar
            .rx
            .text
            .orEmpty
            .asObservable()
            .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribeNext { text in
                if !text.isEmpty {
                    self.allTrackVC?.searchTrigger.accept(text)
                    self.playlistsVC?.searchTrigger.accept(text)
                } else {
                    self.allTrackVC?.viewWillAppearTrigger.accept(())
                    self.playlistsVC?.viewWillAppearTrigger.accept(())
                }
            }
            .disposed(by: disposeBag)
        sc
            .searchBar.rx.cancelButtonClicked
            .subscribeNext {
                self.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)

    }

    @objc func hideKeyboard() {
        sc.searchBar.endEditing(true)
        sc.isActive = false
    }
    
    /// Setup SearchBar Style
    /// - Parameter searchBar: searchBar you want to modify
    private func searchBarStyle(_ searchBar: UISearchBar) {
        searchBar.placeholder = "Search"
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = Asset.primary.color
        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField,
           let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
            glassIconView.image = Asset.smallSearch.image
            glassIconView.image = glassIconView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            glassIconView.tintColor = Asset.primary.color
            textFieldInsideSearchBar.backgroundColor = UIColor(red: 0.062, green: 0.062, blue: 0.062, alpha: 1)
        }

        extendedLayoutIncludesOpaqueBars = true
        searchBar.tintColor = Asset.primary.color
        navigationItem.hidesSearchBarWhenScrolling = false
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
        allTrackVC = storyboard?.instantiateViewController(withIdentifier: BrowseTrackViewController.identifier) as? BrowseTrackViewController
        playlistsVC = storyboard?.instantiateViewController(withIdentifier: BrowsePlaylistViewController.identifier) as? BrowsePlaylistViewController
        addChildViewController(controller: allTrackVC!, containerView: containerView, byConstraints: true)
    }
    
    /// Update controller when press on segment
    /// - Parameter i: User's selected controller index
    func updateControllersByIndex(i: Int) {
        self.removeAllChildViewController()
        if i == 0 {
            addChildViewController(controller: allTrackVC!, containerView: containerView, byConstraints: true)
            if let text = sc.searchBar.text {
                if text.isEmpty {
                    allTrackVC?.viewWillAppearTrigger.accept(())
                } else {
                    allTrackVC?.searchTrigger.accept(text)
                }
            } else {
                allTrackVC?.viewWillAppearTrigger.accept(())
            }
        } else {
            addChildViewController(controller: playlistsVC!, containerView: containerView, byConstraints: true)
            if let text = sc.searchBar.text {
                if text.isEmpty {
                    playlistsVC?.viewWillAppearTrigger.accept(())
                } else {
                    playlistsVC?.searchTrigger.accept(text)
                }
            } else {
                playlistsVC?.viewWillAppearTrigger.accept(())
            }
        }

    }

    func didPresentSearchController(_ searchController: UISearchController) {
        sc.searchBar.becomeFirstResponder()
    }
}
