//
//  PredictionInputEffect.swift
//  Loop
//
//  Created by Nate Racklyeft on 9/4/16.
//  Copyright © 2016 Nathan Racklyeft. All rights reserved.
//

import Foundation
import HealthKit


struct PredictionInputEffect: OptionSet {
    let rawValue: Int

    static let carbs            = PredictionInputEffect(rawValue: 1 << 0)
    static let insulin          = PredictionInputEffect(rawValue: 1 << 1)
    static let momentum         = PredictionInputEffect(rawValue: 1 << 2)
    static let retrospection    = PredictionInputEffect(rawValue: 1 << 3)
    static let suspend          = PredictionInputEffect(rawValue: 1 << 4)

    static let all: PredictionInputEffect = [.carbs, .insulin, .momentum, .retrospection]

    var localizedTitle: String? {
        switch self {
        case [.carbs]:
            return NSLocalizedString("碳水化合物", comment: "Title of the prediction input effect for carbohydrates")
        case [.insulin]:
            return NSLocalizedString("胰岛素", comment: "Title of the prediction input effect for insulin")
        case [.momentum]:
            return NSLocalizedString("血糖动量", comment: "Title of the prediction input effect for glucose momentum")
        case [.retrospection]:
            return NSLocalizedString("回顾性校正", comment: "Title of the prediction input effect for retrospective correction")
        case [.suspend]:
            return NSLocalizedString("胰岛素递送的暂停", comment: "Title of the prediction input effect for suspension of insulin delivery")
        default:
            return nil
        }
    }

    func localizedDescription(forGlucoseUnit unit: HKUnit) -> String? {
        switch self {
        case [.carbs]:
            return String(format: NSLocalizedString("Carbs Absorbed (g) ÷ Carb Ratio (g/U) × Insulin Sensitivity (%1$@/U)", comment: "Description of the prediction input effect for carbohydrates. (1: The glucose unit string)"), unit.localizedShortUnitString)
        case [.insulin]:
            return String(format: NSLocalizedString("Insulin Absorbed (U) × Insulin Sensitivity (%1$@/U)", comment: "Description of the prediction input effect for insulin"), unit.localizedShortUnitString)
        case [.momentum]:
            return NSLocalizedString("15分钟的血糖回归系数（B₁），持续衰减30分钟", comment: "Description of the prediction input effect for glucose momentum")
        case [.retrospection]:
            return NSLocalizedString("30分钟的血糖预测与实际的比较，持续衰减超过60分钟", comment: "Description of the prediction input effect for retrospective correction")
        case [.suspend]:
             return NSLocalizedString("悬浮胰岛素输送的血糖作用", comment: "Description of the prediction input effect for suspension of insulin delivery")
        default:
            return nil
        }
    }
}
