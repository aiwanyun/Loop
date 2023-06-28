//
//  BolusRecommendation.swift
//  Loop
//
//  Created by Pete Schwamb on 1/2/17.
//  Copyright © 2017 LoopKit Authors. All rights reserved.
//

import Foundation
import LoopKit
import HealthKit


extension BolusRecommendationNotice {
    public func description(using unit: HKUnit) -> String {
        switch self {
        case .glucoseBelowSuspendThreshold(minGlucose: let minGlucose):
            let glucoseFormatter = NumberFormatter.glucoseFormatter(for: unit)
            let bgStr = glucoseFormatter.string(from: minGlucose.quantity, unit: unit)!
            return String(format: NSLocalizedString("%1$@ 的预测血糖低于您的血糖安全限值设置。", comment: "Notice message when recommending bolus when BG is below the glucose safety limit. (1: glucose value)"), bgStr)
        case .currentGlucoseBelowTarget(glucose: let glucose):
            let glucoseFormatter = NumberFormatter.glucoseFormatter(for: unit)
            let bgStr = glucoseFormatter.string(from: glucose.quantity, unit: unit)!
            return String(format: NSLocalizedString("%1$@ 的当前血糖低于修正范围。", comment: "Message when offering bolus recommendation even though bg is below range. (1: glucose value)"), bgStr)
        case .predictedGlucoseBelowTarget(minGlucose: let minGlucose), .allGlucoseBelowTarget(minGlucose: let minGlucose):
            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short
            let time = timeFormatter.string(from: minGlucose.startDate)

            let glucoseFormatter = NumberFormatter.glucoseFormatter(for: unit)
            let minBGStr = glucoseFormatter.string(from: minGlucose.quantity, unit: unit)!
            return String(format: NSLocalizedString("%1$@ 的预测血糖为 %2$@。", comment: "Message when offering bolus recommendation even though bg is below range and minBG is in future. (1: glucose time)(2: glucose number)"), time, minBGStr)
        case .predictedGlucoseInRange:
            return NSLocalizedString("预测的葡萄糖在范围内。", comment: "Notice when predicted glucose for bolus recommendation is in range")
        }
    }
}

extension BolusRecommendationNotice: Equatable {
    public static func ==(lhs: BolusRecommendationNotice, rhs: BolusRecommendationNotice) -> Bool {
        switch (lhs, rhs) {
        case (.glucoseBelowSuspendThreshold, .glucoseBelowSuspendThreshold):
            return true

        case (.currentGlucoseBelowTarget, .currentGlucoseBelowTarget):
            return true

        case (let .predictedGlucoseBelowTarget(minGlucose1), let .predictedGlucoseBelowTarget(minGlucose2)):
            // GlucoseValue is not equatable
            return
                minGlucose1.startDate == minGlucose2.startDate &&
                minGlucose1.endDate == minGlucose2.endDate &&
                minGlucose1.quantity == minGlucose2.quantity

        case (.predictedGlucoseInRange, .predictedGlucoseInRange):
            return true

        default:
            return false
        }
    }
}


extension ManualBolusRecommendation: Comparable {
    public static func ==(lhs: ManualBolusRecommendation, rhs: ManualBolusRecommendation) -> Bool {
        return lhs.amount == rhs.amount
    }

    public static func <(lhs: ManualBolusRecommendation, rhs: ManualBolusRecommendation) -> Bool {
        return lhs.amount < rhs.amount
    }
}

