//
//  FavoriteFoodDetailView.swift
//  Loop
//
//  Created by Noah Brauner on 8/2/23.
//  Copyright © 2023 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKit
import HealthKit

public struct FavoriteFoodDetailView: View {
    let food: StoredFavoriteFood?
    let onFoodDelete: (StoredFavoriteFood) -> Void
    
    @State private var isConfirmingDelete = false
    
    let carbFormatter: QuantityFormatter
    let absorptionTimeFormatter: DateComponentsFormatter
    let preferredCarbUnit: HKUnit
    
    public init(food: StoredFavoriteFood?, onFoodDelete: @escaping (StoredFavoriteFood) -> Void, isConfirmingDelete: Bool = false, carbFormatter: QuantityFormatter, absorptionTimeFormatter: DateComponentsFormatter, preferredCarbUnit: HKUnit = HKUnit.gram()) {
        self.food = food
        self.onFoodDelete = onFoodDelete
        self.isConfirmingDelete = isConfirmingDelete
        self.carbFormatter = carbFormatter
        self.absorptionTimeFormatter = absorptionTimeFormatter
        self.preferredCarbUnit = preferredCarbUnit
    }
    
    public var body: some View {
        if let food {
            List {
                Section("Information") {
                    VStack(spacing: 16) {
                        let rows: [(field: String, value: String)] = [
                            ("Name", food.name),
                            ("Carb Quantity", food.carbsString(formatter: carbFormatter)),
                            ("Food Type", food.foodType),
                            ("Absorption Time", food.absorptionTimeString(formatter: absorptionTimeFormatter))
                        ]
                        ForEach(rows, id: \.field) { row in
                            HStack {
                                Text(row.field)
                                    .font(.subheadline)
                                Spacer()
                                Text(row.value)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                
                Button(role: .destructive, action: { isConfirmingDelete.toggle() }) {
                    Text("删除食物")
                        .frame(maxWidth: .infinity, alignment: .center) // Align text in center
                }
            }
            .alert(isPresented: $isConfirmingDelete) {
                Alert(
                    title: Text("Delete “\(food.name)”?"),
                    message: Text("您确定要删除这种食物吗？"),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(Text("删除"), action: { onFoodDelete(food) })
                )
            }
            .insetGroupedListStyle()
            .navigationTitle(food.title)
        }
    }
}
