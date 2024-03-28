//
//  KeyboardMetricsDataModel.swift
//
//
//  Created by Azeem Muzammil on 2024-02-05.
//

import Foundation

struct KeyboardMetricsData: DataStorable {
    static let source: DataSource = .keyboardMetrics
    static let headers: [String] = [
        "timestamp",
        "usageDuration",
        "inputModes",
        "noOfAlteredWordes",
        "noOfAutoCorrections",
        "noOfDeletes",
        "noOfDrags",
        "noOfEmojis",
        "noOfWordTyped",
        "noOfAbsolutistEmojis",
        "noOfAbsolutistWords",
        "noOfAngerEmojis",
        "noOfAngerRelatedWords",
        "noOfAnxietyEmojis",
        "noOfAnxietyRelatedWords",
        "noOfConfusedEmojis",
        "noOfConfusedRelatedWords",
        "noOfDeathEmojis",
        "noOfDeathRelatedWords",
        "noOfDownEmojis",
        "noOfDownRelatedWords",
        "noOfHealthFeelingEmojis",
        "noOfHealthFeelingRelatedWords",
        "noOfLowEnergyEmojis",
        "noOfLowEnergyRelatedWords",
        "noOfPositiveEmojis",
        "noOfPositiveRelatedWords",
        "noOfSadEmojis",
        "noOfSadRelatedWords",
        "typingTime",
        "tz"
    ]

    let timestamp: Int64
    let usageDuration: TimeInterval
    let inputModes: [String]?
    let noOfAlteredWordes: Int
    let noOfAutoCorrections: Int
    let noOfDeletes: Int
    let noOfDrags: Int
    let noOfEmojis: Int
    let noOfWordTyped: Int
    let noOfAbsolutistEmojis: Int?
    let noOfAbsolutistWords: Int?
    let noOfAngerEmojis: Int?
    let noOfAngerRelatedWords: Int?
    let noOfAnxietyEmojis: Int?
    let noOfAnxietyRelatedWords: Int?
    let noOfConfusedEmojis: Int?
    let noOfConfusedRelatedWords: Int?
    let noOfDeathEmojis: Int?
    let noOfDeathRelatedWords: Int?
    let noOfDownEmojis: Int?
    let noOfDownRelatedWords: Int?
    let noOfHealthFeelingEmojis: Int?
    let noOfHealthFeelingRelatedWords: Int?
    let noOfLowEnergyEmojis: Int?
    let noOfLowEnergyRelatedWords: Int?
    let noOfPositiveEmojis: Int?
    let noOfPositiveRelatedWords: Int?
    let noOfSadEmojis: Int?
    let noOfSadRelatedWords: Int?
    let typingTime: TimeInterval
    let tz: Int
}
