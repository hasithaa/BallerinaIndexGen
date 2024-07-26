import ballerina/file;
import ballerina/http;
import ballerina/data.jsondata;
import ballerina/io;

function compileandExportSymbols(string org, string package) returns json|error {
    final string balaPath = string `../sources/${org}/${package}/${package}.bala`;
    if check file:test(balaPath, file:EXISTS) {
        return buildBala(balaPath);
    }
    return error (string `${org}:${package} Bala not found`);
}

function fetchPackage(string org, string package) returns error? {

    final string orgPath = string `../sources/${org}`;
    final string packagePath = string `../sources/${org}/${package}`;

    if !check file:test(orgPath, file:EXISTS) {
        check file:createDir(orgPath);
    }
    http:Response res = check cl->get(string `packages?org=${org}&package=${package}&user-packages=false`);
    GetPackagesResponse pkgResult = check jsondata:parseStream(check res.getByteStream());
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
