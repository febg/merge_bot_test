//
//  main.swift
//  SlackTestAnalyzer
//
//  Created by Benjamin Smith on 5/10/19.
//  Copyright © 2019 Slack. All rights reserved.
//

import Foundation

let CONFIG_INDEX = 1

///Displays help on how to use CoverageAnalyzer
func displayHelp() {
    print("Usage: CoverageAnalyzer <json config file>")
    print("Call with a single argument to produce coverage data")
    exit(1)
}

// Read arguments passed
let arguments = CommandLine.arguments

if arguments.count < 2 { displayHelp() }

// Read config file
let config = FileIO.loadJSONRepresentation(filePath: arguments[CONFIG_INDEX])
// Parse config file
let options = Options(config: config)

let analyzer = Analyzer()

// Handle mode of execution
switch options.mode {
case .analyzeAll:
    print("Printing coverage data \n")
    let coverageReport = analyzer.analyze(filePath: options.reportFiles[0])
    print(coverageReport.description)
    FileIO.write(object: coverageReport, fileName: "coverage_report.json")
case .analyzeFiles:
    print("Printing coverage data \n")
    let coverageReport = analyzer.analyze(filePath: options.reportFiles[0], files: options.pullFiles)
    print(coverageReport.description)
    FileIO.write(object: coverageReport, fileName: "coverage_report.json")
case .analyzeDiff:
    print("Printing diff \n")
    let firstReport = analyzer.analyze(filePath: options.reportFiles[0])
    let secondReport = analyzer.analyze(filePath: options.reportFiles[1])
    let diff = firstReport.diff(secondReport)
    print(diff.description)
    FileIO.write(object: diff, fileName: "coverage_report.json")
default:
    displayHelp()
}
