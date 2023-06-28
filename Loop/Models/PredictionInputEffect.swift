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

    static let all: PredictionInputEffect = [.carbs, .insulin, .momentum, .retrospection]

    var localizedTitle: String? {
        switch self {
        case [.carbs]:
            return NSLocalizedString("碳水化合物", comment: "Title of the prediction input effect for carbohydrates")
        case [.insulin]:
            return NSLocalizedString("胰岛素", comment: "Title of the prediction input effect for insulin")
        case [.momentum]:
            return NSLocalizedString("葡萄糖动量", comment: "Title of the prediction input effect for glucose momentum")
        case [.retrospection]:
            return NSLocalizedString("回顾性校正", comment: "Title of the prediction input effect for retrospective correction")
        default:
            return nil
        }
    }

    func localizedDescription(forGlucoseUnit unit: HKUnit) -> String? {
        switch self {
        case [.carbs]:
            return String(format: NSLocalizedString("吸收的碳水化合物 (g) ÷ 碳水化合物比率 (g/U) × 胰岛素敏感性 (%1$@/U)", comment: "Description of the prediction input effect for carbohydrates. (1: The glucose unit string)"), unit.localizedShortUnitString)
        case [.insulin]:
            return String(format: NSLocalizedString("胰岛素吸收 (U) × 胰岛素敏感性 (%1$@/U)", comment: "Description of the prediction input effect for insulin"), unit.localizedShortUnitString)
        case [.momentum]:
            return NSLocalizedString("15分钟的葡萄糖回归系数（B₁），持续衰减30分钟", comment: "Description of the prediction input effect for glucose momentum")
        case [.retrospection]:
            return NSLocalizedString("30分钟的葡萄糖预测与实际的比较，持续衰减超过60分钟", comment: "Description of the prediction input effect for retrospective correction")
        default:
            return nil
        }
    }
}
