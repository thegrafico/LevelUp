//
//  MissionCategoryPicker.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/24/25.
//

import SwiftUI

struct MissionCategoryPicker: View {
    @Environment(\.currentUser) private var user

    @Binding var selectedCategory: MissionCategory
    @State private var showNewCategoryField = false
    @State private var newCategoryName = ""
    @State private var localCategories: [MissionCategory] = []
    @FocusState private var isTextFieldFocused: Bool

    // MARK: - Combined Categories
    private var combinedCategories: [MissionCategory] {
        var categories = user.missionCategories

        // ✅ Merge with locally added custom categories
        for category in localCategories where !categories.contains(where: { $0.name == category.name }) {
            categories.append(category)
        }

        // ✅ Ensure the current selected one is visible even if it’s brand new
        if case .custom(let custom) = selectedCategory,
           custom.name != MissionCategory.placeholderName,
           !categories.contains(where: { $0.name == custom.name }) {
            categories.append(selectedCategory)
        }

        return categories
    }

    // MARK: - Body
    var body: some View {
        Section("Category") {
            Picker("Select Category", selection: $selectedCategory) {
                ForEach(combinedCategories, id: \.id) { category in
                    Text(category.name).tag(category)
                }

                // ✅ Always show the "Add new" option
                if !showNewCategoryField {
                    Text("➕ New Category…")
                        .tag(MissionCategory.placeholderNewCategory)
                }
            }
            .onAppear {
                // ✅ Initialize local cache once
                localCategories = user.missionCategories
            }
            .onChange(of: selectedCategory) { _, newValue in
                withAnimation {
                    if newValue == .placeholderNewCategory {
                        showNewCategoryField = true
                        isTextFieldFocused = true
                    } else {
                        showNewCategoryField = false
                        newCategoryName = ""
                    }
                }
            }

            // MARK: - New Category Field
            if showNewCategoryField {
                HStack(spacing: 10) {
                    TextField("Enter new category", text: $newCategoryName)
                        .focused($isTextFieldFocused)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)

                    Button("Add") {
                        guard !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        withAnimation {
                            let newCategory = MissionCategory.custom(.init(name: newCategoryName.trimmingCharacters(in: .whitespaces)))
                            selectedCategory = newCategory

                            // Avoid duplicates locally
                            if !localCategories.contains(where: { $0.name == newCategory.name }) {
                                localCategories.append(newCategory)
                            }

                            newCategoryName = ""
                            showNewCategoryField = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Placeholder Constant
extension MissionCategory {
    static let placeholderName = "__placeholder_new__"
    static let placeholderNewCategory = MissionCategory.custom(.init(name: placeholderName))
}

// MARK: - Preview
#Preview {
    MissionCategoryPicker(selectedCategory: .constant(.general))
        .environment(\.currentUser, User.sampleUserWithLogs())
}
