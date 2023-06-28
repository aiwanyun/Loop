//
//  SimpleBolusView.swift
//  Loop
//
//  Created by Pete Schwamb on 9/23/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKit
import LoopKitUI
import HealthKit
import LoopCore

struct SimpleBolusView: View {
    @EnvironmentObject private var displayGlucosePreference: DisplayGlucosePreference
    @Environment(\.dismissAction) var dismiss
    
    @State private var shouldBolusEntryBecomeFirstResponder = false
    @State private var isKeyboardVisible = false
    @State private var isClosedLoopOffInformationalModalVisible = false

    @ObservedObject var viewModel: SimpleBolusViewModel

    private var enteredManualGlucose: Binding<String> {
        Binding(
            get: { return viewModel.manualGlucoseString },
            set: { newValue in viewModel.manualGlucoseString = newValue }
        )
    }

    init(viewModel: SimpleBolusViewModel) {
        self.viewModel = viewModel
    }
    
    var title: String {
        if viewModel.displayMealEntry {
            return NSLocalizedString("简单的进餐计算器", comment: "Title of simple bolus view when displaying meal entry")
        } else {
            return NSLocalizedString("简单的推注计算器", comment: "Title of simple bolus view when not displaying meal entry")
        }
    }
        
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                List() {
                    self.infoSection
                    self.summarySection
                }
                // As of iOS 13, we can't programmatically scroll to the Bolus entry text field.  This ugly hack scoots the
                // list up instead, so the summarySection is visible and the keyboard shows when you tap "Enter Bolus".
                // Unfortunately, after entry, the field scoots back down and remains hidden.  So this is not a great solution.
                // TODO: Fix this in Xcode 12 when we're building for iOS 14.
                .padding(.top, self.shouldAutoScroll(basedOn: geometry) ? -200 : 0)
                .insetGroupedListStyle()
                .navigationBarTitle(Text(self.title), displayMode: .inline)
                
