
swift-steem
===========

Official Steem library for Swift.

Resources:

  * [API documentation](https://steemit.github.io/swift-steem/)
  * [Issue tracker](https://github.com/steemit/swift-steem/issues)
  * [Steem developer portal](https://developers.steem.io)


Installation
------------

Using the [Swift package manager](https://swift.org/package-manager/):

In your Package.swift add:

```
dependencies: [
    .package(url: "https://github.com/steemit/swift-steem.git", .branch("master"))
]
```

and run `swift package update`. Now you can `import Steem` in your Swift project.


Running tests
-------------

To run all tests simply run `swift test`, this will run both the unit- and integration-tests. To run them separately use the `--filter` flag, e.g. `swift test --filter SteemIntegrationTests`


Developing
----------

Development of the library is best done with Xcode, to generate a `.xcodeproj` you need to run `swift package generate-xcodeproj`.

To enable test coverage display go "Scheme > Manage Schemes..." menu item and edit the "Steem-Package" scheme, select the Test configuration and under the Options tab enable "Gather coverage for some targets" and add the `Steem` target.

After adding adding more unit tests the `swift test --generate-linuxmain` command has to be run and the XCTestManifest changes committed for the tests to be run on Linux.
