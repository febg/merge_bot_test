//
//  FileCoverageResult.swift
//  CoverageAnalyzer
//
//  Created by Felipe Ballesteros on 6/9/19.
//  Copyright © 2019 Slack. All rights reserved.
//
import Foundation

// Struct representing coverage data for a single file
struct FileCoverageResult: Codable, JsonConvertible {
    // Name of the file
    let name: String
    // Percentage of lines of code in file that are covered by tests
    let coverage: Double
    // Percentage of target lines of code represented by this file
    let weight: Double

    init(name: String, coverage: Double, weight: Double) {
        self.name = name
        self.coverage = coverage
        self.weight = weight
    }

    func toJSON() -> Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            print("Error encoding \(self.name) to JSON")
            return nil
        }
    }
}
