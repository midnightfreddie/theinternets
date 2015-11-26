# 2015-11-25
# https://www.reddit.com/r/PowerShell/comments/3u7p4j/is_it_possible_to_use_digest_authentication_with/
# NOT COMPLETE OR TESTED AGAINST DIGEST AUTH SERVER. This is just an example at how I think this would go.

[cmdletbinding()]
param(
    $username = "username",
    $password = "password",
    $realm = "realm"
)

function Calculate-cnonce-with-md5-stuff {
    "TBD"
}

function Calculate-response-with-md5-stuff {
    "TBD"
}

$Uri = "http://www.example.tld/digest-authenticated-page.html"
# Hmm, need this for the auth header...should determine this programatically not literally
$UriPath = "/digest-authenticated-page.html"

# This is expected to return with 401 unauthorized
$FirstRequest = Invoke-WebRequest -Uri $Uri
# Maybe parse $FirstRequest.Headers["qop"] as part of a robust generic solution
$qop = "auth"
$nc = 1
$nonce = $FirstRequest.Headers["nonce"]
$opaque = $FirstRequest.Headers["opaque"]

# stub functions...would surely need to send username, password and nonce at least as parameters
$cnonce = Calculate-cnonce-with-md5-stuff
$response = Calculate-response-with-md5-stuff

# maybe should create a native hash then create string from it instead of here-string
# note: Per Wikipedia, nc is hex counter, so formatting it {0:X8} .. hex zero-padded to 8 digits
$authorization = @"
Digest username="$username",
                     realm="$realm",
                     nonce="$nonc3",
                     uri="$UriPath",
                     qop=$qop,
                     nc=$("{0:X8}" -f $nc),
                     cnonce="$cnonce",
                     response="$response",
                     opaque="$opaque"
"@

Write-Verbose $authorization

# real code again, but presumed values
# Splatting the Invoke-Webrequest parameters for readability/maintainability
$Parameters = @{
    Uri = $Uri
    Headers = @{
        Authorization = $authorization
    }
}
$MyAuthenticatedRequest = Invoke-WebRequest @Parameters

# For subsequent requests, increace nc for each...doesn't have to be by one, but why not by one?:
$nc = $nc + 1
# pseudocode:
# recalculate cnonce ... and/or response?
# then rebuild auth header--and parameters hash if splatting--and make the next request