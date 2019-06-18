//
//  CoverageReport.swift
//  SlackTestAnalyzer
//
//  Created by Benjamin Smith on 5/10/19.
//  Copyright © 2019 Slack. All rights reserved.
//

import Foundation

struct CoverageReport: Codable, JsonConvertible {
    // The version described by this report
    let version: String

    // Individual results for each build target, keyed by target name
    let resultsByName: [String: TargetCoverageResult]

    // Newline-separated results for each build target in this report
    var description: String {
        let perTargetResults = Array(resultsByName.values).sorted {
            return $0.name < $1.name
        }
        let perTargetDescriptions = perTargetResults.map { return $0.description }
        return perTargetDescriptions.joined(separator: "\n")
    }

    init(version: String, results: [TargetCoverageResult]) {
        self.version = version
        self.resultsByName = Dictionary(uniqueKeysWithValues: results.map { ($0.name, $0) })
    }

    func diff(_ other: CoverageReport) -> CoverageReportDiff {
        let myReports = self.resultsByName
        let theirReports = other.resultsByName
        var diffsByTargetName: [String: Double] = [:]
        let allKeys = Set(Array(myReports.keys) + Array(theirReports.keys))
        allKeys.forEach {
            guard let myValue = myReports[$0], let theirValue = theirReports[$0] else {
                return
            }
            diffsByTargetName[$0] = myValue.coverage - theirValue.coverage
        }

        return CoverageReportDiff(firstVersion: self.version, secondVersion: other.version, deltasByTargetName: diffsByTargetName)
    }

    func toJSON() -> Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            print("Error encoding " + self.version + " to JSON")
            return nil
        }
    }
}

struct CoverageReportDiff: Codable, JsonConvertible {
    // Coverage deltas for each build target, keyed by target name
    let deltasByTargetName: [String: Double]

    // The two versions being diffed
    let firstReportVersion: String
    let secondReportVersion: String

    init(firstVersion: String, secondVersion: String, deltasByTargetName: [String: Double]) {
        self.firstReportVersion = firstVersion
        self.secondReportVersion = secondVersion
        self.deltasByTargetName = deltasByTargetName
    }

    // Newline-separated deltas for each build target in this diff
    var description: String {
        let sortedKeys = deltasByTargetName.keys.sorted { return $0 < $1 }
        let descriptions = sortedKeys.compactMap { name -> String? in
            guard let delta = deltasByTargetName[name] else {
                return nil
            }
            var deltaString = delta.percentageString()
            if delta > 0.0 { deltaString = "+" + deltaString }
            return name + " delta: " + deltaString
        }
        return descriptions.joined(separator: "\n")
    }

    func toJSON() -> Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            print("Error encoding diff " + firstReportVersion + "…" + secondReportVersion + " to JSON")
            return nil
        }
    }
}
