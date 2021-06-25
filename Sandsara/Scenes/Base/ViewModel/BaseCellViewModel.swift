//
//  BaseCellViewModel.swift
//  HighJump
//
//  Created by Tin Phan Thanh on 10/2/19.
//  Copyright © 2019 VISA. All rights reserved.
//

import Foundation
import RxSwift

class BaseCellViewModel<VMInput: InputType, VMOutput: OutputType>: CellModelType {
    // MARK: Type contract
    typealias Input = VMInput
    typealias Output = VMOutput

    let inputs: Input
    private(set) var outputs: Output!
    let disposeBag = DisposeBag()

    // MARK: Methods
    init(inputs: Input) {
        self.inputs = inputs
        transform()
    }

    func transform() {

    }

    final func setOutput(_ outputs: Output) {
        self.outputs = outputs
    }
}