                self.actionArea
                    .frame(height: self.isKeyboardVisible ? 0 : nil)
                    .opacity(self.isKeyboardVisible ? 0 : 1)
            }
            .onKeyboardStateChange { state in
                self.isKeyboardVisible = state.height > 0
                
                if state.height == 0 {
                    // Ensure tapping 'Enter Bolus' can make the text field the first responder again
                    self.shouldBolusEntryBecomeFirstResponder = false
                }
            }
            .keyboardAware()
            .edgesIgnoringSafeArea(self.isKeyboardVisible ? [] : .bottom)
            .alert(item: self.$viewModel.activeAlert, content: self.alert(for:))
        }
    }
    
    private func formatGlucose(_ quantity: HKQuantity) -> String {
        return displayGlucosePreference.format(quantity)
    }
    
    private func shouldAutoScroll(basedOn geometry: GeometryProxy) -> Bool {
        // Taking a guess of 640 to cover iPhone SE, iPod Touch, and other smaller devices.
        // Devices such as the iPhone 11 Pro Max do not need to auto-scroll.
        shouldBolusEntryBecomeFirstResponder && geometry.size.height < 640
    }
    
    private var infoSection: some View {
        HStack {
            Image("Open Loop")
            Text("当不闭环模式出现时，该应用程序使用简化的推注计算器，例如典型的泵。")
                .font(.footnote)
                .foregroundColor(.secondary)
            infoButton
        }
    }
    
    private var infoButton: some View {
        Button(
            action: {
                self.viewModel.activeAlert = .infoPopup
            },
            label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 25))
                    .foregroundColor(.accentColor)
            }
        )
    }
    
    private var summarySection: some View {
        Section {
            if viewModel.displayMealEntry {
                carbEntryRow
            }
            glucoseEntryRow
            recommendedBolusRow
            bolusEntryRow
        }
    }
    
    private var carbEntryRow: some View {
        HStack(alignment: .center) {
            Text("碳水化合物", comment: "Label for carbohydrates entry row on simple bolus screen")
            Spacer()
            HStack {
                DismissibleKeyboardTextField(
                    text: $viewModel.enteredCarbString,
                    placeholder: viewModel.carbPlaceholder,
                    textAlignment: .right,
                    keyboardType: .decimalPad,
                    maxLength: 5,
                    doneButtonColor: .loopAccent
                )
                carbUnitsLabel
            }
            .padding([.top, .bottom], 5)
            .fixedSize()
            .modifier(LabelBackground())
        }
    }

    private var glucoseEntryRow: some View {
        HStack {
            Text("电流葡萄糖", comment: "Label for glucose entry row on simple bolus screen")
            Spacer()
            HStack(alignment: .firstTextBaseline) {
                DismissibleKeyboardTextField(
                    text: enteredManualGlucose,
                    placeholder: NSLocalizedString(" -   -   - ", comment: "No glucose value representation (3 dashes for mg/dL)"),
                    font: .heavy(.title1),
                    textAlignment: .right,
                    keyboardType: .decimalPad,
                    maxLength: 4,
                    doneButtonColor: .loopAccent
                )

                glucoseUnitsLabel
            }
            .fixedSize()
            .modifier(LabelBackground())
        }
    }
    
    private var recommendedBolusRow: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("推荐的推注", comment: "Label for recommended bolus row on simple bolus screen")
                Spacer()
                HStack(alignment: .firstTextBaseline) {
                    Text(viewModel.recommendedBolus)
                        .font(.title)
                        .foregroundColor(Color(.label))
                        .padding([.top, .bottom], 4)
                    bolusUnitsLabel
                }
            }
            .padding(.trailing, 8)
            if let activeInsulin = viewModel.activeInsulin {
                HStack(alignment: .center, spacing: 3) {
                    Text("调整")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text("活性胰岛素")
                        .font(.footnote)
                        .bold()
                    Text(activeInsulin)
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.secondary)
                    bolusUnitsLabel
                        .font(.footnote)
                        .bold()
                }
            }
        }
    }
    
    private var bolusEntryRow: some View {
        HStack {
            Text("推注", comment: "Label for bolus entry row on simple bolus screen")
            Spacer()
            HStack(alignment: .firstTextBaseline) {
                DismissibleKeyboardTextField(
                    text: $viewModel.enteredBolusString,
                    placeholder: "",
                    font: .preferredFont(forTextStyle: .title1),
                    textColor: .loopAccent,
                    textAlignment: .right,
                    keyboardType: .decimalPad,
                    shouldBecomeFirstResponder: shouldBolusEntryBecomeFirstResponder,
                    maxLength: 5,
                    doneButtonColor: .loopAccent
                )
                
                bolusUnitsLabel
            }
            .fixedSize()
            .modifier(LabelBackground())
        }
    }

    private var carbUnitsLabel: some View {
        Text(QuantityFormatter(for: .gram()).localizedUnitStringWithPlurality())
    }
    
    private var glucoseUnitsLabel: some View {
        Text(displayGlucosePreference.formatter.localizedUnitStringWithPlurality())
            .fixedSize()
            .foregroundColor(Color(.secondaryLabel))
    }

    private var bolusUnitsLabel: Text {
        Text(QuantityFormatter(for: .internationalUnit()).localizedUnitStringWithPlurality())
            .foregroundColor(Color(.secondaryLabel))
    }

    private var actionArea: some View {
        VStack(spacing: 0) {
            if viewModel.isNoticeVisible {
                warning(for: viewModel.activeNotice!)
                    .padding([.top, .horizontal])
                    .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
            }
            actionButton
        }
        .background(Color(.secondarySystemGroupedBackground).shadow(radius: 5))
    }
    
    private var actionButton: some View {
        Button<Text>(
            action: {
                if self.viewModel.actionButtonAction == .enterBolus {
                    self.shouldBolusEntryBecomeFirstResponder = true
                } else {
                    self.viewModel.saveAndDeliver { (success) in
                        if success {
                            self.dismiss()
                        }
                    }
    
                }
            },
            label: {
                switch viewModel.actionButtonAction {
                case .saveWithoutBolusing:
                    return Text("保存而无需加油", comment: "Button text to save carbs and/or manual glucose entry without a bolus")
                case .saveAndDeliver:
                    return Text("保存和交付", comment: "Button text to save carbs and/or manual glucose entry and deliver a bolus")
                case .enterBolus:
                    return Text("输入牛肉", comment: "Button text to begin entering a bolus")
                case .deliver:
                    return Text("递送", comment: "Button text to deliver a bolus")
                }
            }
        )
        .disabled(viewModel.actionButtonDisabled)
        .buttonStyle(ActionButtonStyle(.primary))
        .padding()
    }
    
    private func alert(for alert: SimpleBolusViewModel.Alert) -> SwiftUI.Alert {
        switch alert {
        case .carbEntryPersistenceFailure:
            return SwiftUI.Alert(
                title: Text("无法保存碳水化合物条目", comment: "Alert title for a carb entry persistence error"),
                message: Text("试图保存碳水化合物条目时发生了错误。", comment: "Alert message for a carb entry persistence error")
            )
        case .manualGlucoseEntryPersistenceFailure:
            return SwiftUI.Alert(
                title: Text("无法保存手动葡萄糖输入", comment: "Alert title for a manual glucose entry persistence error"),
                message: Text("试图保存您的手动葡萄糖输入时发生了错误。", comment: "Alert message for a manual glucose entry persistence error")
            )
        case .infoPopup:
            return closedLoopOffInformationalModal()
        }
        
    }
        
    private func warning(for notice: SimpleBolusViewModel.Notice) -> some View {
        
        switch notice {
        case .glucoseBelowSuspendThreshold:
            let title: Text
            if viewModel.bolusRecommended {
                title = Text("低葡萄糖", comment: "Title for bolus screen warning when glucose is below suspend threshold, but a bolus is recommended")
            } else {
                title = Text("不建议推注", comment: "Title for bolus screen warning when glucose is below suspend threshold, and a bolus is not recommended")
            }
            let suspendThresholdString = formatGlucose(viewModel.suspendThreshold)
            return WarningView(
                title: title,
                caption: Text(String(format: NSLocalizedString("您的血糖低于您的血糖安全限值，%1$@。", comment: "Format string for bolus screen warning when no bolus is recommended due input value below glucose safety limit. (1: suspendThreshold)"), suspendThresholdString))
            )
        case .glucoseWarning:
            let warningThresholdString = formatGlucose(LoopConstants.simpleBolusCalculatorGlucoseWarningLimit)
            return WarningView(
                title: Text("低葡萄糖", comment: "Title for bolus screen warning when glucose is below glucose warning limit."),
                caption: Text(String(format: NSLocalizedString("您的血糖低于%1$@。 您确定要推注吗？", comment: "Format string for simple bolus screen warning when glucose is below glucose warning limit."), warningThresholdString))
            )
        case .glucoseBelowRecommendationLimit:
            let caption: String
            if viewModel.displayMealEntry {
                caption = NSLocalizedString("您的葡萄糖很低。吃碳水化合物并考虑等待推注，直到您的葡萄糖处于安全范围为止。", comment: "Format string for meal bolus screen warning when no bolus is recommended due to glucose input value below recommendation threshold")
            } else {
                caption = NSLocalizedString("您的葡萄糖很低。吃碳水化合物并密切监测。", comment: "Bolus screen warning when no bolus is recommended due to glucose input value below recommendation threshold for meal bolus")
            }
            return WarningView(
                title: Text("不建议推注", comment: "Title for bolus screen warning when no bolus is recommended"),
                caption: Text(caption)
            )
        case .glucoseOutOfAllowedInputRange:
            let glucoseMinString = formatGlucose(LoopConstants.validManualGlucoseEntryRange.lowerBound)
            let glucoseMaxString = formatGlucose(LoopConstants.validManualGlucoseEntryRange.upperBound)
            return WarningView(
                title: Text("葡萄糖进入范围", comment: "Title for bolus screen warning when glucose entry is out of range"),
                caption: Text(String(format: NSLocalizedString("手动葡萄糖输入必须介于 %1$@ 和 %2$@ 之间。", comment: "Warning for simple bolus when glucose entry is out of range. (1: upper bound) (2: lower bound)"), glucoseMinString, glucoseMaxString)))
        case .maxBolusExceeded:
            return WarningView(
                title: Text("最大推注超过", comment: "Title for bolus screen warning when max bolus is exceeded"),
                caption: Text(String(format: NSLocalizedString("您的最大推注量为%1$@。", comment: "Warning for simple bolus when max bolus is exceeded. (1: maximum bolus)"), viewModel.maximumBolusAmountString )))
        case .recommendationExceedsMaxBolus:
            return WarningView(
                title: Text("推荐的推注超过最大推注", comment: "Title for bolus screen warning when recommended bolus exceeds max bolus"),
                caption: Text(String(format: NSLocalizedString("您推荐的推注量超过了最大推注量 %1$@。", comment: "Warning for simple bolus when recommended bolus exceeds max bolus. (1: maximum bolus)"), viewModel.maximumBolusAmountString )))
        case .carbohydrateEntryTooLarge:
            let maximumCarbohydrateString = QuantityFormatter(for: .gram()).string(from: LoopConstants.maxCarbEntryQuantity)!
            return WarningView(
                title: Text("碳水化合物入口太大", comment: "Title for bolus screen warning when carbohydrate entry is too large"),
                caption: Text(String(format: NSLocalizedString("允许的最大量为%1$@。", comment: "Warning for simple bolus when carbohydrate entry is too large. (1: maximum carbohydrate entry)"), maximumCarbohydrateString)))
        }
    }
    
    private func closedLoopOffInformationalModal() -> SwiftUI.Alert {
        return SwiftUI.Alert(
            title: Text("关闭循环", comment: "Alert title for closed loop off informational modal"),
            message: Text(String(format: NSLocalizedString("%1$@ 在关闭位置闭环运行。 您的泵和 CGM 将继续运行，但应用程序不会自动调整剂量。", comment: "Alert message for closed loop off informational modal. (1: app name)"), Bundle.main.bundleDisplayName))
        )
    }

}


