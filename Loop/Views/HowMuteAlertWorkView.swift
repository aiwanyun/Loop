//
//  HowMuteAlertWorkView.swift
//  Loop
//
//  Created by Nathaniel Hamming on 2022-12-09.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKitUI

struct HowMuteAlertWorkView: View {
    @Environment(\.dismissAction) private var dismiss
    @Environment(\.guidanceColors) private var guidanceColors
    @Environment(\.appName) private var appName

    var body: some View {
        NavigationView {
            List {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("关键和时间敏感警报的示例是什么？")
                            .bold()
                        
                        Text("iOS关键警报和时间敏感警报是Apple通知的类型。它们用于高优先事件。一些示例包括：")
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("关键警报")
                                    .bold()
                                
                                Text("紧急低")
                                    .bulleted()
                                Text("传感器失败")
                                    .bulleted()
                                Text("储液器空")
                                    .bulleted()
                                Text("泵已过期")
                                    .bulleted()
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("时间敏感警报")
                                    .bold()
                                
                                Text("高血糖")
                                    .bulleted()
                                Text("发射器低电池")
                                    .bulleted()
                            }
                        }
                        
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundColor(.black.opacity(0.6))
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color(.systemFill), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(
                            String(
                                format: NSLocalizedString(
                                    "How can I temporarily silence all %1$@ app sounds?",
                                    comment: "Title text for temporarily silencing all sounds (1: app name)"
                                ),
                                appName
                            )
                        )
                        .bold()
                        
                        Text(
                            String(
                                format: NSLocalizedString(
                                    "Use the Mute Alerts feature. It allows you to temporarily silence all of your alerts and alarms via the %1$@ app, including Critical Alerts and Time Sensitive Alerts.",
                                    comment: "Description text for temporarily silencing all sounds (1: app name)"
                                ),
                                appName
                            )
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("如何使非关键警报保持静音？")
                            .bold()
                        
                        Text(
                            String(
                                format: NSLocalizedString(
                                    "Turn off the volume on your iOS device or add %1$@ as an allowed app to each Focus Mode. Time Sensitive and Critical Alerts will still sound, but non-Critical Alerts will be silenced.",
                                    comment: "Description text for temporarily silencing non-critical alerts (1: app name)"
                                ),
                                appName
                            )
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("我如何仅使时间敏感和非关键警报保持静音？")
                            .bold()
                        
                        Text(
                            String(
                                format: NSLocalizedString(
                                    "For safety purposes, you should allow Critical Alerts, Time Sensitive and Notification Permissions (non-critical alerts) on your device to continue using %1$@ and cannot turn off individual alarms.",
                                    comment: "Description text for silencing time sensitive and non-critical alerts (1: app name)"
                                ),
                                appName
                            )
                        )
                    }
                }
                .padding(.vertical, 8)
            }
            .insetGroupedListStyle()
            .navigationTitle(NSLocalizedString("管理警报", comment: "View title for how mute alerts work"))
            .navigationBarItems(trailing: closeButton)
        }
    }

    private var closeButton: some View {
        Button(action: dismiss) {
            Text(NSLocalizedString("关闭", comment: "Button title to close view"))
        }
    }
}

private extension Text {
    func bulleted(color: Color = .accentColor.opacity(0.5)) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: 8, height: 8)
                .foregroundColor(color)
            
            self
        }
    }
}

struct HowMuteAlertWorkView_Previews: PreviewProvider {
    static var previews: some View {
        HowMuteAlertWorkView()
    }
}
