//
//  AlertManagementView.swift
//  Loop
//
//  Created by Nathaniel Hamming on 2022-09-09.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKit
import LoopKitUI

struct AlertManagementView: View {
    @Environment(\.appName) private var appName
    @Environment(\.guidanceColors) private var guidanceColors

    @ObservedObject private var checker: AlertPermissionsChecker
    @ObservedObject private var alertMuter: AlertMuter

    @State private var showMuteAlertOptions: Bool = false
    @State private var showHowMuteAlertWork: Bool = false

    private var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()

    private var formattedSelectedDuration: Binding<String> {
        Binding(
            get: { formatter.string(from: alertMuter.configuration.duration)! },
            set: { newValue in
                guard let selectedDurationIndex = formatterDurations.firstIndex(of: newValue)
                else { return }
                DispatchQueue.main.async {
                    // avoid publishing during view update
                    alertMuter.configuration.startTime = Date()
                    alertMuter.configuration.duration = AlertMuter.allowedDurations[selectedDurationIndex]
                }
            }
        )
    }

    private var formatterDurations: [String] {
        AlertMuter.allowedDurations.compactMap { formatter.string(from: $0) }
    }
    
    private var missedMealNotificationsEnabled: Binding<Bool> {
        Binding(
            get: { UserDefaults.standard.missedMealNotificationsEnabled },
            set: { enabled in
                UserDefaults.standard.missedMealNotificationsEnabled = enabled
            }
        )
    }

    public init(checker: AlertPermissionsChecker, alertMuter: AlertMuter = AlertMuter()) {
        self.checker = checker
        self.alertMuter = alertMuter
    }

    var body: some View {
        List {
            alertPermissionsSection
            if FeatureFlags.criticalAlertsEnabled {
                muteAlertsSection
            }
            if FeatureFlags.missedMealNotifications {
                missedMealAlertSection
            }
        }
        .navigationTitle(NSLocalizedString("警报管理", comment: "Title of alert management screen"))
    }
    
    private var footerView: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top, spacing: 8) {
                Image("phone")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 64, maxHeight: 64)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(
                        String(
                            format: NSLocalizedString(
                                "%1$@ APP SOUNDS",
                                comment: "App sounds title text (1: app name)"
                            ),
                            appName.uppercased()
                        )
                    )
                    
                    Text(
                        String(
                            format: NSLocalizedString(
                                "While mute alerts is on, all alerts from your %1$@ app including Critical and Time Sensitive alerts will temporarily display without sounds and will vibrate only.",
                                comment: "App sounds descriptive text (1: app name)"
                            ),
                            appName
                        )
                    )
                }
            }
            
            HStack(alignment: .top, spacing: 8) {
                Image("hardware")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 64, maxHeight: 64)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("硬件声音")
                    
                    Text("当静音警报打开时，您的胰岛素泵和CGM硬件仍然可能听起来。")
                }
            }
            
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "moon.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 64, maxHeight: 48)
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("iOS焦点模式")
                    
                    Text(
                        String(
                            format: NSLocalizedString(
                                "If iOS Focus Mode is ON and Mute Alerts is OFF, Critical Alerts will still be delivered and non-Critical Alerts will be silenced until %1$@ is added to each Focus mode as an Allowed App.",
                                comment: "Focus modes descriptive text (1: app name)"
                            ),
                            appName
                        )
                    )
                }
            }
        }
        .padding(.top)
    }

    private var alertPermissionsSection: some View {
        Section(footer: DescriptiveText(label: String(format: NSLocalizedString("Notifications give you important %1$@ app information without requiring you to open the app.", comment: "Alert Permissions descriptive text (1: app name)"), appName))) {
            NavigationLink(destination:
                            NotificationsCriticalAlertPermissionsView(mode: .flow, checker: checker))
            {
                HStack {
                    Text(NSLocalizedString("警报许可", comment: "Alert Permissions button text"))
                    if checker.showWarning ||
                        checker.notificationCenterSettings.scheduledDeliveryEnabled {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.critical)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var muteAlertsSection: some View {
        Section(footer: footerView) {
            if !alertMuter.configuration.shouldMute {
                howMuteAlertsWork
                Button(action: { showMuteAlertOptions = true }) {
                    HStack {
                        muteAlertIcon
                        Text(NSLocalizedString("静音所有警报", comment: "Label for button to mute all alerts"))
                    }
                }
                .actionSheet(isPresented: $showMuteAlertOptions) {
                   muteAlertOptionsActionSheet
                }
            } else {
                Button(action: alertMuter.unmuteAlerts) {
                    HStack {
                        unmuteAlertIcon
                        Text(NSLocalizedString("点击取消静音警报", comment: "Label for button to unmute all alerts"))
                    }
                }
                HStack {
                    Text(NSLocalizedString("所有警报都静音直到", comment: "Label for when mute alert will end"))
                    Spacer()
                    Text(alertMuter.formattedEndTime)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var muteAlertIcon: some View {
        Image(systemName: "speaker.slash.fill")
            .foregroundColor(.white)
            .padding(5)
            .background(guidanceColors.warning)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }

    private var unmuteAlertIcon: some View {
        Image(systemName: "speaker.wave.2.fill")
            .foregroundColor(.white)
            .padding(.vertical, 5)
            .padding(.horizontal, 2)
            .background(guidanceColors.warning)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }

    private var howMuteAlertsWork: some View {
        Button(action: { showHowMuteAlertWork = true }) {
            HStack {
                Text(NSLocalizedString("关于警报的常见问题", comment: "Label for link to see frequently asked questions"))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "info.circle")
                    .font(.body)
            }
        }
        .sheet(isPresented: $showHowMuteAlertWork) {
            HowMuteAlertWorkView()
        }
    }

    private var muteAlertOptionsActionSheet: ActionSheet {
        var muteAlertDurationOptions: [SwiftUI.Alert.Button] = formatterDurations.map { muteAlertDuration in
            .default(Text(muteAlertDuration),
                     action: { formattedSelectedDuration.wrappedValue =  muteAlertDuration })
        }
        muteAlertDurationOptions.append(.cancel())

        return ActionSheet(
            title: Text(NSLocalizedString("暂时静音所有警报", comment: "Title for mute alert duration selection action sheet")),
            message: Text(NSLocalizedString("静音时不会发出警报或警报。选择您想静音多长时间。", comment: "Message for mute alert duration selection action sheet")),
            buttons: muteAlertDurationOptions)
    }
    
    private var missedMealAlertSection: some View {
        Section(footer: DescriptiveText(label: NSLocalizedString("启用后，闭环在发现未登录的餐点时会通知您。", comment: "Description of missed meal notifications."))) {
            Toggle(NSLocalizedString("错过的通知", comment: "Title for missed meal notifications toggle"), isOn: missedMealNotificationsEnabled)
        }
    }
}

extension UserDefaults {
    private enum Key: String {
        case missedMealNotificationsEnabled = "com.loopkit.Loop.MissedMealNotificationsEnabled"
    }
    
    var missedMealNotificationsEnabled: Bool {
        get {
            return object(forKey: Key.missedMealNotificationsEnabled.rawValue) as? Bool ?? false
        }
        set {
            set(newValue, forKey: Key.missedMealNotificationsEnabled.rawValue)
        }
    }
}

struct AlertManagementView_Previews: PreviewProvider {
    static var previews: some View {
        AlertManagementView(checker: AlertPermissionsChecker(), alertMuter: AlertMuter())
    }
}
