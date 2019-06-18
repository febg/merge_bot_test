//
//  JsonConvertible.swift
//  CoverageAnalyzer
//
//  Created by Benjamin Smith on 5/13/19.
//  Copyright © 2019 Slack. All rights reserved.
//

import Foundation

protocol JsonConvertible {
    func toJSON() -> Data?
}
