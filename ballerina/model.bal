type GetAvailableNodesResponse record {|
    Category[] categories;
|};

type GetNodeTemplateResponse record {|
    FlowNode node;
|};

type GetSourceCodeResponse record {|
    TextEdit[] textEdits;
|};

type GetFlowModelResponse record {|
    Diagram diagram;
|};

type Diagram record {|
    string filename;
    FlowNode[] nodes;
    Connections[] connections;
|};

type Connections record {|
    CodeData codedata;
    string label;
    Scope scope;
|};

type TextEdit record {|
    string newText;
    record {|
        Position 'start;
        Position end;
    |} range;
|};

type Position record {|
    int line;
    int character;
|};

type LinePosition record {|
    int line;
    int offset;
|};

type LineRange record {|
    string fileName;
    LinePosition startLine;
    LinePosition endLine;
|};

type Metadata record {|
    string label;
    string description;
    string[] keywords?;
|};

type FlowNode record {
    IndexMetadata metadata;
    CodeData codedata;
    map<Property> properties;
    Branch[] branches;
};

type Property record {
    IndexMetadata metadata;
    string valueType;
    string value;
    boolean optional;
    boolean editable;
};

type CodeData record {
    string node;
    string org?;
    string module?;
    string 'object?;
    string symbol?;
    LineRange lineRange?;
};

type Branch record {
    string label;
    BranchKind kind;
    CodeData codedata;
    Repeatable repeatable;
    map<Property> properties;
    FlowNode[] children;
};

type Category record {|
    IndexMetadata metadata;
    Category[]|AvailableNode[] items?;
|};

type AvailableNode record {|
    IndexMetadata metadata;
    CodeData codedata;
    boolean enabled;
|};

type BranchKind "block"|"worker";

type Repeatable "1+"|"0..1"|"1"|"0+";

type Scope "module"|"local"|"object";