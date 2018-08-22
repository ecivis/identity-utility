component extends="testbox.system.BaseSpec" {

    function run() {

        describe("Identity Utility", function () {
            beforeEach(function () {
                identityUtility = createObject("component", "models.IdentityUtility").init();
            });

            it("has working UUID style accessors", function () {
                identityUtility.setPreferredUUIDStyle("cfml");
                expect(identityUtility.getPreferredUUIDStyle()).toBe("cfml");

                expect( function(){
                    identityUtility.setPreferredUUIDStyle("foobar");
                }).toThrow(type="UnsupportedPreferenceException");
            });

            it("should remember the preferred UUID style", function () {
                identityUtility.setPreferredUUIDStyle("mssql");
                expect(reFind("[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}", identityUtility.uuid())).toBe(1);
            });

            it("can create a default UUID", function () {
                var uuid = identityUtility.uuid();

                // Like 43dc4b19-0342-42d2-a0a1-6909b0c7d588
                expect(reFind("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", uuid)).toBe(1);
            });

            it("can create a CFML-style UUID", function () {
                var uuid = identityUtility.cfmluuid();

                // Like 43DC4B19-0342-42D2-A0A16909B0C7D588
                expect(reFind("[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}", uuid)).toBe(1);
            });

            it("can create a MSSQL-style UUID", function () {
                var uuid = identityUtility.mssqluuid();

                // Like 43DC4B19-0342-42D2-A0A1-6909B0C7D588
                expect(reFind("[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}", uuid)).toBe(1);
            });

            it("can convert mess into a valid UUID", function () {
                var mess = "43DC4B19%252D0342%252D42D2%252DA0A1%252D6909B0C7D588";

                expect(reFind("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", identityUtility.normalizeUUID(mess, "jvm"))).toBe(1);
                expect(reFind("[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}", identityUtility.normalizeUUID(mess, "cfml"))).toBe(1);
                expect(reFind("[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}", identityUtility.normalizeUUID(mess, "mssql"))).toBe(1);
            });

            it("can validate identities", function () {
                expect(identityUtility.validateUUID("foo", "cfml")).toBe(false);
                expect(identityUtility.validateUUID(createUUID(), "cfml")).toBe(true);

                expect(identityUtility.validateUUID("43dc4b19-0342-42d2-a0a1-6909b0c7d588", "jvm")).toBe(true);
                expect(identityUtility.validateUUID("I'm Perfectly Calm, Dude", "jvm")).toBe(false);

                expect(identityUtility.validateUUID("43DC4B19-0342-42D2-A0A1-6909B0C7D588", "mssql")).toBe(true);
                expect(identityUtility.validateUUID("Calmer Than You Are", "mssql")).toBe(false);
            });

        });
    };

}