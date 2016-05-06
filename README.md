<h1>Design Patterns in Swift: Adapter</h1>
This repository is part of a series. For the full list check out <a href="https://shirazian.wordpress.com/2016/04/11/design-patterns-in-swift/">Design Patterns in Swift</a>

<h3>The problem:</h3>
<a href="http://www.yourmechanic.com">YourMechanic</a> is expanding to Canada. Now our friends to the north can have their cars fixed at their home or office by one of our professional mechanics. To finalize our expansion we need to make some changes to our system. Providing support for the Canadian currency and the metric system would be a lot of work so we want an easy way to interface with our current Quote API. The Quote API can add and remove parts, set tax rates, set labor rates, set labor times for a quote, calculate a total price and track a car's mileage. All these values are assumed in USD/Imperial by our current system. We need a way to both display and input values in CAD and the metric system and have it remain consistent throughout our system. 

<!--more-->

<h3>The solution:</h3>

Link to the repo for the completed project: <a href="https://github.com/kingreza/Swift-Adapter">Swift - Adapter</a>
