<h1>Design Patterns in Swift: Adapter</h1>
This repository is part of a series. For the full list check out <a href="https://shirazian.wordpress.com/2016/04/11/design-patterns-in-swift/">Design Patterns in Swift</a>

For a cheat-sheet of design patterns implemented in Swift check out <a href="https://github.com/ochococo/Design-Patterns-In-Swift"> Design Patterns implemented in Swift: A cheat-sheet</a>

<h3>The problem:</h3>
<a href="http://www.yourmechanic.com">YourMechanic</a> is expanding to Canada. Now our friends to the north can have their cars fixed at their home or office by one of our professional mechanics. To finalize our expansion there are major changes we need to make to our system. Providing support for the Canadian currency and the metric system would be a lot of work and we are short on time. Therefore we want an easy way to interface with our current Quote API. The Quote API can add and remove parts, set labor times for a quote, calculate a total price and track a car's mileage. There also two properties, tax rates and labor rates which cannot be set but are derived from some external data source that we do not have access. All these values are assumed in USD/Imperial by our current system. We need a way to both display and input values in CAD and the metric system and have it remain consistent throughout our system. Also tax rates and labor rates are different in Canada so we need to adapt for those changes as well.
<h3>The solution:</h3>
We will define an adapter that will implement the same set of functions as our original API. This new adapter will take an instance of our original API as a parameter and will act as a middleman between calls. If a function call in our original API needs to be manipulated in anyway to deal with our new Canadian requirements, the adapter will take care of it. If not, the adapter will simply call the original API function with the same parameters passed to it.

<!--more-->

Link to the repo for the completed project: <a href="https://github.com/kingreza/Swift-Adapter">Swift - Adapter</a>

To demonstrate the full scope of an adapter, we will define our originalApi as pseudo-builder class for our quotes. This object will be stateful. This means each instance of it is responsible for a specific quote and that every function call will affect the state of the underlying object. I'm mentioning this since APIs have traditionally be associated with stateless RESTful architecture and seeing it this way might seem a bit foreign.

Lets define our QuoteAPI which is basically an interface for building a quote

```Swift
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
```

We begin by defining our readonly values. We do not have write access to our tax and labor hourly rate as mentioned in the requirements. Total cost and labor cost are also values that are derived from other properties. This leaves us with four functions that we can use to set stuff: laborInMinute which is the total amount of minutes required to complete this quote's appointment, car mileage which is simply the number of miles the car has traveled and a simple add and remove function for adding and removing parts to our quote.

Let see how these functions look in our original quote API.

```Swift

class OriginalQuoteAPI: QuoteAPI {

  let tax: Double = 0.20

  let laborRatePerHour: Double =  50.00

  var laborInMinutes: Int = 0

  var carMileage: Int = 0

  var parts: Set<Part>

   init() {
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

```

We define our tax and hourly labor rates. These values as mentioned are set in stone as far as we are concerned so we'll hardcode 20% and $50 respectively. We define our laborInMinutes and carMileage along with a set for our Parts ( we will look at our Part class in a bit). We then proceed to initialize these properties by setting our labor time and car mileage to zero. This is fairly standard Swift stuff up to this point.

Next we begin to define our derived variables. Our labor cost is our labor in minutes divided by 60 (to give us duration in hour) multiplied by our hourly rate.

Our parts cost is an aggregate of all our parts prices, summed up. We use Swift's higher order function reduce to calculate this value. If you are not familiar with higher order functions or this seems odd, I suggest you take a look at<a href="https://www.weheartswift.com/higher-order-functions-map-filter-reduce-and-more/"> this article</a>. Learning higher order functions and closures in general can save you a lot of "for loops".

Finally we calculate our total cost by adding our parts cost to our labor cost and adding the required tax to the final price.

We also have two functions for adding and removing parts which simply add and remove items from our Set of parts.

This will give us our original API. We will write an adapter for this so it can work with Canadian currency, the metric system and Canadian tax and labor rates. But before we get to that let's quickly go over our Parts class which we have used in our original QuoteAPI.

```Swift

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

```

We define our Parts class to implement Hashable and Equatable protocols. Implementing these protocol makes it possible for us to use instances of Part in a Set collection. What these protocols do is that they provide Swift a way to derive a hash value and test for equality between different instances. Once we implement these protocol we need to define a hashValue of type Int and a == function for our Parts class. We can assume that our Part's class will have a unique partId for each part which we can use to both provide a hash value and check for equality between different instances of Parts.

We also define a name and price for our Parts which we set in our initializer.

Alright let's look at our Adapter.

```Swift

import Foundation

class CanadianQuoteAPI: QuoteAPI {

  private var target: QuoteAPI

  let tax: Double

  let cadToUsd: Double

  let usdToCad: Double

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

  var laborInMinutes: Int {
    get {
      return target.laborInMinutes
    }

    set(newValue) {
      target.laborInMinutes = newValue
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

```

