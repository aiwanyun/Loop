//
//  GlucoseThresholdTableViewController.swift
//  Loop
//
//  Created by Pete Schwamb on 1/1/17.
//  Copyright © 2017 LoopKit Authors. All rights reserved.
//

import Foundation
import HealthKit
import LoopKit
import LoopKitUI
import UIKit

final class GlucoseThresholdTableViewController: TextFieldTableViewController {
    
    public let glucoseUnit: HKUnit
    
    init(threshold: Double?, glucoseUnit: HKUnit) {
        self.glucoseUnit = glucoseUnit
        
        super.init(style: .grouped)
        
        placeholder = NSLocalizedString("输入血糖安全极限", comment: "The placeholder text instructing users to enter a glucose safety limit")
        keyboardType = .decimalPad
        contextHelp = NSLocalizedString("当电流或预测的血糖低于血糖安全限制时，环路将不建议推注，并且始终建议每小时0单位的临时基础速率。", comment: "Explanation of glucose safety limit")

        let formatter = QuantityFormatter(for: glucoseUnit)

        unit = formatter.localizedUnitStringWithPlurality()

        if let threshold = threshold {
            value = formatter.numberFormatter.string(from: threshold)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
