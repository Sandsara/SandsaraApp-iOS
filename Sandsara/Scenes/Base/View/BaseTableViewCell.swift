import UIKit
import RxSwift

protocol CellModelType {
    associatedtype Input
    associatedtype Output

    var inputs: Input { get }
    var outputs: Output! { get }
}

// MARK: BaseTableViewCell support ViewModel Binding
class BaseTableViewCell<ViewModel: CellModelType>: UITableViewCell, ViewModelBindable {

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
