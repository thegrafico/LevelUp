//
//  Collections.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/9/25.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
