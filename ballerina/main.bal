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
const PATH_INDEX = "../index/";
const EXT_JSON = ".json";

public function main() returns error? {

    // check fetachAllOrgs();
    // check fetchAllDocs();
    check buildKeyowrdIndex([ORG_BALLERINA, ORG_BALLERINAX, ORG_WSO2]);
    check buildConnectionIndex();

}

type DocTable table<record {|readonly string org; readonly string module; DocsResponse doc;|}> key(org, module);

function buildConnectionIndex() returns error? {

    DocTable docsTable = table [];
    IndexConnections connections = {categories: []};
    IndexNodeTemplateGroup nodeTemplates = {};

    foreach DataConnectionGroup group in connectionBuilder.groups {
        IndexCategory category = {metadata: {label: group.label}, items: <IndexCategory[]>[]};
        connections.categories.push(category);
        foreach DataConnection item in group.items {
            // Derive rest of the connection details from the reference
            [IndexCategory, IndexNodeTemplate[]] data = check deriveConnectionData(item.ref, item.label, docsTable);
            category.items.push(data[0]);
            foreach IndexNodeTemplate template in data[1] {
                nodeTemplates.connections[template.codedata.node + ":" + template.codedata.module + ":" + <string>template.codedata.'object + ":" + template.codedata.symbol] = template;
            }
        }
    }
    check io:fileWriteJson(PATH_INDEX + "connections.json", connections);
    check io:fileWriteJson(PATH_INDEX + "nodeTemplates.json", nodeTemplates);
}

function deriveConnectionData([string, string, string] ref, string label, DocTable cache) returns [IndexCategory, IndexNodeTemplate[]]|error {
    // Derive the connection data from the reference
    DocsResponse doc;
    if cache.hasKey([ref[0], ref[1]]) {
        doc = cache.get([ref[0], ref[1]]).doc;
    } else {
        doc = check jsondata:parseStream(check io:fileReadBlocksAsStream(PATH_SOURCES + ref[0] + "/" + ref[1] + "/doc.json"));
        cache.put({org: ref[0], module: ref[1], doc: doc});
    }
    ClientItem[] connections = from ClientItem item in doc.docsData.modules[0].clients ?: []
        where item.id == ref[2] || item.name == ref[2]
        select item;
    if connections.length() == 0 || connections.length() > 1 {
        return error("Client not found", ref = ref, found = connections.length());
    }
    ClientItem connection = connections[0];
    IndexCategory indexCategory = {metadata: {label, description: connection.description}, items: <IndexNode[]>[]};
    IndexNodeTemplate[] nodeTemplates = [];

    // Init method
    [IndexNode, IndexNodeTemplate] [initNode, initTemplate] = check handleInitMethod(ref, connection);
    indexCategory.items.push(initNode);
    nodeTemplates.push(initTemplate);

    // JBallerina Bug. LHS type is not parsed correctly. Hence using var.
    var [nodes, templates] = check handleRemoteMethods(ref, connection);
    indexCategory.items.push(...nodes);
    nodeTemplates.push(...templates);
    return [indexCategory, nodeTemplates];
}

function handleInitMethod([string, string, string] ref, ClientItem connection) returns [IndexNode, IndexNodeTemplate]|error {
    IndexNode initNode = {
        metadata: {label: "New Connection", description: "Create a new connection"},
        codedata: {node: "NEW_CONNECTION", module: ref[1], symbol: "init", org: ref[0], 'object: ref[2]},
        enabled: true
    };
    IndexNodeTemplate initTemplate = {
        metadata: initNode.metadata,
        codedata: initNode.codedata,
        properties: {},
        flags: 0
    };
    string prefix = ref[1];
    if ref[1].includes(".") {
        prefix = ref[1].substring(<int>ref[1].lastIndexOf(".") + 1);
    }
    initTemplate.codedata["importStmt"] = "import " + ref[0] + "/" + ref[1] + " as " + prefix;

    map<IndexProperty> properties = {};
    initTemplate.properties = properties;
    properties["scope"] = {
        metadata: {label: "Connection Scope", description: "Scope of the connection, Global or Local"},
        valueType: "Enum",
        value: "Global",
        optional: false,
        editable: false,
        valueTypeConstraints: {'enum: ["Global", "Local"]},
        'order: 0
    };
    properties["variable"] = {
        metadata: {label: "Variable", description: "Variable to store the connection"},
        valueType: "Identifier",
        value: "connection",
        optional: false,
        editable: true,
        'order: 1,
        valueTypeConstraints: {identifier: {isExistingVariable: false, isNewVariable: true}}
    };
    properties["type"] = {
        metadata: {label: "Type", description: "Type of the connection"},
        value: prefix + ":" + ref[2],
        valueType: "Type",
        optional: false,
        editable: false,
        valueTypeConstraints: {'type: {"value": prefix + ":" + ref[2]}},
        'order: 2
    };

    // Find init method.
    MethodsItem? init = connection.initMethod;
    if init is () {
        // Check for method parameters
        MethodsItem[] methods = connection.methods ?: [];
        if methods.length() == 0 || methods.filter(m => m.name == "init").length() == 0 {
            // No explicit init method found
        } else {
            init = methods.filter(m => m.name == "init")[0];
        }
    }
    if init !is () {
        // Add method parameters as properties
        handleMethodParameters(init, properties, false);
    }

    // TODO: Check init contains errors. Use category field. Following is a temporary fix. 
    setCheckedFlag(initTemplate);
    return [initNode, initTemplate];
}

function handleRemoteMethods([string, string, string] ref, ClientItem connection) returns [IndexNode[], IndexNodeTemplate[]] {
    IndexNode[] nodes = [];
    IndexNodeTemplate[] templates = [];
    RemoteMethodsItem[] methods = connection.remoteMethods ?: [];
    foreach RemoteMethodsItem method in methods {
        IndexNode node = {
            metadata: {label: method.name, description: method.description},
            codedata: {node: "ACTION_CALL", module: ref[1], symbol: method.name, org: ref[0], 'object: ref[2]},
            enabled: true
        };
        IndexNodeTemplate template = {
            metadata: node.metadata,
            codedata: node.codedata,
            properties: {},
            flags: 0
        };
        string prefix = ref[1];
        if ref[1].includes(".") {
            prefix = ref[1].substring(<int>ref[1].lastIndexOf(".") + 1);
        }
        template.codedata["importStmt"] = "import " + ref[0] + "/" + ref[1] + " as " + prefix;

        map<IndexProperty> properties = {};
        template.properties = properties;
        properties["connection"] = {
            metadata: {label: "Connection", description: "Connection to use"},
            valueType: "Identifier",
            value: "connection",
            optional: false,
            editable: true,
            'order: 0,
            valueTypeConstraints: {'type: {typeOf: prefix + ":" + ref[2]}, identifier: {isExistingVariable: true, isNewVariable: false}}
        };

        properties["variable"] = {
            metadata: {label: "Variable", description: "Variable to store the connection"},
            valueType: "Identifier",
            value: "res",
            optional: false,
            editable: true,
            'order: 1,
            valueTypeConstraints: {identifier: {isExistingVariable: false, isNewVariable: true}}
        };
        // We fix this later when we have the return type of the remote method
        properties["type"] = {
            metadata: {label: "Type", description: "Type of the result"},
            value: "", // Fixed with return type
            valueType: "Type",
            optional: false,
            editable: false,
            'order: 2
        };
        handleRemoteMethodParameters(method, properties);

        // TODO: Check init contains errors. Use category field. Following is a temporary fix. 
        setCheckedFlag(template);
        nodes.push(node);
        templates.push(template);
    }
    return [nodes, templates];
}

function setCheckedFlag(IndexNodeTemplate template) {
    template.flags = template.flags | 1;
    if template.codedata.hasKey("flags") {
        template.codedata["flags"] = <int>template.codedata["flags"] | 1;
    } else {
        template.codedata["flags"] = 1;
    }
}

function handleMethodParameters(MethodsItem method, map<IndexProperty> properties, boolean handleReturn = true) {
    Type? dependentlyTyped = ();
    foreach ParametersItem item in method.parameters {
        if handleReturn && item.defaultValue == "<>" {
            // This is dependently Typed function
            dependentlyTyped = item.'type;
        }
        properties[item.name] = {
            metadata: {label: item.name, description: item.description},
            valueType: "Expression",
            value: item.defaultValue,
            optional: item.defaultValue != "" && item.defaultValue != "<>",
            editable: true,
            valueTypeConstraints: {'type: item.'type.toJson()},
            'order: properties.length()
        };
    }
    // TODO: Handle return type
}

function handleRemoteMethodParameters(RemoteMethodsItem method, map<IndexProperty> properties, boolean handleReturn = true) {
    Type? dependentlyTyped = ();
    foreach ParametersItem item in method.parameters {
        if handleReturn && item.defaultValue == "<>" {
            // This is dependently Typed function
            dependentlyTyped = item.'type;
        }
        properties[item.name] = {
            metadata: {label: item.name, description: item.description},
            valueType: "Expression",
            value: item.defaultValue,
            optional: item.defaultValue != "" && item.defaultValue != "<>",
            editable: true,
            valueTypeConstraints: {'type: item.'type.toJson()},
            'order: properties.length()
        };
    }
    if method.returnParameters.length() > 0 {
        // TODO: Improve. We fix this later. Assume dependently typed allways used if present.
        // Also we assume checked is always present, so we ignore errors.
        IndexProperty typeProperty = <IndexProperty>properties["type"];

        ReturnParametersItem returnParametersItem = method.returnParameters[0];
        if dependentlyTyped !is () {
            if dependentlyTyped.category == "types" {
                // This is refering to a Type definition (80% case) and we need to get the type from semantic model.
                // As a temporary fix we assume the type is a json object..
                typeProperty.value = "map<json>"; // Ideally we need a built in type called JSON objects. 
            } else {
                typeProperty.value = dependentlyTyped.name ?: "json";
            }
        } else {
            // Improve this logic for union and others. 
            if returnParametersItem.'type.memberTypes.length() > 0 {
                // This is a union type. Get the first non-error type for now. 
                // TODO: Improve this logic
                foreach var item in returnParametersItem.'type.memberTypes {
                    if item.category != "errors" {
                        typeProperty.value = item.name ?: "json";
                        break;
                    }
                }
            } else {
                typeProperty.value = returnParametersItem.'type.name ?: "json";
            }
            typeProperty.valueTypeConstraints = {'type: returnParametersItem.'type.toJson()};
        }
    }
}

function buildKeyowrdIndex(string[] orgs) returns error? {
    final map<IndexKeyword[]> functionKeywordIndex = {};
    final map<IndexKeyword[]> clientKeywordIndex = {};
    final map<IndexKeyword[]> listenerKeywordIndex = {};
    foreach string org in orgs {
        GetPackagesResponse pkgsRes = check jsondata:parseStream(check io:fileReadBlocksAsStream(PATH_SOURCES + org + EXT_JSON));
        foreach PackagesItem pkg in pkgsRes.packages {
            foreach RegModulesItem mod in pkg.modules {
                var module = mod.name;
                var keywords = pkg.keywords;
                var version = pkg.version;
                do {
                    io:println(string `Building index for ${org}/${module}/${version}`);
                    DocsResponse doc = check jsondata:parseStream(check io:fileReadBlocksAsStream(PATH_SOURCES + org + "/" + module + "/doc.json"));
                    if doc.searchData.functions.length() == 0 && doc.searchData.listeners.length() == 0 && doc.searchData.clients.length() == 0 {
                        // Skip if no functions, listeners or clients found
                        continue;
                    }
                    if doc.searchData.functions.length() > 0 {
                        string?[] ids = doc.searchData.functions.'map(a => a.id);
                        updateKeywordIndex(functionKeywordIndex, ids, keywords, org, module, version);
                    }
                    if doc.searchData.clients.length() > 0 {
                        string?[] ids = doc.searchData.clients.'map(a => a.id);
                        updateKeywordIndex(clientKeywordIndex, ids, keywords, org, module, version);
                    }
                    if doc.searchData.listeners.length() > 0 {
                        string?[] ids = doc.searchData.listeners.'map(a => a.id);
                        updateKeywordIndex(listenerKeywordIndex, ids, keywords, org, module, version);
                    }
                } on fail error err {
                    io:println(string `Error fetching docs for ${org}/${module}/${version}: `, err.message());
                }
            }
        }
    }
    check io:fileWriteJson(PATH_INDEX + "keywords/function.json", sortKeys(functionKeywordIndex));
    check io:fileWriteJson(PATH_INDEX + "keywords/client.json", sortKeys(clientKeywordIndex));
    check io:fileWriteJson(PATH_INDEX + "keywords/listener.json", sortKeys(listenerKeywordIndex));
}

function sortKeys(map<json> data) returns map<json> {
    map<json> sortedData = {};
    string[] keys = data.keys().sort();
    foreach string key in keys {
        sortedData[key] = data[key];
    }
    return sortedData;
}

function updateKeywordIndex(map<IndexKeyword[]> keywordIndex, string?[] ids, string[] keywords, string org, string module, string version) {
    foreach string keyword in keywords {
        if keywordIndex.hasKey(keyword) {
            IndexKeyword[] items = keywordIndex.get(keyword);
            items.push({org, module, version, ids});
        } else {
            keywordIndex[keyword] = [{org, module, version, ids}];
        }
    }
    if keywords.length() == 0 {
        // Add the module to the index if no keywords found
        if keywordIndex.hasKey("") {
            IndexKeyword[] items = keywordIndex.get("");
            items.push({org, module, version, ids});
        } else {
            keywordIndex[""] = [{org, module, version, ids}];
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
