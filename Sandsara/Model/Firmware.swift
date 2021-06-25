//
//  Firmware.swift
//  Sandsara
//
//  Created by Tín Phan on 31/12/2020.
//

import Foundation

class FirmwaresResponse: Decodable {
    var firmwares: [FirmwareResponse] = []

    enum CodingKeys: String, CodingKey {
        case records
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        container.decodeIfPresent([FirmwareResponse].self, forKey: .records, assignTo: &firmwares)
    }
}

class FirmwareResponse: Decodable {
    var firmware: Firmware = Firmware()

    enum CodingKeys: String, CodingKey {
        case fields
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        container.decodeIfPresent(Firmware.self, forKey: .fields, assignTo: &firmware)
    }
}

class Firmware: Codable {
    var version: String = ""
    var file: [File]?

    enum CodingKeys: String, CodingKey {
        case version
        case file
    }

    init() {}

    required init(from decoder: Decoder) throws {
        let fieldContainer = try decoder.container(keyedBy: CodingKeys.self)
        fieldContainer.decodeIfPresent(String.self, forKey: .version, assignTo: &version)
        if let file = try fieldContainer.decodeIfPresent([File].self, forKey: .file) {
            self.file = file
        }
    }

    func encode(to encoder: Encoder) throws {
        var nestedContainer = encoder.container(keyedBy: CodingKeys.self)
        try nestedContainer.encode(version, forKey: .version)
        try nestedContainer.encode(file, forKey: .file)
    }
}
