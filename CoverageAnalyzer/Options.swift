//
//  Options.swift
//  SlackTestAnalyzer
//
//  Created by Benjamin Smith on 5/13/19.
//  Copyright © 2019 Slack. All rights reserved.
//

// Struct representing the command line arguments for this invocation
import Foundation

struct Options: Equatable {

    let mode: Mode
    // List of files containig raw code coverage data
    var reportFiles: [String] = []
    // List of files modified on pull request
    var pullFiles: [String] = []

    enum Mode: String {
        // File level analysis of all files
        case analyzeAll
        // Line level analysis of all files
        case masterLines
        // Line level analysis of files modified on pr
        case pullLines
        // File level analysis of files modified on pr
        case analyzeFiles
        // File level differential coverage between all files of two reports
        case analyzeDiff
        // Invalid option
        case invalid

        init(rawValue: String, reportFileCount: Int, pullFileCount: Int) {
            switch rawValue {
            case "analyze-all":
                if reportFileCount != 1 {
                    self = .invalid
                } else { self = .analyzeAll }
            case "master-lines":
                if reportFileCount != 1 {
                    self = .invalid

                } else { self = .masterLines }
            case "analyze-files":
                if reportFileCount != 1 && pullFileCount != 1 {
                    self = .invalid

                } else { self = .analyzeFiles }
            case "pull-lines":
                if reportFileCount != 1 && pullFileCount != 1 {
                    self = .invalid

                } else { self = .pullLines }
            case "analyze-diff":
                if reportFileCount != 2 {
                    self = .invalid

                } else { self = .analyzeDiff }
            default: self = .invalid
            }
        }
    }

    // Init struct by providing arguments
    init(mode: Mode, pullFiles: [String], reportFiles: [String]) {
        self.mode = mode
        self.pullFiles = pullFiles
        self.reportFiles = reportFiles
    }

    // Init struct from JSON config file
    init(config: [String: Any]) {
        guard let command = config["command"] as? String,
            let reportFiles = config["reportFiles"] as? [String],
            let pullFiles = config["pullFiles"] as? [String]
            else {
                self.mode = .invalid
                return
        }
        self.mode = Mode(rawValue: command, reportFileCount: reportFiles.count, pullFileCount: pullFiles.count)
        self.reportFiles = reportFiles
        self.pullFiles = pullFiles
    }
}
