//
//  main.swift
//  Mechanic - Adapter
//
//  Created by Reza Shirazian on 2016-05-05.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

var originalAPI = OriginalQuoteAPI()

// We add two parts, set how long it takes to do the job and add the car's mileage
originalAPI.addPart(Part(partId: 15, name: "Brade Fluid", price: 20.00))
originalAPI.addPart(Part(partId: 8, name: "Filters", price: 10.00))
originalAPI.laborInMinutes = 60
originalAPI.carMileage = 11000
print(originalAPI.totalCost)


var canadianAPI = CanadianQuoteAPI(target: originalAPI,
                                   tax: 0.20,
                                   laborRatePerHour: 50.00,
                                   cadToUsd: 0.75,
                                   usdToCad: 1.2)
//Print total cost in CAD
print(canadianAPI.totalCost)

//Add part through Canadian APIT, price will be in CAD
canadianAPI.addPart(Part(partId: 63, name: "Regular Oil", price: 5.00))

//Print total cost in CAD
print(canadianAPI.totalCost)

//Print total cost in USD
print(originalAPI.totalCost)

//Print total cost of parts in USD
print(originalAPI.partCost)

//Print car mileage in miles and km
print("Mileage of the car is \(originalAPI.carMileage) Miles")
print("Mileage of the car is \(canadianAPI.carMileage) Kilometers")

//Change cars mileage through Canadian api, new value is in KM
canadianAPI.carMileage = 10000

//Print car mileage in miles and km
print("Mileage of the car is \(originalAPI.carMileage) Miles")
print("Mileage of the car is \(canadianAPI.carMileage) Kilometers")
