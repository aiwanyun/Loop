//
//  DeliveryUncertaintyAlertManager.swift
//  Loop
//
//  Created by Pete Schwamb on 8/31/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import Foundation
import UIKit
import LoopKitUI

class DeliveryUncertaintyAlertManager {
    private let pumpManager: PumpManagerUI
    private let alertPresenter: AlertPresenter
    private var uncertainDeliveryAlert: UIAlertController?

    init(pumpManager: PumpManagerUI, alertPresenter: AlertPresenter) {
        self.pumpManager = pumpManager
        self.alertPresenter = alertPresenter
    }

    private func showUncertainDeliveryRecoveryView() {
        var controller = pumpManager.deliveryUncertaintyRecoveryViewController(colorPalette: .default, allowDebugFeatures: FeatureFlags.allowDebugFeatures)
        controller.completionDelegate = self
        self.alertPresenter.present(controller, animated: true)
    }
    
    func showAlert(animated: Bool = true) {
        if self.uncertainDeliveryAlert == nil {
            let alert = UIAlertController(
                title: NSLocalizedString("无法到达泵", comment: "Title for alert shown when delivery status is uncertain"),
                message: String(format: NSLocalizedString("%1$@ 无法与您的胰岛素泵通信。 应用程序将继续尝试到达您的泵，但无法更新胰岛素输送信息，并且无法继续实现自动化。\n您可以等待几分钟，看看问题是否得到解决，或点击下面的按钮以了解有关其他选项的更多信息。", comment: "Message for alert shown when delivery status is uncertain. (1: app name)"), Bundle.main.bundleDisplayName),
                preferredStyle: .alert)
            
            let actionTitle = NSLocalizedString("了解更多", comment: "OK button title for alert shown when delivery status is uncertain")
            let action = UIAlertAction(title: actionTitle, style: .default) { (_) in
                self.uncertainDeliveryAlert = nil
                self.showUncertainDeliveryRecoveryView()
            }
            alert.addAction(action)
            self.alertPresenter.dismissTopMost(animated: false) {
                self.alertPresenter.present(alert, animated: animated)
            }
            self.uncertainDeliveryAlert = alert
        }
    }
    
    func clearAlert() {
        self.uncertainDeliveryAlert?.dismiss(animated: true, completion: nil)
        self.uncertainDeliveryAlert = nil
    }
}


extension DeliveryUncertaintyAlertManager: CompletionDelegate {
    func completionNotifyingDidComplete(_ object: CompletionNotifying) {
        // If delivery still uncertain after recovery view dismissal, present modal alert again.
        if let vc = object as? UIViewController {
            vc.dismiss(animated: true) {
                if self.pumpManager.status.deliveryIsUncertain {
                    self.showAlert(animated: false)
                }
            }
        }
    }
}