struct SimpleBolusCalculatorView_Previews: PreviewProvider {
    class MockSimpleBolusViewDelegate: SimpleBolusViewModelDelegate {
        func addGlucose(_ samples: [NewGlucoseSample], completion: @escaping (Swift.Result<[StoredGlucoseSample], Error>) -> Void) {
            completion(.success([]))
        }
        
        func addCarbEntry(_ carbEntry: NewCarbEntry, replacing replacingEntry: StoredCarbEntry?, completion: @escaping (Result<StoredCarbEntry>) -> Void) {
            
            let storedCarbEntry = StoredCarbEntry(
                uuid: UUID(),
                provenanceIdentifier: UUID().uuidString,
                syncIdentifier: UUID().uuidString,
                syncVersion: 1,
                startDate: carbEntry.startDate,
                quantity: carbEntry.quantity,
                foodType: carbEntry.foodType,
                absorptionTime: carbEntry.absorptionTime,
                createdByCurrentApp: true,
                userCreatedDate: Date(),
                userUpdatedDate: nil)
            completion(.success(storedCarbEntry))
        }
        
        func enactBolus(units: Double, activationType: BolusActivationType) {
        }
        
        func insulinOnBoard(at date: Date, completion: @escaping (DoseStoreResult<InsulinValue>) -> Void) {
            completion(.success(InsulinValue(startDate: date, value: 2.0)))
        }
        
