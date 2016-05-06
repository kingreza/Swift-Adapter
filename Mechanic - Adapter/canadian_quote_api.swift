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

  let cadToUsd: Double

  let usdToCad: Double

  var laborInMinutes: Int = 0

  var laborRatePerHour: Double

  init(target: QuoteAPI, tax: Double,
      laborRatePerHour: Double,
      cadToUsd: Double,
      usdToCad: Double) {

    self.tax = tax
    self.laborRatePerHour = laborRatePerHour
    self.target = target
    self.cadToUsd = cadToUsd
    self.usdToCad = usdToCad
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
      return ((Double(target.laborInMinutes) / 60.0) * self.laborRatePerHour) * usdToCad
    }
  }

  var partCost: Double {
    get {
      return target.partCost * usdToCad
    }
  }

  var totalCost: Double {
    get {
      return (self.laborCost + self.partCost) * (1.0 + tax)
    }
  }

  func addPart(part: Part) {
    part.price = part.price * cadToUsd
    target.addPart(part)
  }

  func removePart(part: Part) {
    target.removePart(part)
  }

}
