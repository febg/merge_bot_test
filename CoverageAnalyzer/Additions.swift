//
//  Additions.swift
//  SlackTestAnalyzer
//
//  Created by Benjamin Smith on 5/13/19.
//  Copyright © 2019 Slack. All rights reserved.
//

import Foundation

extension Double {
    // Returns a string like "XY.Z%" from a double ranging 0…1
    func percentageString() -> String {
        return String(format:"%.1f", self*100) + "%"
    }
}
