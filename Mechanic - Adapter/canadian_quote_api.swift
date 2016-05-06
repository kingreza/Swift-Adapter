//
//  canadian_quote_api.swift
//  Mechanic - Adapter
//
//  Created by Reza Shirazian on 2016-05-06.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

class CanadianQuoteAPI: QuoteAPI {

  private var target: QuoteAPI

  let tax: Double

  let cndToUsd: Double

  let usdToCdn: Double

  var laborInMinutes: Int = 0

  var laborRatePerHour: Double

  init(target: QuoteAPI, tax: Double,
      laborRatePerHour: Double,
      cndToUsd: Double,
      usdToCdn: Double) {
        
    self.tax = tax
    self.laborRatePerHour = laborRatePerHour
    self.target = target
    self.cndToUsd = cndToUsd
    self.usdToCdn = usdToCdn
  }

  var carMileage: Int {
    get {
      return Int(Double(target.carMileage) * 1.60934)
    }
    set(newValue) {
      target.carMileage = Int(Double(newValue) * 0.621371)
    }
  }

  var laborCost: Double {
    get {
      return ((Double(target.laborInMinutes) / 60.0) * self.laborRatePerHour) * usdToCdn
    }
  }

  var partCost: Double {
    get {
      return target.partCost * usdToCdn
    }
  }

  var totalCost: Double {
    get {
      return (self.laborCost + self.partCost) * (1.0 + tax)
    }
  }

  func addPart(part: Part) {
    part.price = part.price * cndToUsd
    target.addPart(part)
  }

  func removePart(part: Part) {
    target.removePart(part)
  }

}
