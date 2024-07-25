import ballerina/jballerina.java;


isolated function buildBala(string path) returns json = @java:Method {
    'class: "io.ballerina.lib.compiler.api.Compiler"
} external;

isolated function init() {
    setModule();
}

isolated function setModule() = @java:Method {
    'class: "io.ballerina.lib.compiler.api.ModuleUtils"
} external;