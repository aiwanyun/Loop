//
//  NumberRangeEntry.swift
//  Learn
//
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import UIKit


class NumberRangeEntry: LessonSectionProviding {
    let headerTitle: String?

    var cells: [LessonCellProviding] {
        return numberCells
    }

    var minValue: NSNumber? {
        return numberCells.compactMap({ $0.number }).min()
    }

    var maxValue: NSNumber? {
        return numberCells.compactMap({ $0.number }).max()
    }

    var range: Range<NSNumber>? {
        guard let minValue = minValue, let maxValue = maxValue else {
            return nil
        }

        return minValue..<maxValue
    }

    var closedRange: ClosedRange<NSNumber>? {
        guard let minValue = minValue, let maxValue = maxValue else {
            return nil
        }

        return minValue...maxValue
    }

    private var numberCells: [NumberEntry]

    init(headerTitle: String?, minValue: NSNumber?, maxValue: NSNumber?, formatter: NumberFormatter, unitString: String?, keyboardType: UIKeyboardType) {
        self.headerTitle = headerTitle

        self.numberCells = [
            NumberEntry(
                number: minValue,
                formatter: formatter,
                placeholder: NSLocalizedString("最低限度", comment: "Placeholder for lower range entry"),
                unitString: unitString,
                keyboardType: keyboardType
            ),
            NumberEntry(
                number: maxValue,
                formatter: formatter,
                placeholder: NSLocalizedString("最大限度", comment: "Placeholder for upper range entry"),
                unitString: unitString,
                keyboardType: keyboardType
            ),
        ]
    }
}