        func computeSimpleBolusRecommendation(at date: Date, mealCarbs: HKQuantity?, manualGlucose: HKQuantity?) -> BolusDosingDecision? {
            var decision = BolusDosingDecision(for: .simpleBolus)
            decision.manualBolusRecommendation = ManualBolusRecommendationWithDate(recommendation: ManualBolusRecommendation(amount: 3, pendingInsulin: 0),
                                                                                   date: Date())
            return decision
        }
        
        func storeManualBolusDosingDecision(_ bolusDosingDecision: BolusDosingDecision, withDate date: Date) {
        }
        
        var displayGlucosePreference: DisplayGlucosePreference {
            return DisplayGlucosePreference(displayGlucoseUnit: .milligramsPerDeciliter)
        }
        
        var maximumBolus: Double {
            return 6
        }
        
        var suspendThreshold: HKQuantity {
            return HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 75)
        }
    }

    static var viewModel: SimpleBolusViewModel = SimpleBolusViewModel(delegate: MockSimpleBolusViewDelegate(), displayMealEntry: true)
    
    static var previews: some View {
        NavigationView {
            SimpleBolusView(viewModel: viewModel)
        }
        .previewDevice("iPod touch (7th generation)")
        .environmentObject(DisplayGlucosePreference(displayGlucoseUnit: .milligramsPerDeciliter))
    }
}
