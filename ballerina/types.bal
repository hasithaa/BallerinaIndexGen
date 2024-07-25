type ModulesItem record {|
    string name;
    string summary;
    string apiDocURL;
|};

type PackagesItem record {|
    string organization;
    string name;
    string version;
    string URL;
    string balaURL;
    boolean template;
    string[] keywords;
    string ballerinaVersion;
    int createdDate;
    ModulesItem[] modules;
|};

type GetPackagesResponse record {|
    PackagesItem[] packages;
    int count;
    int 'limit;
    int offset;
|};
