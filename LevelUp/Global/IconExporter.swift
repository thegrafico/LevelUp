//
//  IconExporter.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/2/25.
//

import Foundation
import SwiftUI

@MainActor
private func exportIcons() {
       let sizes: [CGFloat] = [1024, 512, 256, 128]

       for size in sizes {
           let icon = XPAppIcon(size: size, forAppStore: true)
               .environment(\.theme, .orange)

           let renderer = ImageRenderer(content: icon)

           if let uiImage = renderer.uiImage {
               if let data = uiImage.pngData() {
                   // Save inside app’s Documents directory (works on iOS Simulator)
                   let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                   let url = documents.appendingPathComponent("XPAppIcon_\(Int(size)).png")

                   do {
                       try data.write(to: url)
                       print("✅ Exported: \(url)")
                   } catch {
                       print("❌ Failed to save: \(error)")
                   }
               }
           }
       }
   }
