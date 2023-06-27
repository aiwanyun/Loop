//
//  NSUserActivity.swift
//  Loop
//
//  Copyright © 2018 LoopKit Authors. All rights reserved.
//

import Foundation


extension NSUserActivity {
    /// Activity of viewing the current status of the Loop
    static let viewLoopStatusActivityType = "ViewLoopStatus"

    class func forViewLoopStatus() -> NSUserActivity {
        return NSUserActivity(activityType: viewLoopStatusActivityType)
    }

    static let didAddCarbEntryOnWatchActivityType = "com.loopkit.Loop.AddCarbEntryOnWatch"

    class func forDidAddCarbEntryOnWatch() -> NSUserActivity {
        let activity = NSUserActivity(activityType: didAddCarbEntryOnWatchActivityType)
        activity.isEligibleForSearch = true
        activity.isEligibleForHandoff = false
        activity.isEligibleForPublicIndexing = false
        if #available(watchOSApplicationExtension 5.0, *) {
            activity.isEligibleForPrediction = true
        }
        activity.requiredUserInfoKeys = []
        activity.title = NSLocalizedString("添加碳水化合物输入", comment: "Title of the user activity for adding carbs")
        return activity
    }
}
