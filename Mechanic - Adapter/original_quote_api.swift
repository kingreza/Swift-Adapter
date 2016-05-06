//
//  original_quote_api.swift
//  Mechanic - Adapter
//
//  Created by Reza Shirazian on 2016-05-05.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

class OriginalQuoteAPI: QuoteAPI {

  internal let tax: Double

  internal let laborRatePerHour: Double

  var laborInMinutes: Int = 0

  var carMileage: Int = 0

  var parts: Set<Part>

   init(tax: Double, laborRatePerHour: Double) {
    self.tax = tax
    self.parts = Set<Part>()
    self.laborRatePerHour = laborRatePerHour
  }

  var laborCost: Double {
    get {
      return (Double(self.laborInMinutes) / 60.0) * self.laborRatePerHour
    }
  }

  var partCost: Double {
    get {
      return parts.reduce(0.0, combine: {$0 + $1.price})
    }
  }

  var totalCost: Double {
    get {
      return (laborCost + partCost) * (1.0 + tax)
    }
  }

  func addPart(part: Part) {
    parts.insert(part)
  }

  func removePart(part: Part) {
    parts.remove(part)
  }
}
