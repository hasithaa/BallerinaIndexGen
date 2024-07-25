import ballerina/data.jsondata;
import ballerina/file;
import ballerina/http;
import ballerina/io;

type Index record {|
    Category functions;
    Category connections;
|};

// final Index index = {
//     functions: {
//         metadata: {label: "", description: ""},
//         items: <AvailableNode[]>[]
//     },
//     connections: {
//         metadata: {label: "", description: ""},
//         items: <AvailableNode[]>[]
//     }
// };

final http:Client cl = check new ("https://api.central.ballerina.io/2.0/registry/");

public function main() returns error? {

    // check fetchPackages("ballerina", "log");
    io:println(jsondata:prettify(check getSymbols("ballerina", "log")));
    // check fetchPackages("ballerina", "http");
    // check fetchPackages("ballerinax", "redis");
    // check fetchPackages("ballerina", "data.xmldata");
    // check fetchPackages("ballerina", "data.jsondata");
}

public function getSymbols(string org, string package) returns json|error {
    final string balaPath = string `../sources/${org}/${package}/${package}.bala`;
    if check file:test(balaPath, file:EXISTS) {
        return buildBala(balaPath);
    }
    return {};
}


public function fetchPackages(string org, string package) returns error? {

    final string orgPath = string `../sources/${org}`;
    final string packagePath = string `../sources/${org}/${package}`;

    if !check file:test(orgPath, file:EXISTS) {
        check file:createDir(orgPath);
    }
    http:Response res = check cl->get(string `packages?org=${org}&package=${package}&user-packages=false`);
    GetPackages pkgResult = check jsondata:parseStream(check res.getByteStream());
    if pkgResult.packages.length() > 0 {
        PackagesItem item = pkgResult.packages[0];
        if !check file:test(packagePath, file:EXISTS) {
            check file:createDir(packagePath);
        }
        check io:fileWriteJson(string `../sources/${org}/${package}/package.json`, item.toJson());
        final http:Client balaCl = check new (item.balaURL);
        http:Response balRes = check balaCl->get("");
        check io:fileWriteBlocksFromStream(string `../sources/${org}/${package}/${package}.bala`, check balRes.getByteStream());
    }
}