Let's break it down and look at it step by step. Before getting into our derived variables and QuoteAPI functions let's look at what properties we need for our adapter.

```Swift
class CanadianQuoteAPI: QuoteAPI {

  private var target: QuoteAPI

  let tax: Double

  let cadToUsd: Double

  let usdToCad: Double

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
    self.laborInMinutes = 0
  }
```

First off we define our CanadianQuoteAPI as a class that implements our QuoteAPI protocol. Our adapter needs to be able to do everything our original quote API does. We then define a target variable which will be of type QuoteAPI. In this case, this will be an instance of OriginalQuoteAPI. Beside tax, laborRatePerHour which were hardcoded in OrigianlQuoteAPI we are defining two new properties: usdToCad and cadToUsd. These two doubles will be our exchange rates from CAD to USD and vise-versa.

OriginalQuoteAPI may have its tax rates and labor rates hardcored, but our adapter doesn't have to. Since we are writing this adapter we can make it so it uses a different tax and labor rates, ones that we will pass when we instantiate it.

Our initializer takes in an instance of QuoteAPI which will be our target. It will grab a tax rate, labor rate and our exchange rates as well.

But, wait a second. What happened to our Parts? or car mileage? laborInMinutes? don't we need to have these properties as well if we want to conform to QuoteAPI? Shouldn't our CanadianQuoteAPI save these values as well?

Yes we do and no it doesn't.

```Swift
  var carMileage: Int {
    get {
      return Int(Double(target.carMileage) * 1.60934)
    }
    set(newValue) {
      target.carMileage = Int(Double(newValue) * 0.621371)
    }
  }
```

This is a property that is defined in our protocol with a setter and getter. This means our API needs to be able to set and get its value. Since our target API is in miles we can translate its value to kilometers by simply multiplying its value by 1.609 when it is requested by our CanadianQuoteAPI. We then use the same process when we want to set its value. We take the input we receive from CanadianQuoteAPI which will be in kilometers and translate it into miles. Note that we do not store the car mileage in our CanadianQuoteAPI. We translate it and save it in an instance of the OriginalQuoteAPI (our target). Our CanadianQuoteAPI is not a replacement of our original API, it is an adapter. It simply works as a middleman for converting our data from one standard to another.

In the case of carMileage we need to translate our data from one standard to another, before we save or retrieve its value, for something like labor time (laborInMinute) we don't have to do this.

```Swift
  var laborInMinutes: Int {
    get {
      return target.laborInMinutes
    }

    set(newValue) {
      target.laborInMinutes = newValue
    }
  }
```

The definition of time or minute to be more specific is the same in US as it is in Canada. Therefor we simply take the value and pass it as-is to our target. Again note that we do not save any of these values locally and simply act as the middleman (adapter) between original API (target) and the outside world.

Let's look out the rest of our definition.

```Swift
  var laborCost: Double {
    get {
      return ((Double(target.laborInMinutes) / 60.0) * self.laborRatePerHour) 
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
```

We have three readonly definitions that we need to cover. Labor cost, part cost and total cost. Labor cost for our CanadianQuoteAPI will be our labor time which is saved in our target, divided by 60, multiplied by our canadian labor rate. Since our Canadian labor rate is already in CAD we do not need to worry about currency conversion.

Our parts cost however will be in USD since we will retrieve it directly from our OriginalAPI. We will convert it to CAD by multiplying with the exchange rate we set initially for our USD to CAD.

Our total cost will be our CanadianQuoteAPI's labor cost plus our parts cost summed with our Canadian tax rate. All the values we retrieve for these three properties will be in Canadian dollars. We do not need to save any of these values as they are derived directly from our original API.

Finally let's look at how we add and remove parts.

```Swift
  func addPart(part: Part) {
    part.price = part.price * cadToUsd
    target.addPart(part)
  }

  func removePart(part: Part) {
    target.removePart(part)
  }  
```

Since parts being added through our CanadianQuoteAPI will be in CAD we need to change their price to USD before adding them to the OrigianlAPI. We have to ensure that everything in our original API remains in USD. Remember we are building this adapter so our old system will work under these new condition, as such we have to ensure the new conditions do not alter the data we save in our original API.

We do not need to worry about part's prices when we are removing them from our part's set so we simply call the target's removePart with the part being passed from our CanadianQuoteAPI.

And this is it. We are done with our adapter. Lets test it out.

