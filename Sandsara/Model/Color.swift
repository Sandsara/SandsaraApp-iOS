//
//  Color.swift
//  Sandsara
//
//  Created by Tín Phan on 20/12/2020.
//

import Foundation
import UIKit

struct ColorsResponse: Decodable {
    var colors: [ColorResponse] = []

    enum CodingKeys: String, CodingKey {
        case records
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        container.decodeIfPresent([ColorResponse].self, forKey: .records, assignTo: &colors)
    }
}

struct ColorModel: Codable {
    var position: [Int] = []
    var colors: [String] = []
}

struct ColorResponse: Decodable {
    var color: ColorModel = ColorModel()

    var position: [Int] = []
    var red: [Int] = []
    var green: [Int] = []
    var blue: [Int] = []

    enum CodingKeys: String, CodingKey {
        case fields
        case position
        case red
        case green
        case blue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nestedContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .fields)

        if let position = try nestedContainer.decodeIfPresent(String.self, forKey: .position) {
            self.position = position.components(separatedBy: ",").map { Int($0) ?? 0 }
        }

        if let position = try nestedContainer.decodeIfPresent(String.self, forKey: .red) {
            self.red = position.components(separatedBy: ",").map { Int($0) ?? 0 }
        }

        if let position = try nestedContainer.decodeIfPresent(String.self, forKey: .blue) {
            self.blue = position.components(separatedBy: ",").map { Int($0) ?? 0 }
        }

        if let position = try nestedContainer.decodeIfPresent(String.self, forKey: .green) {
            self.green = position.components(separatedBy: ",").map { Int($0) ?? 0 }
        }

        let colors = zip3(red, green, blue).map {
            RGBA(red: CGFloat($0.0) / 255, green: CGFloat($0.1) / 255, blue: CGFloat($0.2) / 255).color().hexString()
        }
        color = ColorModel(position: position, colors: colors)
    }
}

struct Zip3Sequence<E1, E2, E3>: Sequence, IteratorProtocol {
    private let _next: () -> (E1, E2, E3)?

    init<S1: Sequence, S2: Sequence, S3: Sequence>(_ s1: S1, _ s2: S2, _ s3: S3) where S1.Element == E1, S2.Element == E2, S3.Element == E3 {
        var it1 = s1.makeIterator()
        var it2 = s2.makeIterator()
        var it3 = s3.makeIterator()
        _next = {
            guard let e1 = it1.next(), let e2 = it2.next(), let e3 = it3.next() else { return nil }
            return (e1, e2, e3)
        }
    }

    mutating func next() -> (E1, E2, E3)? {
        return _next()
    }
}

func zip3<S1: Sequence, S2: Sequence, S3: Sequence>(_ s1: S1, _ s2: S2, _ s3: S3) -> Zip3Sequence<S1.Element, S2.Element, S3.Element> {
    return Zip3Sequence(s1, s2, s3)
}
