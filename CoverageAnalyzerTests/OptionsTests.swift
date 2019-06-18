//
//  OptionsTests.swift
//  CoverageAnalyzerTests
//
//  Created by Felipe Ballesteros on 6/12/19.
//  Copyright © 2019 Slack. All rights reserved.
//

import XCTest

class OptionsTests: XCTestCase {

    override func setUp() {

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let sampleConfig0:[String:Any] = ["command": "file", "pullFiles": [], "reportFiles": [] ]
        let sampleConfig1:[String:Any] = ["command":"analyze-all", "pullFiles":[], "reportFiles": ["test_coverage_raw_1.json"]]
        let sampleConfig2:[String:Any] = ["command": "analyze-files", "pullFiles": [], "reportFiles": ["test_coverage_raw_1.json"]]
        let sampleConfig3:[String:Any] = ["command":"analyze-files", "pullFiles": ["ObjectLeakDetector.swift", "HUDManager.swift"], "reportFiles": ["test_coverage_raw_1.json"]]
        let sampleConfig4:[String:Any] = ["pullFiles": [], "reportFiles": [] ]

        let invalidOption = Options(mode: .invalid, pullFiles: [], reportFiles: [])
        let expectedOption1 = Options(mode: .analyzeAll, pullFiles: [], reportFiles: ["test_coverage_raw_1.json"])
        let expectedOption2 = Options(mode: .analyzeFiles, pullFiles: [], reportFiles: ["test_coverage_raw_1.json"])
        let expectedOption3 = Options(mode: .analyzeFiles, pullFiles: ["ObjectLeakDetector.swift", "HUDManager.swift"], reportFiles: ["test_coverage_raw_1.json"])

        let option0 = Options(config: sampleConfig0)
        let option1 = Options(config: sampleConfig1)
        let option2 = Options(config: sampleConfig2)
        let option3 = Options(config: sampleConfig3)
        let option4 = Options(config: sampleConfig4)

        XCTAssertEqual(option0, invalidOption)
        XCTAssertEqual(option1, expectedOption1)
        XCTAssertEqual(option2, expectedOption2)
        XCTAssertEqual(option3, expectedOption3)
        XCTAssertEqual(option4, invalidOption)

    }

}
