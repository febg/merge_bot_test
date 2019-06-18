//
//  FileIO.swift
//  CoverageAnalyzer
//
//  Created by Benjamin Smith on 5/13/19.
//  Copyright © 2019 Slack. All rights reserved.
//

import Foundation

class FileIO {
    static func loadJSONRepresentation(filePath: String) -> [String: Any] {
        do {
            let fileURL = URL(fileURLWithPath: filePath)
            let jsonData = try Data(contentsOf: fileURL)
            let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
            return jsonResult
        } catch {
            print("Error loading JSON \(error)")
            exit(1)
        }

        return [:]
    }

    static func write(object: JsonConvertible, fileName: String) {
        let currentDir = FileManager.default.currentDirectoryPath
        guard let path = NSURL(fileURLWithPath: currentDir).appendingPathComponent(fileName) else {
            print("Error: couldn't get file path for writing")
            return
        }

        do {
            guard let data = object.toJSON() else {
                print("Error converting results to JSON")
                exit(1)
            }
            try data.write(to: path)
        } catch {
            print("Error writing JSON: " + fileName)
            return
        }

        print("Wrote results to: " + path.absoluteString)
    }
}
