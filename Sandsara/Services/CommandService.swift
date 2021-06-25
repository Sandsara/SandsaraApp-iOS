//
//  CommandService.swift
//  Sandsara
//
//  Created by Tín Phan on 30/11/2020.
//

import Bluejay

// MARK: Led Strip Service
struct LedStripService {
    private static let ledStripService = ServiceIdentifier(uuid: "fd31a2be-22e7-11eb-adc1-0242ac120002")

    static let ledStripSpeed = CharacteristicIdentifier(uuid: "1a9a7b7e-2305-11eb-adc1-0242ac120002",
                                                        service: ledStripService)

    static let selectPattle = CharacteristicIdentifier(uuid: "1a9a813c-2305-11eb-adc1-0242ac120002",
                                                       service: ledStripService)

    static let ledStripCycleEnable = CharacteristicIdentifier(uuid: "1a9a7dea-2305-11eb-adc1-0242ac120002",
                                                              service: ledStripService)

    static let ledStripDirection = CharacteristicIdentifier(uuid: "1a9a8042-2305-11eb-adc1-0242ac120002",
                                                            service: ledStripService)

    static let amountOfColors = CharacteristicIdentifier(uuid: "1a9a820e-2305-11eb-adc1-0242ac120002",
                                                         service: ledStripService)

    static let positions = CharacteristicIdentifier(uuid: "1a9a82d6-2305-11eb-adc1-0242ac120002",
                                                    service: ledStripService)

    static let red = CharacteristicIdentifier(uuid: "1a9a83a8-2305-11eb-adc1-0242ac120002",
                                              service: ledStripService)

    static let green = CharacteristicIdentifier(uuid: "1a9a8466-2305-11eb-adc1-0242ac120002",
                                                service: ledStripService)

    static let blue = CharacteristicIdentifier(uuid: "1a9a852e-2305-11eb-adc1-0242ac120002",
                                               service: ledStripService)

    static let uploadCustomPalette = CharacteristicIdentifier(uuid: "1a9a87b8-2305-11eb-adc1-0242ac120002",
                                                              service: ledStripService)

    static let notifyError = CharacteristicIdentifier(uuid: "1a9a8880-2305-11eb-adc1-0242ac120002",
                                                      service: ledStripService)

    static let brightness = CharacteristicIdentifier(uuid: "1a9a8948-2305-11eb-adc1-0242ac120002",
                                                     service: ledStripService)
}

// MARK: File Service
struct FileService {
    private static let fileService = ServiceIdentifier(uuid: "fd31abc4-22e7-11eb-adc1-0242ac120002")

    static let sendFileFlag = CharacteristicIdentifier(uuid: "fcbff68e-2af1-11eb-adc1-0242ac120002",
                                                       service: fileService)

    static let sendBytes = CharacteristicIdentifier(uuid: "fcbffa44-2af1-11eb-adc1-0242ac120002",
                                                    service: fileService)

    static let checkFileExist = CharacteristicIdentifier(uuid: "fcbffb52-2af1-11eb-adc1-0242ac120002",
                                                         service: fileService)

    static let deleteFile = CharacteristicIdentifier(uuid: "fcbffc24-2af1-11eb-adc1-0242ac120002",
                                                     service: fileService)

    static let receiveFileRespone = CharacteristicIdentifier(uuid: "fcbffce2-2af1-11eb-adc1-0242ac120002",
                                                             service: fileService)

    static let readFileFlag = CharacteristicIdentifier(uuid: "fcbffdaa-2af1-11eb-adc1-0242ac120002",
                                                       service: fileService)

    static let readFiles = CharacteristicIdentifier(uuid: "fcbffe72-2af1-11eb-adc1-0242ac120002",
                                                    service: fileService)
}

// MARK: Device Service
struct DeviceService {
    private static let deviceService = ServiceIdentifier(uuid: "fd31a840-22e7-11eb-adc1-0242ac120002")

    static let firmwareVersion = CharacteristicIdentifier(uuid: "7b204278-30c3-11eb-adc1-0242ac120002", service: deviceService)

    static let deviceName = CharacteristicIdentifier(uuid: "7b204548-30c3-11eb-adc1-0242ac120002", service: deviceService)

    static let deviceStatus = CharacteristicIdentifier(uuid: "7b204660-30c3-11eb-adc1-0242ac120002", service: deviceService)

    static let pause = CharacteristicIdentifier(uuid: "7b20473c-30c3-11eb-adc1-0242ac120002", service: deviceService)

    static let play = CharacteristicIdentifier(uuid: "7b20480e-30c3-11eb-adc1-0242ac120002", service: deviceService)

    static let sleep = CharacteristicIdentifier(uuid: "7b204a3e-30c3-11eb-adc1-0242ac120002", service: deviceService)

    static let speed = CharacteristicIdentifier(uuid: "7b204b10-30c3-11eb-adc1-0242ac120002", service: deviceService)

    static let restart = CharacteristicIdentifier(uuid: "7b204bce-30c3-11eb-adc1-0242ac120002", service: deviceService)

    static let factoryReset = CharacteristicIdentifier(uuid: "7b204c8c-30c3-11eb-adc1-0242ac120002", service: deviceService)

    static let notifyError = CharacteristicIdentifier(uuid: "9b12aa02-2c6e-11eb-adc1-0242ac120002", service: deviceService)
}

// MARK: Playlist Service
struct PlaylistService {
    private static let playlistService = ServiceIdentifier(uuid: "fd31a778-22e7-11eb-adc1-0242ac120002")

    static let playlistName = CharacteristicIdentifier(uuid: "9b12a048-2c6e-11eb-adc1-0242ac120002", service: playlistService)

    static let amountWithPathInsidePlaylist = CharacteristicIdentifier(uuid: "9b12a26e-2c6e-11eb-adc1-0242ac120002", service: playlistService)

    static let pathName = CharacteristicIdentifier(uuid: "9b12a534-2c6e-11eb-adc1-0242ac120002", service: playlistService)

    static let pathPosition = CharacteristicIdentifier(uuid: "9b12a62e-2c6e-11eb-adc1-0242ac120002", service: playlistService)

    static let addPath = CharacteristicIdentifier(uuid: "9b12a7be-2c6e-11eb-adc1-0242ac120002", service: playlistService)

    static let createPlaylist = CharacteristicIdentifier(uuid: "9b12a886-2c6e-11eb-adc1-0242ac120002", service: playlistService)

    static let progressOfPath = CharacteristicIdentifier(uuid: "9b12a944-2c6e-11eb-adc1-0242ac120002", service: playlistService)

    static let notifyError = CharacteristicIdentifier(uuid: "9b12aa02-2c6e-11eb-adc1-0242ac120002", service: playlistService)
}

