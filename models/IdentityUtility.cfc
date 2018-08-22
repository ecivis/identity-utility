component {

    /**
    * Hang on to an instance if you want to retain preferences
    * @preferredUUIDStyle May be cfml, jvm, or mssql. It's called "jvm" instead of "java" because it really depends on the JVM you're using.
    */
    public IdentityUtility function init(string preferredUUIDStyle) {
        if (structKeyExists(arguments, "preferredUUIDStyle")) {
            setPreferredUUIDStyle(arguments.preferredUUIDStyle);
        }
        return this;
    }

    /**
    * Produces a Type 4 pseudo random UUID using java.util.UUID. See https://docs.oracle.com/javase/8/docs/api/java/util/UUID.html
    */
    public string function jvmuuid() {
        return createObject("java", "java.util.UUID").randomUUID();
    }

    /**
    * UUIDs in CFML have the fourth hyphen removed and are expressed in uppercase. Use this function for compatibility with createUUID()
    */
    public string function cfmluuid() {
        var id = jvmuuid();
        return ucase(left(id, 23) & right(id, 12));
    }

    /**
    * Produces a UUID consistent with Microsoft SQL Server's UNIQUEIDENTITY data type
    */
    public string function mssqluuid() {
        return ucase(jvmuuid());
    }

    /**
    * Produces a UUID using the preferred style. See also setPreferredUUIDStyle()
    */
    public string function uuid() {
        var style = getPreferredUUIDStyle();

        if (style == "cfml") {
            return cfmluuid();
        }
        if (style == "mssql") {
            return mssqluuid();
        }
        if (style == "jvm") {
            return jvmuuid();
        }
        throw(type="UnknownUUIDStyleException", message="The configured UUID style preference [#style#] is not valid.");
    }

    /**
    * Get the preferred UUID style, where jvm is the default.
    */
    public string function getPreferredUUIDStyle() {
        if (structKeyExists(variables, "preferredUUIDStyle")) {
            return variables.preferredUUIDStyle;
        }
        return "jvm";
    }

    /**
    * Change the UUID style after initialization. If you're into that sort of thing.
    */
    public void function setPreferredUUIDStyle(required string preferredUUIDStyle) {
        if (!structKeyExists(getSupportedStyles(), arguments.preferredUUIDStyle)) {
            throw(type="UnsupportedPreferenceException", message="The specified UUID style preference [#arguments.preferredUUIDStyle#] is not suported.");
        }
        variables.preferredUUIDStyle = arguments.preferredUUIDStyle;
    }

    /**
    * Returns a normalized version of UUID in the style requested
    * @input This may be any garbled version of a UUID and we'll do our best.
    * @desiredStyle Options are jvm, cfml, and mssql
    */
    public string function normalizeUUID(required string input, required string desiredStyle) {
        var buff = arguments.input;
        var style = "";

        if (!structKeyExists(getSupportedStyles(), arguments.desiredStyle)) {
            throw(type="InvalidUUIDStyleException", message="The specified UUID style preference [#arguments.desiredUUIDStyle#] is not suported.");
        }
        style = arguments.desiredStyle;

        /* Remove one level of double-URL encoding. Perhaps a future version could recurse until all levels have been removed. */
        buff = replaceNoCase(buff, "%25", "%", "all");

        /* Remove URL encoding, if it exists */
        buff = replaceNoCase(buff, "%2D", "-", "all");

        /* Grab just the hex characters */
        buff = reReplaceNoCase(buff, "[^0-9a-f]", "", "all");

        if (len(buff) != 32) {
            throw(type="InvalidUUIDException", message="A UUID should have 32 characers of hex. Yours [#arguments.input#] did not.");
        }

        if (style == "cfml") {
            return ucase(left(buff, 8) & "-" & mid(buff, 9, 4) & "-" & mid(buff, 13, 4) & "-" & right(buff, 16));
        }
        if (style == "mssql") {
            return ucase(left(buff, 8) & "-" & mid(buff, 9, 4) & "-" & mid(buff, 13, 4) & "-" & mid(buff, 17, 4) & "-" & right(buff, 12));
        }
        if (style == "jvm") {
            return lcase(left(buff, 8) & "-" & mid(buff, 9, 4) & "-" & mid(buff, 13, 4) & "-" & mid(buff, 17, 4) & "-" & right(buff, 12));
        }
        return "";
    }

    /**
    * Returns a boolean value representing the validity of the input for the given style. Unexpected case-sensitivity does not cause a validation failure.
    * @input A string to evaluate for the specified style
    * @style Options are jvm, cfml, and mssql
    */
    public boolean function validateUUID(required string input, required string style) {
        if (!structKeyExists(getSupportedStyles(), arguments.style)) {
            throw(type="UnsupportedStyleException", message="The specified UUID style [#arguments.preferredUUIDStyle#] is not suported.");
        }

        if (reFindNoCase("[^-0-9a-f]", arguments.input)) {
            return false;
        }
        if (arguments.style == "jvm" || arguments.style == "mssql") {
            if (len(arguments.input) != 36) {
                return false;
            }
            if (reFindNoCase("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", arguments.input) != 1) {
                return false;
            }
        }
        if (arguments.style == "cfml" && len(arguments.input) != 36) {
            if (len(arguments.input) != 35) {
                return false;
            }
            if (reFindNoCase("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{16}$", arguments.input) != 1) {
                return false;
            }
        }

        return true;
    }

    private struct function getSupportedStyles() {
        if (structKeyExists(variables, "_supportedStyles")) {
            return variables._supportedStyles;
        }
        variables._supportedStyles = {
            "jvm": 1,
            "cfml": 1,
            "mssql": 1
        };
        return variables._supportedStyles;
    }

}