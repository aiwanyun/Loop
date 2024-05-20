//
//  HowAbsorptionTimeWorksView.swift
//  Loop
//
//  Created by Noah Brauner on 7/28/23.
//  Copyright © 2023 LoopKit Authors. All rights reserved.
//

import SwiftUI

struct HowAbsorptionTimeWorksView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("为大餐或含有脂肪和蛋白质的食物选择更长的吸收时间。这只是对算法的指导，不必确切地说。", comment: "Carb entry section footer text explaining absorption time")
                }
            }
            .navigationTitle("Absorption Time")
            .toolbar {
                dismissButton
            }
        }
    }
    
    private var dismissButton: some View {
        Button(action: dismiss.callAsFunction) {
            Text("关闭")
        }
    }
}
