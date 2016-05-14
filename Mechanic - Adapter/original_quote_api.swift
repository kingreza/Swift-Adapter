//
//  original_quote_api.swift
//  Mechanic - Adapter
//
//  Created by Reza Shirazian on 2016-05-05.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

class OriginalQuoteAPI: QuoteAPI {

  let tax: Double = 0.20

  let laborRatePerHour: Double =  50.00

  var laborInMinutes: Int

  var carMileage: Int

  var parts: Set<Part>

   init() {
    self.laborInMinutes = 0
    self.carMileage = 0
    self.parts = Set<Part>()
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
