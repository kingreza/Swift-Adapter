//
//  part.swift
//  Mechanic - Adapter
//
//  Created by Reza Shirazian on 2016-05-05.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

class Part: Hashable, Equatable {
  var partId: Int
  var name: String
  var price: Double

  init(partId: Int, name: String, price: Double) {
    self.partId = partId
    self.name = name
    self.price = price
  }

  var hashValue: Int {
    return partId
  }
}

func == (lhs: Part, rhs: Part) -> Bool {
  return lhs.partId == rhs.partId
}
