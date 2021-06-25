//
//  LedStripServiceImpl.swift
//  Sandsara
//
//  Created by Tín Phan on 30/11/2020.
//

import Foundation
import RxSwift
import RxCocoa

extension StringProtocol {
    var data: Data { .init(utf8) }
    var bytes: [UInt8] { .init(utf8) }
}

// MARK: Impl of Led strip service
class LedStripServiceImpl {
    static let shared = LedStripServiceImpl()
    
    
    /// Update custom palettte
    /// - Parameter colorString: Encoded data of color
    func uploadCustomPalette(colorString: Data) {
        var step = 0
        bluejay.run { sandsaraBoard -> Bool in
            do {
                try sandsaraBoard.write(to: LedStripService.uploadCustomPalette, value: colorString)
                step += 1
                print("step \(step)")

            } catch(let error) {
                print(error.localizedDescription)
            }
            return false
        } completionOnMainThread: { result in
            debugPrint(result)
            switch result {
            case .success:
                debugPrint("Write to sensor location is successful.\(result)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
