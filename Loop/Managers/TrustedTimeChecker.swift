//
//  TrustedTimeChecker.swift
//  Loop
//
//  Created by Rick Pasetto on 10/14/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import LoopKit
import TrueTime
import UIKit

fileprivate extension UserDefaults {
    private enum Key: String {
        case detectedSystemTimeOffset = "com.loopkit.Loop.DetectedSystemTimeOffset"
    }
    
    var detectedSystemTimeOffset: TimeInterval? {
        get {
            return object(forKey: Key.detectedSystemTimeOffset.rawValue) as? TimeInterval
        }
        set {
            set(newValue, forKey: Key.detectedSystemTimeOffset.rawValue)
        }
    }
}

class TrustedTimeChecker {
    private let acceptableTimeDelta = TimeInterval.seconds(120)

    // For NTP time checking
    private var ntpClient: TrueTimeClient
    private weak var alertManager: AlertManager?
    private lazy var log = DiagnosticLog(category: "TrustedTimeChecker")

    var detectedSystemTimeOffset: TimeInterval {
        didSet {
            UserDefaults.standard.detectedSystemTimeOffset = detectedSystemTimeOffset
        }
    }

    init(alertManager: AlertManager? = nil) {
        ntpClient = TrueTimeClient.sharedInstance
        #if DEBUG
        if ntpClient.responds(to: #selector(setter: TrueTimeClient.logCallback)) {
            ntpClient.logCallback = { _ in }    // TrueTimeClient is a bit chatty in DEBUG build. This squelches all of its logging.
        }
        #endif
        ntpClient.start()
        self.alertManager = alertManager
        self.detectedSystemTimeOffset = UserDefaults.standard.detectedSystemTimeOffset ?? 0
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                               object: nil, queue: nil) { [weak self] _ in self?.checkTrustedTime() }
        NotificationCenter.default.addObserver(forName: .LoopRunning,
                                               object: nil, queue: nil) { [weak self] _ in self?.checkTrustedTime() }
        checkTrustedTime()
    }
    
    private func checkTrustedTime() {
        ntpClient.fetchIfNeeded(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(referenceTime):
                let deviceNow = Date()
                let ntpNow = referenceTime.now()
                let timeDelta = ntpNow.timeIntervalSince(deviceNow)

                if abs(timeDelta) > self.acceptableTimeDelta {
                    self.log.default("applicationSignificantTimeChange: ntpNow = %@, deviceNow = %@", ntpNow.debugDescription, deviceNow.debugDescription)
                    self.detectedSystemTimeOffset = timeDelta
                    self.issueTimeChangedAlert()
                } else {
                    self.detectedSystemTimeOffset = 0
                    self.retractTimeChangedAlert()
                }
            case let .failure(error):
                self.log.error("applicationSignificantTimeChange: Error getting NTP time: %@", error.localizedDescription)
            }
        })
    }

    private var alertIdentifier: Alert.Identifier {
        Alert.Identifier(managerIdentifier: "Loop", alertIdentifier: "significantTimeChange")
    }

    private func issueTimeChangedAlert() {
        let alertTitle = String(format: NSLocalizedString("%1$@ 时间设置需要注意的事项", comment: "Time change alert title"), UIDevice.current.model)
        let alertBody = String(format: NSLocalizedString("您的 %1$@ 的时间已更改。 %2$@ 需要准确的时间记录来预测您的血糖并相应地调整您的胰岛素。\n\n检查您的 %1$@ 设置（常规/日期和时间）并验证“自动设置”是否已打开。 如果解决失败，可能会导致严重的胰岛素输送不足或输送过多。", comment: "Time change alert body. (1: app name)"), UIDevice.current.model, Bundle.main.bundleDisplayName)
        let content = Alert.Content(title: alertTitle, body: alertBody, acknowledgeActionButtonLabel: NSLocalizedString("好的", comment: "Alert acknowledgment OK button"))
        alertManager?.issueAlert(Alert(identifier: alertIdentifier, foregroundContent: content, backgroundContent: content, trigger: .immediate))
    }

    private func retractTimeChangedAlert() {
        alertManager?.retractAlert(identifier: alertIdentifier)
    }
}
