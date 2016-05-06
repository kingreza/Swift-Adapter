//
//  main.swift
//  Mechanic - Adapter
//
//  Created by Reza Shirazian on 2016-05-05.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

/* We assume we do not have access to the APIR's tax rate or laborRatePerHour.
 * For all we know these values are stored in some legacy code deep inside some old server
 * We cannot access or change it. */

var originalAPI = OriginalQuoteAPI(tax: 0.20, laborRatePerHour: 50.00)

// We add two parts, set how long it takes to do the job and add the car's mileage
originalAPI.addPart(Part(partId: 15, name: "Brade Fluid", price: 20.00))
originalAPI.addPart(Part(partId: 8, name: "Filters", price: 10.00))
originalAPI.laborInMinutes = 60
originalAPI.carMileage = 11000
print(originalAPI.totalCost)


var canadianAPI = CanadianQuoteAPI(target: originalAPI,
                                   tax: 0.20,
                                   laborRatePerHour: 50.00,
                                   cndToUsd: 0.75,
                                   usdToCdn: 1.2)
print(canadianAPI.totalCost)
canadianAPI.addPart(Part(partId: 63, name: "Regular Oil", price: 5.00))
print(canadianAPI.totalCost)
print(originalAPI.totalCost)
print(originalAPI.partCost)


print("Mileage of the car is \(originalAPI.carMileage) Miles")
print("Mileage of the car is \(canadianAPI.carMileage) Kilometers")

canadianAPI.carMileage = 10000

print("Mileage of the car is \(originalAPI.carMileage) Miles")
print("Mileage of the car is \(canadianAPI.carMileage) Kilometers")
