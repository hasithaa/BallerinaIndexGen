type DataConnection record {
    string label;
    [string, string, string] ref;
};

type DataConnectionGroup record {
    string label;
    DataConnection[] items;
};

type DataConnections record {
    DataConnectionGroup[] groups;
};

type IndexKeyword record {|
    string org;
    string module;
    string version;
    string?[] ids;
|};

type IndexMetadata record {|
    string label;
    string description?;
    json...;
|};

type IndexCodedata record {|
    string node;
    string module;
    string symbol;
    string org;
    string 'object?;
    json...;
|};

type IndexNode record {|
    IndexMetadata metadata;
    IndexCodedata codedata;
    boolean enabled?;
|};

type IndexCategory record {|
    IndexMetadata metadata;
    IndexNode[]|IndexCategory[] items;
|};

type IndexConnections record {|
    IndexCategory[] categories;
|};

type IndexProperty record {|
    IndexMetadata metadata;
    string valueType;
    string value;
    boolean optional;
    boolean editable;
    json valueTypeConstraints?;
    int 'order;
|};

type IndexNodeTemplate record {|
    IndexMetadata metadata;
    IndexCodedata codedata;
    map<IndexProperty> properties;
    int flags;
|};

type IndexNodeTemplateGroup record {|
    map<IndexNodeTemplate> connections = {};
    map<IndexNodeTemplate> functions = {};
|};

final json index = {
    functions: [
        // {
        //     label: "Log",
        //     items: [
        //         {org: "ballerina", module: "log", symbol: "printInfo", alias: "Info"},
        //         {org: "ballerina", module: "log", symbol: "printError", alias: "Error"},
        //         {org: "ballerina", module: "log", symbol: "printWarn", alias: "Warn"},
        //         {org: "ballerina", module: "log", symbol: "printDebug", alias: "Debug"}
        //     ]
        // },
        // {
        //     label: "Data Conversion",
        //     items: [
        //         {org: "ballerina", module: "data.jsondata", symbol: "toJson", alias: "Schema To JSON"},
        //         {org: "ballerina", module: "data.xmldata", symbol: "toXml", alias: "Schema To XML"},
        //         {org: "ballerina", module: "data.jsondata", symbol: "parseAsType", alias: "JSON To Schema"},
        //         {org: "ballerina", module: "data.xmldata", symbol: "parseAsType", alias: "XML To Schema"}
        //     ]
        // },
        // {
        //     label: "JSON",
        //     items: [
        //         {org: "ballerina", module: "data.jsondata", symbol: "read", alias: "JSON Path"},
        //         {org: "ballerina", module: "data.jsondata", symbol: "prettyPrint", alias: "JSON Pretty Print"}
        //     ]
        // },
        // {
        //     label: "XML",
        //     items: [
        //         {org: "ballerina", module: "data.xmldata", symbol: ""}
        //     ]
        // }
    ]
};

DataConnections connectionBuilder = {
    groups: [
        {
            label: "Network",
            items: [
                {
                    label: "HTTP Connection",
                    ref: ["ballerina", "http", "Client"]
                },
                {
                    label: "GraphQL Connection",
                    ref: ["ballerina", "graphql", "Client"]
                },
                {
                    label: "gRPC Connection",
                    ref: ["ballerina", "grpc", "Client"]
                },
                {
                    label: "gRPC Streaming Connection",
                    ref: ["ballerina", "grpc", "StreamingClient"]
                },
                {
                    label: "WebSocket Connection",
                    ref: ["ballerina", "websocket", "Client"]
                }
            ]
        },
        {
            label: "Databases",
            items: [
                {
                    label: "MySQL",
                    ref: ["ballerinax", "mysql", "Client"]
                },
                {
                    label: "Redis",
                    ref: ["ballerinax", "redis", "Client"]
                },
                {
                    label: "MS SQL",
                    ref: ["ballerinax", "mssql", "Client"]
                },
                // {
                //     label: "Oracle",
                //     ref: ["ballerinax", "oracle", "Client"]
                // },
                {
                    label: "MongoDB",
                    ref: ["ballerinax", "mongodb", "Client"]
                },
                {
                    label: "PostgreSQL",
                    ref: ["ballerinax", "postgresql", "Client"]
                }
            ]
        }
    ]
};
