//
//  SettingsViewController.swift
//  Sandsara
//
//  Created by Tín Phan on 11/11/20.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import Bluejay

extension Array {
    func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

class SettingsViewController: BaseVMViewController<SettingViewModel, NoInputParam> {

    @IBOutlet private weak var tableView: UITableView!

    private let viewWillAppearTrigger = PublishRelay<()>()
    private let lightMode = BehaviorRelay<LightMode>(value: .cycle)

    typealias Section = SectionModel<String, SettingItemCellType>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    private lazy var dataSource: DataSource = self.makeDataSource()

    /// Dictionary to store cell height
    private var cellHeightsDictionary: [IndexPath: CGFloat] = [:]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(largeTitleColor: Asset.primary.color, backgoundColor: Asset.background.color, tintColor: Asset.primary.color, title: L10n.settings, preferredLargeTitle: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = " "
    }

    override func setupViewModel() {
        setupTableView()
        viewModel = SettingViewModel(inputs: SettingViewModelContract.Input(viewWillAppearTrigger: viewWillAppearTrigger, lightMode: lightMode))
        viewWillAppearTrigger.accept(())
    }

    override func bindViewModel() {
        viewModel
            .outputs.datasources
            .map { [Section(model: "", items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()

        tableView.register(ProgressTableViewCell.nib, forCellReuseIdentifier: ProgressTableViewCell.identifier)
        tableView.register(SegmentTableViewCell.nib, forCellReuseIdentifier: SegmentTableViewCell.identifier)
        tableView.register(ToogleTableViewCell.nib, forCellReuseIdentifier: ToogleTableViewCell.identifier)
        tableView.remembersLastFocusedIndexPath = true
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)

        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 73

        tableView.register(SettingHeaderView.nib, forHeaderFooterViewReuseIdentifier: SettingHeaderView.identifier)
    }

    private func makeDataSource() -> DataSource {
        return RxTableViewSectionedReloadDataSource<Section>(
            configureCell: { [weak self] (_, tableView, indexPath, modelType) -> UITableViewCell in
                guard let self = self else { return UITableViewCell() }
                switch modelType {
                case .speed(let viewModel), .brightness(let viewModel), .lightCycleSpeed(let viewModel):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: ProgressTableViewCell.identifier, for: indexPath) as? ProgressTableViewCell else { return UITableViewCell()}
                    cell.bind(to: viewModel)
                    return cell
                case .lightMode(let viewModel):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: SegmentTableViewCell.identifier, for: indexPath) as? SegmentTableViewCell else { return UITableViewCell() }
                    cell.bind(to: viewModel)
                    cell.cellUpdated
                        .observeOn(MainScheduler.asyncInstance)
                        .subscribeNext {
                            tableView.beginUpdates()
                            tableView.endUpdates()
                        }.disposed(by: cell.disposeBag)
                    cell.advancedBtnTap.subscribeNext { [weak self] in
                        guard let self = self else { return }
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: AdvanceSettingViewController.identifier) as! AdvanceSettingViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }.disposed(by: cell.disposeBag)
                    return cell
                case .toogle(let viewModel):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: ToogleTableViewCell.identifier, for: indexPath) as? ToogleTableViewCell else { return UITableViewCell() }
                    cell.bind(to: viewModel)
                    return cell
                default: return UITableViewCell()
                }

            })
    }
}

// MARK: UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeightsDictionary[indexPath] = cell.frame.size.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeightsDictionary[indexPath] ?? UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingHeaderView.identifier) as? SettingHeaderView
        headerView?.titleLabel.text = L10n.basicSetting
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 73
    }
}
