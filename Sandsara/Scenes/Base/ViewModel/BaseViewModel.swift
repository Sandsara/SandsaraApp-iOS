//
//  BaseViewModel.swift
//  Sandsara
//
//  Created by Tín Phan on 11/7/20.
//

import RxSwift
import RxCocoa

// MARK: Base protocol for ViewModel
protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    var inputs: Input { get }
    var outputs: Output! { get }

    var isLoading: Driver<Bool> { get }
    var onError: Driver<Error> { get }
    var disposeBag: DisposeBag { get }

    func transform()
    func viewModelDidBind()
}

protocol InputType {}
protocol OutputType {}
protocol DependencyType {}

class BaseViewModel<VMInput: InputType, VMOutput: OutputType>: ViewModelType {
    // MARK: Type contract
    typealias Input = VMInput
    typealias Output = VMOutput

    // MARK: Properties
    private let isLoadingSubject = PublishRelay<Bool>()
    private let errorSubject = PublishRelay<Error>()

    let inputs: Input
    private(set) var outputs: Output!
    let disposeBag = DisposeBag()

    // MARK: Methods
    init(inputs: Input) {
        self.inputs = inputs
        transform()
    }

    func transform() {}

    func viewModelDidBind() {}
}

// MARK: - Final Scope
extension BaseViewModel {
    final var isLoading: Driver<Bool> {
        return isLoadingSubject.asDriver(onErrorJustReturn: false)
    }

    final var onError: Driver<Error> {
        return errorSubject.asDriver(onErrorJustReturn: AppError(message: "This is an error !!!"))
    }

    final func emitEventLoading(_ value: Bool) {
        isLoadingSubject.accept(value)
    }

    final func emitEventError(_ error: Error) {
        errorSubject.accept(error)
    }

    final func setOutput(_ outputs: Output) {
        self.outputs = outputs
    }
}
