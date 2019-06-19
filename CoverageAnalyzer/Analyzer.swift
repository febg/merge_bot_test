//
//  Analyzer.swift
//  SlackTestAnalyzer
//
//  Created by Benjamin Smith on 5/10/19.
//  Copyright © 2019 Slack. All rights reserved.
//

import Foundation

class Analyzer {
    // Build targets to be excluded from analysis, such as test bundles and external deps
    private let blacklistedTargetNameComponents = ["Test", "PromiseKit", "TSFKitSample", "Pods_"]

    // Generates a CoverageReport from an input file
    func analyze(filePath: String) -> CoverageReport {
        let jsonReport = FileIO.loadJSONRepresentation(filePath: filePath)
        let linesOfCode = self.totalLinesOfCode(from: jsonReport)
        let results = self.analyzeCoverage(from: jsonReport, sumLinesOfCode: linesOfCode)
        let report = CoverageReport(version: "tbd", results: results)
        return report
    }

    /**
     Generates a CoverageReport for an specific set of files

     - Parameter filePath: Path of raw_coverage.json file
     - Parameter files: Array of files to be analyzed

     - Returns: A CoverageReport containing file level information for an specific set of files
    */
    func analyze(filePath: String, files: [String]) -> CoverageReport {
        let jsonReport = FileIO.loadJSONRepresentation(filePath: filePath)
        let linesOfCode = self.totalLinesOfCode(from: jsonReport)
        let results = self.analyzeCoverage(from: jsonReport, filesChanged: files, sumLinesOfCode: linesOfCode)
        let report = CoverageReport(version: "tbd", results: results)
        return report
    }

    private func shouldSkipTarget(name: String) -> Bool {
        for blacklistedTarget in blacklistedTargetNameComponents {
            if name.contains(blacklistedTarget) { return true}
        }

        return false
    }

    // Computes the total lines of executable code for the project
    private func totalLinesOfCode(from report: [String : Any]) -> Double {
        var targets = report["targets"] as! [[String: Any]]
        targets = targets.filter {
            let targetPath = $0["buildProductPath"] as! String
            let targetURL = URL(fileURLWithPath: targetPath)
            let targetName = targetURL.lastPathComponent
            return !shouldSkipTarget(name: targetName)
        }
        var totalLines = 0.0
        targets.forEach { totalLines += $0["executableLines"] as! Double }
        return totalLines
    }

    // Analyzes a JSON representation of a .xccovreport file
    // Returns an array of per-build-target coverage results
    private func analyzeCoverage(from report: [String: Any], sumLinesOfCode: Double) -> [TargetCoverageResult] {
        let targets = report["targets"] as! [[String: Any]]
        var coverageResults: [TargetCoverageResult] = []
        for target in targets {
            let files = target["files"] as! [[String: Any]]
            let executableLines = target["executableLines"] as! Double
            let fileReports = analyzeFileCoverage(targetFiles: files, targetLines: executableLines)
            guard let result = computeTargetCoverage(target: target, linesOfCode: sumLinesOfCode, executableLines: executableLines, fileReports: fileReports) else {
                continue
            }
            coverageResults.append(result)
        }
        return coverageResults
    }

    /**
     Analyzes a JSON representation of raw coverage data for a given set of files

     - Parameter report: Dictionary containing coverage raw data
     - Parameter filesChanged: Array of files to be analyzed

     - Returns: A list of TargetCoverageResult containing target & file level code coverage for a given set of files
     */
    private func analyzeCoverage(from report: [String: Any], filesChanged: [String], sumLinesOfCode: Double) -> [TargetCoverageResult] {
        let targets =  report["targets"] as! [[String:Any]]
        var coverageResults: [TargetCoverageResult] = []
        for target in targets {
            let files = target["files"] as! [[String: Any]]
            let executableLines = target["executableLines"] as! Double
            guard let fileReports = analyzeFileCoverage(targetFiles: files, files: filesChanged, targetLines: executableLines) else {
                continue
            }
            guard let result = computeTargetCoverage(target: target, linesOfCode: sumLinesOfCode, executableLines: executableLines, fileReports: fileReports) else {
                //TODO: Handle error
                continue
            }
            coverageResults.append(result)
        }
        return coverageResults
    }

    /**
     Computes code coverage result for a given target

     - Parameter target: Dictionary containing target code coverage raw data
     - Parameter linesOfCode: Total number of lines of code in scheme
     - Parameter executableLines: Total number of executable lines of code in target
     - Parameter fileReports: List of file level reports

     - Returns: A TargetCoverageResult containing target & file level code coverage
     */
    private func computeTargetCoverage(target: [String:Any], linesOfCode: Double, executableLines: Double, fileReports: [FileCoverageResult]) -> TargetCoverageResult? {
        let targetPath = target["buildProductPath"] as! String
        let targetURL = URL(fileURLWithPath: targetPath)
        let targetName = targetURL.lastPathComponent
        if shouldSkipTarget(name: targetName) { return nil }
        let coveredLines = target["coveredLines"] as! Double
        let weight = executableLines/linesOfCode
        let coverage = coveredLines/executableLines
        let result = TargetCoverageResult(name: targetName, coverage: coverage, weight: weight, fileReports: fileReports)
        return result
    }

    /**
     Generates a list of file-level coverage reports for all files in a target

     - Parameter targetFiles: Dictionary containing raw coverage data for all files in a target
     - Parameter targetLines: Total lines of code in target

     - Returns: A list of FileCoverageResult containing file level code coverage for all files
     */
    private func analyzeFileCoverage(targetFiles: [[String: Any]], targetLines: Double) -> [FileCoverageResult] {
        var fileResults = [FileCoverageResult]()
        var totalWeight = 0.0
        for file in targetFiles {
            let fileName = file["name"] as! String
            let coveredLines = file["coveredLines"] as! Double
            let executableLines = file["executableLines"] as! Double
            let coverage = coveredLines/executableLines * 100
            let weight = (executableLines/targetLines) * 100
            totalWeight += weight
            let result = FileCoverageResult(name: fileName, coverage: coverage, weight: weight)
            fileResults.append(result)
        }
        return fileResults
    }

    /**
     Generates list of file-level coverage reports for a given set of files in a target

     - Parameter targetFiles: Dictionary containing raw coverage data for all files in a target
     - Parameter targetLines: Total lines of code in target
     - Parameter files: Array with names of files to be analyzed

     - Returns: A list of FileCoverageResult containing file level information for a given set of files
     */
    private func analyzeFileCoverage(targetFiles: [[String: Any]], files: [String], targetLines: Double) -> [FileCoverageResult]? {
        var fileReports = [FileCoverageResult]()
        var fileDetected = false
        for file in targetFiles {
            let fileName = file["name"] as! String
            if !files.contains(fileName) { continue }
            let coveredLines = file["coveredLines"] as! Double
            let executableLines = file["executableLines"] as! Double
            let coverage = coveredLines/executableLines * 100
            let weight = (executableLines/targetLines) * 100
            let report = FileCoverageResult(name: fileName, coverage: coverage, weight: weight)
            fileReports.append(report)
            fileDetected = true
        }
        return fileDetected ? fileReports : nil
    }
}
