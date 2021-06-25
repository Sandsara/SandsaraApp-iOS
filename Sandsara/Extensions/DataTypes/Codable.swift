//
//  Codable.swift
//  Sandsara
//
//  Created by Tín Phan on 11/7/20.
//

import Foundation

extension Encodable {
    /// Converting object to postable dictionary
    func toDictionary(_ encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        var json = [String: Any]()
        var data: Data = Data()
        do {
            data = try encoder.encode(self)
        } catch(let error) {
            throw error
        }

        do {
            json = try JSONSerialization.jsonObject(with: data) as? [String : Any] ?? [:]
        } catch(let error) {
            throw error
        }

        return json
    }

    func toData(_ encoder: JSONEncoder = JSONEncoder()) -> Data? {
        do {
            let data = try encoder.encode(self)

            let dict = try toDictionary(encoder)

            debugPrint(dict)

            debugPrint(data)

            return data
        } catch(let error) {
            print(error.localizedDescription)
            return nil
        }
    }
}

extension Decodable {
    typealias Dictionary = [AnyHashable: Any]
    static func toObject<Target>(type: Target.Type, from json: Dictionary) -> Target? where Target: Decodable {
        if let data = json.toData {
            do {
                let object = try JSONDecoder().decode(type, from: data)
                return object
            } catch let error {
                debugPrint(error.localizedDescription)
                return nil
            }
        }
        return nil
    }

    static func toObject<Target>(type: Target.Type, from data: Data) -> Target? where Target: Decodable {
        do {
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch {
            return nil
        }
    }
}

extension KeyedDecodingContainer {
    /// Decodes a value of the given type for the given key, if present.
    ///
    /// This method assigns this decoded value to variable.
    /// It will help to reduce alot of if statement in your code.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter key: The key that the decoded value is associated with.
    /// - parameter variable: variable will be assign when the key present with a value.
    /// - returns: No return.
    public func decodeIfPresent<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key, assignTo variable: inout T) where T: Decodable {
        if let value = try? decodeIfPresent(type.self, forKey: key) {
            variable = value
        }
    }
}
