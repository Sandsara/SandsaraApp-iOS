//
//  SerialQueue.swift
//  Sandsara
//
//  Created by Tín Phan on 15/12/2020.
//

import Foundation

typealias Action = (() -> Void)

typealias ServiceSerialQueueTask = ((@escaping Action) -> Bool)

// MARK: -

enum ServiceSerialQueueUseCase: String {
    case syncFiles
}

// MARK: -

final class ServiceSerialQueue {

    // MARK: - Properties

    static let shared = ServiceSerialQueue()

    private let queue: DispatchQueue
    private let semaphore = DispatchSemaphore(value: 0)
    private var callbackDict = [ServiceSerialQueueUseCase: Bool]()

    // MARK: - Initialization
    init() {
        self.queue = DispatchQueue(label: "_\(String(describing: ServiceSerialQueue.self))")
    }

    // MARK: - Public Methods
    
    /// <#Description#>
    /// - Parameters:
    ///   - useCase: add use case to use
    ///   - task:Put closure after the task is completed
    func addTask(_ useCase: ServiceSerialQueueUseCase,
                 task: @escaping ServiceSerialQueueTask) {
        queue.async { [weak self] in
            guard let self = self,
                  self.callbackDict[useCase] == true,
                  task({ self.semaphore.signal() }) else { return }
            self.semaphore.wait()
        }
    }

    func cancel(_ useCase: ServiceSerialQueueUseCase) {
        callbackDict[useCase] = false
    }
}
