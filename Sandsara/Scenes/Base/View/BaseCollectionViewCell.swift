//
//  BaseCollectionViewCell.swift
//  Sandsara
//
//  Created by Tín Phan on 15/11/2020.
//

import UIKit
import RxSwift

// MARK: BaseCollectionViewCell support ViewModel Binding
class BaseCollectionViewCell<ViewModel: CellModelType>: UICollectionViewCell, ViewModelBindable {

    private(set) var disposeBag = DisposeBag()
    var viewModel: ViewModel!

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    func bindViewModel() {
        fatalError()
    }

}
