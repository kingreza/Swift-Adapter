//
//  quote_api.swift
//  Mechanic - Adapter
//
//  Created by Reza Shirazian on 2016-05-05.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

protocol QuoteAPI {

  var tax: Double {get}

  var laborRatePerHour: Double {get}

  var partCost: Double {get}

  var totalCost: Double {get}

  var laborCost: Double {get}

  var laborInMinutes: Int {get set}

  var carMileage: Int {get set}

  func addPart(part: Part)

  func removePart(part: Part)

}
