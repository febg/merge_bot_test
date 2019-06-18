//
//  FileCoverageResultTests.swift
//  CoverageAnalyzerTests
//
//  Created by Felipe Ballesteros on 6/13/19.
//  Copyright © 2019 Slack. All rights reserved.
//

import XCTest

class FileCoverageResultTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFileCoverageResult() {
        let name = "testFileName"
        let coverage = 100.0
        let weight = 50.0
        let fileCoverageResult = FileCoverageResult(name: name, coverage: coverage, weight: weight)
        XCTAssertEqual(fileCoverageResult.name, name)
        XCTAssertEqual(fileCoverageResult.coverage, coverage)
        XCTAssertEqual(fileCoverageResult.weight, weight)
    }

    func testToJSON() {
        let name = "testFileName2"
        let coverage = 10.0
        let weight = 10.0
        let fileCoverageResult = FileCoverageResult(name: name, coverage: coverage, weight: weight)
        let json = fileCoverageResult.toJSON()
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: json!) as? [String:Any]
            XCTAssertEqual(jsonResult!["name"] as? String, name)
            XCTAssertEqual(jsonResult!["coverage"] as? Double, coverage)
            XCTAssertEqual(jsonResult!["weight"] as? Double, weight)
        } catch let parsingError {
            print("Error", parsingError)
        }
    }

}
