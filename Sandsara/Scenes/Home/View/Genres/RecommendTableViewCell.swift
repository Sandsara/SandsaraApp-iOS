//
//  AllGenresTableViewCell.swift
// 
//
//  Created by tin on 5/18/20.
//  Copyright © 2020 tin. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

private struct Constants {
    static let cellHeight: CGFloat = 127.0
    static let cellWidth: CGFloat = 127.0
}

class RecommendTableViewCell: BaseTableViewCell<RecommendTableViewCellViewModel> {
    
    // MARK: Outlet connections between swift file and xib/ storyboard file
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: Properties
    typealias Section = SectionModel<String, RecommendCellViewModel>
    typealias DataSource = RxCollectionViewSectionedReloadDataSource<Section>
    var selectedCell = PublishRelay<(Int, DisplayItem)>()

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = Asset.background.color
        titleLabel.font = FontFamily.Tinos.regular.font(size: 20)
        titleLabel.textColor = Asset.primary.color
        collectionView.backgroundColor = Asset.background.color
        collectionView.register(RecommendCell.nib, forCellWithReuseIdentifier: RecommendCell.identifier)
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        
        /// Binding Recommended tracks or Recommended Playlist result here
        viewModel.outputs
            .dataSources
            .map { [Section(model: "", items: $0)] }
            .drive(collectionView.rx.items(dataSource: makeDatasource()))
            .disposed(by: disposeBag)

        viewModel
            .outputs.title
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        /// Cell section handler and trigger back to controller when a cell is selected
        Observable
            .zip(
                collectionView.rx.itemSelected,
                collectionView.rx.modelSelected(RecommendCellViewModel.self)
            ).bind { [weak self] indexPath, model in
                guard let self = self else { return }
                self.collectionView.deselectItem(at: indexPath, animated: true)
                self.selectedCell.accept((indexPath.row, model.inputs.item))
            }.disposed(by: disposeBag)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    private func makeDatasource() -> DataSource {
        return DataSource(
            configureCell: { (_, collectionView, indexPath, viewModel) -> UICollectionViewCell in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendCell.identifier, for: indexPath) as? RecommendCell else { return UICollectionViewCell()}
                cell.bind(to: viewModel)
                return cell
            })
    }
}

// MARK: UICollectionViewFlowLayout, Cell size calculation
extension RecommendTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.cellWidth, height: Constants.cellHeight)
    }
}
