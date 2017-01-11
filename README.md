JavaScript/TypeScript to Swift Transpiler aka JSON with functions
==============

JSON is a widely adopted format for storing information.
It's very portable and can be easily parsed in any programming language.
As such, it can be used to share common data across multiple development platforms.

Let's say we're developing an app for iOS, Android and the browser.
Let's say our app needs to handle conversion between units of measurement.
We don't want to declare this data separately for every language that we use.
Let's store everything in one JSON file that we can reuse across all platforms:
```JSON
{
    "weight": {
        "g": {"isBase": true, "factor": 1},
        "mg": {"isBase": false, "factor": 0.001},
        "kg": {"isBase": false, "factor": 1000},
        "pound": {"isBase": false, "factor": 453.592}
    }
}
```

So far, so good - this data will tell our app how to convert weight measures.
But what if we wanted to add Celsius and Fahrenheit?
Those two aren't trivial to convert between each other.
Ideally, we would write a function to do it:
```TypeScript
const units = {
    temperature: {
        C: {
            isBase: true,
            toBase: (val:number):number => val,
            fromBase: (val:number):number => val
        },
        F: {
            isBase: false,
            toBase: (val:number):number => val * 5 / 9 + 32,
            fromBase: (val:number):number => val * 9 / 5 + 32
        }
    }
}
```

Unfortunately, there's no easy way to reuse this TypeScript code in a Swift or a Java project.
We would need to rewrite the same function in each language.
What if we then think of another unit of measurement that requires a function?
We would need to add it in three different code bases.

Enter this transpiler.

The aim of the project is to create a "JSON with functions" that would be reusable in different languages
and able to store both data as well as functions.

The transpiler will convert the above code to Swift:
```Swift
let units = [
    "temperature": [
        "C": (
            isBase : true ,
            toBase : { (val:Double) -> Double in val },
            fromBase : { (val:Double) -> Double in val }
        ),
        "F": (
            isBase : false ,
            toBase : { (val:Double) -> Double in val * 5.0 / 9.0 + 32.0 },
            fromBase : { (val:Double) -> Double in val * 9.0 / 5.0 + 32.0 }
        )
    ]
]
```

Check out http://typeswift.com/ts-to-swift for live preview.

It's early days and the project is only at a "proof of concept" stage as yet.
I'm using it to transpile JSONs in a pet project of mine, so I will be adding more functionality as I go along.

What are your thoughts? If enough people find it useful, I'll try and bring in full Swift support,
as well as conversion to Java and possibly other languages.

Please leave a star or drop me a line at marcelganczak@gmail.com. Any contributions welcome!

Also, check out my reverse project (Swift to JS/Java transpiler), which happens to be more robust:
https://github.com/marcelganczak/swift-js-transpiler

Usage
==============

You will need Java to run the transpiler.

It will grab the contents of example.ts in the root folder and print the transpiled Swift into console.

License
==============

MIT