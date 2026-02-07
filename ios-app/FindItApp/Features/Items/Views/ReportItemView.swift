//
//  ReportItemView.swift
//  FindItKIET
//
//  Report item placeholder screen
//

import SwiftUI

struct ReportItemView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Report Item Screen")
                        .font(.title)
                    
                    Text("Full implementation includes:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        bulletPoint("Title and description fields")
                        bulletPoint("Category picker")
                        bulletPoint("Lost/Found status toggle")
                        bulletPoint("Location input")
                        bulletPoint("Date/time picker")
                        bulletPoint("Image upload (multiple)")
                        bulletPoint("Submit button with validation")
                    }
                    .padding()
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle("Report Item")
        }
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top) {
            Text("•")
            Text(text)
        }
        .font(.subheadline)
    }
}
