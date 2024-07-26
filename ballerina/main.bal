import ballerina/data.jsondata;
import ballerina/file;
import ballerina/http;
import ballerina/io;

final http:Client cl = check new ("https://api.central.ballerina.io/2.0/registry/");
final http:Client docCl = check new ("https://api.central.ballerina.io/2.0/docs/");
const ORG_BALLERINA = "ballerina";
const ORG_BALLERINAX = "ballerinax";
const ORG_WSO2 = "wso2";

const PATH_SOURCES = "../sources/";
const EXT_JSON = ".json";

public function main() returns error? {

    // check fetachAllOrgs();
    // check fetchAllDocs();
    check buildIndex([ORG_BALLERINA, ORG_BALLERINAX, ORG_WSO2]);

}

function buildIndex(string[] orgs) returns error? {
    foreach string org in orgs {
        GetPackagesResponse pkgsRes = check jsondata:parseStream(check io:fileReadBlocksAsStream(PATH_SOURCES + org + EXT_JSON));
        foreach PackagesItem pkg in pkgsRes.packages {
            foreach RegModulesItem mod in pkg.modules {
                check buildIndexPerModule(org, mod.name, pkg.version, pkg.keywords);
            }
        }
    }

    check io:fileWriteJson(PATH_SOURCES + "keywords/function.json", sortKeys(functionKeywordIndex));
    check io:fileWriteJson(PATH_SOURCES + "keywords/client.json", sortKeys(clientKeywordIndex));
    check io:fileWriteJson(PATH_SOURCES + "keywords/listener.json", sortKeys(listenerKeywordIndex));
}

final map<[string, string, string][]> functionKeywordIndex = {};
final map<[string, string, string][]> clientKeywordIndex = {};
final map<[string, string, string][]> listenerKeywordIndex = {};

function sortKeys(map<json> data) returns map<json> {
    map<json> sortedData = {};
    string[] keys = data.keys().sort();
    foreach string key in keys {
        sortedData[key] = data[key];
    }
    return sortedData;
}

function buildIndexPerModule(string org, string module, string version, string[] keywords) returns error? {
    do {
        io:println(string `Building index for ${org}/${module}/${version}`);
        DocsResponse doc = check check jsondata:parseStream(check io:fileReadBlocksAsStream(PATH_SOURCES + org + "/" + module + "/doc.json"));
        if doc.searchData.functions.length() == 0 && doc.searchData.listeners.length() == 0 && doc.searchData.clients.length() == 0 {
            // Skip if no functions, listeners or clients found
            return;
        }
        if doc.searchData.functions.length() > 0 {
            updateKeywordIndex(functionKeywordIndex, keywords, org, module, version);
        }
        if doc.searchData.clients.length() > 0 {
            updateKeywordIndex(clientKeywordIndex, keywords, org, module, version);
        }
        if doc.searchData.listeners.length() > 0 {
            updateKeywordIndex(listenerKeywordIndex, keywords, org, module, version);
        }
        // io:println(string `${keywords.toString()}`);
        // io:println(string `${doc.searchData.functions.length()} functions found`);
        // io:println(string `${doc.searchData.clients.length()} clients found`);
        // io:println(string `${doc.searchData.listeners.length()} Listeners found`);
    } on fail error err {
        io:println(string `Error fetching docs for ${org}/${module}/${version}: `, err.message());
    }
}

function updateKeywordIndex(map<[string, string, string][]> keywordIndex, string[] keywords, string org, string module, string version) {
    foreach string keyword in keywords {
        if keywordIndex.hasKey(keyword) {
            [string, string, string][] items = keywordIndex.get(keyword);
            items.push(([org, module, version]));
        } else {
            keywordIndex[keyword] = [[org, module, version]];
        }
    }
    if keywords.length() == 0 {
        // Add the module to the index if no keywords found
        if keywordIndex.hasKey("") {
            [string, string, string][] items = keywordIndex.get("");
            items.push(([org, module, version]));
        } else {
            keywordIndex[""] = [[org, module, version]];
        }
    }
}

function fetchAllDocs() returns error? {
    check fetchOrgDoc(ORG_BALLERINA);
    check fetchOrgDoc(ORG_BALLERINAX, true);
    check fetchOrgDoc(ORG_WSO2);
}

function fetchOrgDoc(string org, boolean ignoreExist = false) returns error? {
    GetPackagesResponse pkgsRes = check jsondata:parseStream(check io:fileReadBlocksAsStream(PATH_SOURCES + org + EXT_JSON));
    foreach PackagesItem pkg in pkgsRes.packages {
        foreach RegModulesItem mod in pkg.modules {
            check fetchModuleDocs(org, mod.name, pkg.version, ignoreExist);
        }
    }
}

function fetchModuleDocs(string org, string module, string version, boolean ignoreExist) returns error? {
    if !check file:test(PATH_SOURCES + org + "/" + module, file:EXISTS) {
        check file:createDir(PATH_SOURCES + org + "/" + module, file:RECURSIVE);
    }
    if ignoreExist && check file:test(PATH_SOURCES + org + "/" + module + "/doc.json", file:EXISTS) {
        io:println(string `Skiped docs for ${org}/${module}/${version}`);
        return;
    }
    io:println(string `Fetching docs for ${org}/${module}/${version}`);
    do {
        json doc = check docCl->get(string `/${org}/${module}/${version}`);
        check io:fileWriteJson(PATH_SOURCES + org + "/" + module + "/doc.json", doc);
    } on fail {
        io:println(string `Error fetching docs for ${org}/${module}/${version}`);
    }
}

function fetachAllOrgs() returns error? {
    check io:fileWriteJson(PATH_SOURCES + ORG_BALLERINA + EXT_JSON, check fetchAllPackagesInOrg("ORG_BALLERINA"));
    check io:fileWriteJson(PATH_SOURCES + ORG_BALLERINAX + EXT_JSON, check fetchAllPackagesInOrg("ORG_BALLERINAX"));
    check io:fileWriteJson(PATH_SOURCES + ORG_WSO2 + EXT_JSON, check fetchAllPackagesInOrg("ORG_WSO2"));
}

function fetchAllPackagesInOrg(string org) returns GetPackagesResponse|error {
    io:println(string `Fetching packages for ${org}`);
    GetPackagesResponse pkg = check fetchPackagesInOrgBatch(org, 15, 0);
    if pkg.count > 15 {
        int offset = 15;
        while offset < pkg.count {
            io:println(string `Fetching packages for ${org} offset ${offset}`);
            GetPackagesResponse nextPkg = check fetchPackagesInOrgBatch(org, 15, offset);
            pkg.packages.push(...nextPkg.packages);
            offset = offset + 15;
        }
    }
    if pkg.packages.length() != pkg.count {
        io:println("Error: Count mismatch");
    }
    return pkg;
}

function fetchPackagesInOrgBatch(string org, int 'limit, int offset) returns GetPackagesResponse|error {
    http:Response res = check cl->get(string `packages?org=${org}&limit=${'limit}&offset=${offset}&user-packages=false`);
    GetPackagesResponse pkgResult = check jsondata:parseStream(check res.getByteStream());
    return pkgResult;
}
