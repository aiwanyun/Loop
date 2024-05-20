//
//  CrashRecoveryManager.swift
//  Loop
//
//  Created by Pete Schwamb on 9/17/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import Foundation
import LoopKit

class CrashRecoveryManager {

    private let log = DiagnosticLog(category: "CrashRecoveryManager")

    let managerIdentifier = "CrashRecoveryManager"

    private let crashAlertIdentifier = "CrashAlert"

    var doseRecoveredFromCrash: AutomaticDoseRecommendation?

    let alertIssuer: AlertIssuer

    var pendingCrashRecovery: Bool {
        return doseRecoveredFromCrash != nil
    }

    init(alertIssuer: AlertIssuer) {
        self.alertIssuer = alertIssuer

        doseRecoveredFromCrash = UserDefaults.appGroup?.inFlightAutomaticDose

        if doseRecoveredFromCrash != nil {
            issueCrashAlert()
        }
    }

    func dosingStarted(dose: AutomaticDoseRecommendation) {
        UserDefaults.appGroup?.inFlightAutomaticDose = dose
    }

    func dosingFinished() {
        UserDefaults.appGroup?.inFlightAutomaticDose = nil
    }

    private func issueCrashAlert() {
        let title = NSLocalizedString("闭环崩溃了", comment: "Title for crash recovery alert")
        let modalBody = NSLocalizedString("不好了！给药时环崩溃了，胰岛素调整已暂停，直到关闭此对话框为止。剂量历史可能不准确。请查看胰岛素输送图，并仔细监测您的血糖。", comment: "Modal body for crash recovery alert")
        let modalContent = Alert.Content(title: title,
                                         body: modalBody,
                                         acknowledgeActionButtonLabel: NSLocalizedString("继续", comment: "Default alert dismissal"))
        let notificationBody = NSLocalizedString("胰岛素调整已被禁用！", comment: "Notification body for crash recovery alert")
        let notificationContent = Alert.Content(title: title,
                                                body: notificationBody,
                                                acknowledgeActionButtonLabel: NSLocalizedString("继续", comment: "Default alert dismissal"))

        let identifier = Alert.Identifier(managerIdentifier: managerIdentifier, alertIdentifier: crashAlertIdentifier)

        let alert = Alert(identifier: identifier,
                         foregroundContent: modalContent,
                         backgroundContent: notificationContent,
                         trigger: .immediate,
                         interruptionLevel: .critical)

        self.alertIssuer.issueAlert(alert)
    }
}

extension CrashRecoveryManager: AlertResponder {
    func acknowledgeAlert(alertIdentifier: LoopKit.Alert.AlertIdentifier, completion: @escaping (Error?) -> Void) {
        UserDefaults.appGroup?.inFlightAutomaticDose = nil
        doseRecoveredFromCrash = nil
    }
}