```Swift

var originalAPI = OriginalQuoteAPI()

// We add two parts, set how long it takes to do the job and add the car's mileage
originalAPI.addPart(Part(partId: 15, name: "Brake Fluid", price: 20.00))
originalAPI.addPart(Part(partId: 8, name: "Filters", price: 10.00))
originalAPI.laborInMinutes = 60
originalAPI.carMileage = 11000
print("original API total cost:")
print(originalAPI.totalCost)


var canadianAPI = CanadianQuoteAPI(target: originalAPI,
                                   tax: 0.20,
                                   laborRatePerHour: 50.00,
                                   cadToUsd: 0.75,
                                   usdToCad: 1.2)
print("Canadian API total cost with a 1.2 USD to CAD exchange rate:")
//Print total cost in CAD
print(canadianAPI.totalCost)

//Add part through Canadian API, price will be in CAD
canadianAPI.addPart(Part(partId: 63, name: "Regular Oil", price: 5.00))

print("Original API total cost after a $5 CAD part is added:")
//Print total cost in USD
print(originalAPI.totalCost)

print("Canadian API total cost after a $5 CAD part is added:")
//Print total cost in CAD
print(canadianAPI.totalCost)


print("Original API part cost after a $5 CAD part is added:")
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

```

Running the test case mentioned above gives us the following output:

```
original API total cost:
96.0
Canadian API total cost with a 1.2 USD to CAD exchange rate:
103.2
Original API total cost after a $5 CAD part is added:
100.5
Canadian API total cost after a $5 CAD part is added:
108.6
Original API part cost after a $5 CAD part is added:
33.75
Mileage of the car is 11000 Miles
Mileage of the car is 17702 Kilometers
Mileage of the car is 6213 Miles
Mileage of the car is 9998 Kilometers
Program ended with exit code: 0
```

Let's break it down step by step and verify that our adapter is working correctly.

First off we create and instance of our origianlAPI. We then add two parts, one costing $20.00 and another costing $10.00. We set our labor time for this quote to be 60 minutes. The tax rate and hourly labor rate in our original API was hardcoded at %20 and $50.00 respectluvly. Therefor the total price for this quote would be:

(Filters + Brake Fluid + Labor Cost) x Tax Rate = Total
(10.00 + 20.00 + 50.00) x 1.2 = $96.00

And that is what we got.

Now lets instantiate our Canadian adapter. We will set our tax rate and hourly labor rate to be the same, however we set our exchange rate to be 0.75 USD for every CAD and 1.20 CAD for every USD. We check the price against our Canadian adapter and get 103.20. But wait a second that doesn't look right. Should our price be

((Filters + Brake Fluid + Labor Cost) x Exchange Rate) x Tax Rate = Total
((10.00 + 20.00 + 50.00) x 1.2) x 1.2 = 96 x 1.2 = $115.2?

The answer is no. The labor rate we set in our adapter is an input it received independently from the original API. The $50.00 laborRatePerHour that is passed into our CanadianQuoteAPI is in Canadian dollars. Therefor the labor cost calculated by our adapter considers that as already in CAD and does not multiply it by the 1.2 exchange rate. So the correct formula working behind our adapter is actually this:

(((Filters + Brake Fluid) x Exchange Rate + Labor Cost) x Tax Rate = Total
(((10.00 + 20.00) x 1.2) + 50) x 1.2 = $103.20

Next we'll add a part to our Quote through our Canadian API. Because our part is being added through the Adapter, it will assume that the price is in CAD. And since all our data is saved in our original API it is converted to USD. However when we ask for total price in CAD we are not getting the original CAD price rather the CAD -&gt; USD -&gt; CAD. This is technically correct but it definitely shows a possible flaw in our adapter for this problem. In our case there is a certain denigration of the price since our CAD =&gt; USD and USD =&gt; CAD are not reflective.

Because of this, when we add a $5 CAD part to our quote it is saved as

CAD 5.00 x 0.75 = 3.75

So when we get our total price in USD through our original API we get:

(Filters + Brake Fluid + Oil + Labor Cost) x Tax Rate = Total

(10.00 + 20.00 + 3.75 + 50.00) x 1.2 = $100.5

Which is fine however when we request for our canadian total, although the formula is still

(((Filters + Brake Fluid) x Exchange Rate + Labor Cost + Oil) x Tax Rate = Total
((((10.00 + 20.00) x 1.2) + 50 + 5.0) x 1.2) = $109.20?

We get $108.60

That's because, although we marked our part as $5 CAD because it is being converted to USD and back to CAD using our exchange rates, it's being returned at 90% its original valuation. Which is

((((10.00 + 20.00) x 1.2) + 50 + 4.5) x 1.2) = $108.60

What's the best way to deal with data that is not completely adaptable. Or when it is mathematically impossible to convert one value to another and have a corresponding inverse function that can convert it back. Thankfully converting Miles to KM and vice-versa is rather trivial. I'll leave confirming that to you.

Congratulations you have just implemented the Adapter Design Pattern to solve a nontrivial problem.

The repo for the complete project can be found here: <a href="https://github.com/kingreza/Swift-Adapter">Swift - Adapter.</a>

Download a copy of it and play around with it. See if you can find ways to improve its design, Add more complex functionalities. Here are some suggestions on how to expand or improve on the project:
<ul>
  <li>We need to be able to provide receipts in French as well as in English, assume the original API has an English receipt generator, expand our adapter to provide a french version of it</li>
  <li>How can we deal with prices changing when we go from CAD =&gt; USD =&gt; CAD?</li>
</ul>
