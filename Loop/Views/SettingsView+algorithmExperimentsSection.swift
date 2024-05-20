//
//  SettingsView+algorithmExperimentsSection.swift
//  Loop
//
//  Created by Jonas Björkert on 2023-06-03.
//  Copyright © 2023 LoopKit Authors. All rights reserved.
//

import Foundation
import SwiftUI
import LoopKit
import LoopKitUI

extension SettingsView {
    internal var algorithmExperimentsSection: some View {
        NavigationLink(NSLocalizedString("算法实验", comment: "The title of the Algorithm Experiments section in settings")) {
            ExperimentsSettingsView(automaticDosingStrategy: viewModel.automaticDosingStrategy)
        }
    }
}

public struct ExperimentRow: View {
    var name: String
    var enabled: Bool

    public var body: some View {
        HStack {
            Text(name)
                .foregroundColor(.primary)
            Spacer()
            Text(enabled ? "On" : "Off")
                .foregroundColor(enabled ? .red : .secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .foregroundColor(.accentColor)
        .cornerRadius(10)
    }
}

public struct ExperimentsSettingsView: View {
    @State private var isGlucoseBasedApplicationFactorEnabled = UserDefaults.standard.glucoseBasedApplicationFactorEnabled
    @State private var isIntegralRetrospectiveCorrectionEnabled = UserDefaults.standard.integralRetrospectiveCorrectionEnabled
    var automaticDosingStrategy: AutomaticDosingStrategy

    public var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 12) {
                Text(NSLocalizedString("算法实验", comment: "Navigation title for algorithms experiments screen"))
                    .font(.headline)
                VStack {
                    Text("⚠️").font(.largeTitle)
                    Text("警告")
                }
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    Text(NSLocalizedString("算法实验是对闭环算法的可选修改。这些修改的测试要比标准闭环算法少，因此请仔细使用。", comment: "Algorithm Experiments description."))
                    Text(NSLocalizedString("在将来的闭环版本中，这些实验可能会改变，最终以闭环算法的标准部分最终形式，或者完全从闭环中删除。请继续进行闭环Zulip聊天，以了解这些功能可能更改的情况。", comment: "Algorithm Experiments description second paragraph."))
                }
                .foregroundColor(.secondary)

                Divider()
                NavigationLink(destination: GlucoseBasedApplicationFactorSelectionView(isGlucoseBasedApplicationFactorEnabled: $isGlucoseBasedApplicationFactorEnabled, automaticDosingStrategy: automaticDosingStrategy)) {
                    ExperimentRow(
                        name: NSLocalizedString("基于血糖的部分应用", comment: "Title of glucose based partial application experiment"),
                        enabled: isGlucoseBasedApplicationFactorEnabled && automaticDosingStrategy == .automaticBolus)
                }
                NavigationLink(destination: IntegralRetrospectiveCorrectionSelectionView(isIntegralRetrospectiveCorrectionEnabled: $isIntegralRetrospectiveCorrectionEnabled)) {
                    ExperimentRow(
                        name: NSLocalizedString("整体回顾性校正", comment: "Title of integral retrospective correction experiment"),
                        enabled: isIntegralRetrospectiveCorrectionEnabled)
                }
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}


extension UserDefaults {
    private enum Key: String {
        case GlucoseBasedApplicationFactorEnabled = "com.loopkit.algorithmExperiments.glucoseBasedApplicationFactorEnabled"
        case IntegralRetrospectiveCorrectionEnabled = "com.loopkit.algorithmExperiments.integralRetrospectiveCorrectionEnabled"
    }

    var glucoseBasedApplicationFactorEnabled: Bool {
        get {
            bool(forKey: Key.GlucoseBasedApplicationFactorEnabled.rawValue) as Bool
        }
        set {
            set(newValue, forKey: Key.GlucoseBasedApplicationFactorEnabled.rawValue)
        }
    }

    var integralRetrospectiveCorrectionEnabled: Bool {
        get {
            bool(forKey: Key.IntegralRetrospectiveCorrectionEnabled.rawValue) as Bool
        }
        set {
            set(newValue, forKey: Key.IntegralRetrospectiveCorrectionEnabled.rawValue)
        }
    }

}
