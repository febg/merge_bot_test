//
//  CoverageResult.swift
//  SlackTestAnalyzer
//
//  Created by Benjamin Smith on 5/10/19.
//  Copyright © 2019 Slack. All rights reserved.
//

import Foundation

// Struct representing coverage data for a single build target
struct TargetCoverageResult: Codable, JsonConvertible {
    // Name of the build target, ex. SlackDataProviders
    let name: String

    // Percentage of lines of code in this target that are exercised by tests
    let coverage: Double

    // Percentage of overall project lines of code represented by this target
    let weight: Double

    // List containg coverage data for files in target
    let fileReports: [FileCoverageResult]

    init(name: String, coverage: Double, weight: Double, fileReports: [FileCoverageResult]) {
        self.name = name
        self.coverage = coverage
        self.weight = weight
        self.fileReports = fileReports
    }

    var description: String {
        return name + ": coverage " + coverage.percentageString() + ". Weight: " + weight.percentageString()
    }

    func toJSON() -> Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            print("Error encoding " + self.name + " to JSON")
            return nil
        }
    }
}
