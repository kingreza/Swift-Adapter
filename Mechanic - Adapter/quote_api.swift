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

  var laborInMinutes: Int {get set}

  var laborCost: Double {get}

  var carMileage: Int {get set}

  var partCost: Double {get}

  var totalCost: Double {get}

  func addPart(part: Part)

  func removePart(part: Part)

}
