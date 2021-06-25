//
//  AppError.swift
//  Sandsara
//
//  Created by Tín Phan on 11/7/20.
//

import Foundation

struct AppError {
    let message: String

    init(message: String) {
        self.message = message
    }
}

extension AppError: LocalizedError {
    var errorDescription: String? { return message }
}
