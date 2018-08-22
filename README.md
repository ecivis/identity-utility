# Identity Utility

This is a ColdBox Module with a modest goal of aiding in creating, converting, and validating unique identities. It's not specific to UUIDs, but that's what's implemented currently.

## Requirements
- Lucee 4.5+ or Adobe ColdFusion 10+
- ColdBox 4+

## Installation

Install using [CommandBox](https://www.ortussolutions.com/products/commandbox):
`box install identity-utility`

### API Documentation

To generate API documentation (for the one modest component in this project), execute the following:
`box run-script generate-docs`
The resulting static files can be viewed in a web browser from `identity-utility/apidocs/index.html`

### Tests

To run the tests, execute the following:
```
box server start
box testbox run
```
This will fire up an embedded server and run the TestBox spec for the utility, returning the results to the shell.

## Usage

Within the component you'd like to make use of the Identity Utility, have WireBox inject an instance for you from the module's namespace:
```
property name="idutil" inject="identityUtility@IdentityUtility";
```
Once you have a reference to it, you can retrieve a new UUID using one of these methods:
- `uuid()`
- `jvmuuid()`
- `cfmluuid()`
- `mssqluuid()`

You can easily normalize and convert a garbage UUID:
```
variables.idutil.normalizeUUID("43DC4B19%252D0342%252D42D2%252DA0A1%252D6909B0C7D588", "cfml");
```

A value can be validated to be a UUID with the specified style:
```
variables.idutil.validateUUID(uncertainInput, "jvm");
```

With an instance of the utility, you can persist the desired UUID style:
```
variables.idutil.setPreferredUUIDStyle("mssql")
````
After specifying the preferred UUID style, calls to `uuid()` method will use your preference.

See the [TestBox](https://www.ortussolutions.com/products/testbox) test spec at `/tests/specs/TestIdentityUtility.cfc` for more ideas.

## License

See the [LICENSE](LICENSE.txt) file for license rights and limitations (MIT).
