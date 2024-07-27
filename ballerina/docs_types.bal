type Constraint record {|
    boolean isAnonymousUnionType;
    boolean isInclusion;
    boolean isArrayType;
    boolean isNullable;
    boolean isTuple;
    boolean isIntersectionType;
    boolean isParenthesisedType;
    boolean isTypeDesc;
    boolean isRestParam;
    boolean isDeprecated;
    boolean isPublic?;
    boolean generateUserDefinedTypeLink;
    MemberTypesItem[] memberTypes;
    int arrayDimensions;
    string name?;
    string category?;
    string orgName?;
    string moduleName?;
    string version?;
|};

type ElementType record {|
    boolean isAnonymousUnionType;
    boolean isInclusion;
    boolean isArrayType;
    boolean isNullable;
    boolean isTuple;
    boolean isIntersectionType;
    boolean isParenthesisedType;
    boolean isTypeDesc;
    boolean isRestParam;
    boolean isDeprecated;
    boolean isPublic?;
    boolean generateUserDefinedTypeLink;
    MemberTypesItem[] memberTypes;
    int arrayDimensions;
    string name?;
    string category?;
    ElementType elementType?;
    string orgName?;
    string moduleName?;
    string version?;
    string description?;
    Constraint constraint?;
|};

type MemberTypesItem record {|
    boolean isAnonymousUnionType;
    boolean isInclusion;
    boolean isArrayType;
    boolean isNullable;
    boolean isTuple;
    boolean isIntersectionType;
    boolean isParenthesisedType;
    boolean isTypeDesc;
    boolean isRestParam;
    boolean isDeprecated;
    boolean isPublic?;
    boolean generateUserDefinedTypeLink;
    MemberTypesItem[] memberTypes;
    int arrayDimensions;
    string name?;
    string category?;
    string orgName?;
    string moduleName?;
    string version?;
    ElementType elementType?;
    Constraint constraint?;
    json...;
|};

type Type record {|
    boolean isAnonymousUnionType;
    boolean isInclusion;
    boolean isArrayType;
    boolean isNullable;
    boolean isTuple;
    boolean isIntersectionType;
    boolean isParenthesisedType;
    boolean isTypeDesc;
    boolean isRestParam;
    boolean isDeprecated;
    boolean isPublic?;
    boolean generateUserDefinedTypeLink;
    MemberTypesItem[] memberTypes;
    int arrayDimensions;
    string category?;
    string name?;
    string orgName?;
    string moduleName?;
    string version?;
    Constraint constraint?;
    ElementType elementType?;
    boolean isLambda?;
    boolean isIsolated?;
    boolean isExtern?;
    ParamTypesItem[] paramTypes?;
|};
type ParamTypesItem record {|
    string name;
    boolean isAnonymousUnionType;
    boolean isInclusion;
    boolean isArrayType;
    boolean isNullable;
    boolean isTuple;
    boolean isIntersectionType;
    boolean isParenthesisedType;
    boolean isTypeDesc;
    boolean isRestParam;
    boolean isDeprecated;
    boolean isPublic?;
    boolean generateUserDefinedTypeLink;
    anydata[] memberTypes;
    int arrayDimensions;
    ElementType elementType?;
|};

type ReturnType record {|
    boolean isAnonymousUnionType;
    boolean isInclusion;
    boolean isArrayType;
    boolean isNullable;
    boolean isTuple;
    boolean isIntersectionType;
    boolean isParenthesisedType;
    boolean isTypeDesc;
    boolean isRestParam;
    boolean isDeprecated;
    boolean isPublic?;
    boolean generateUserDefinedTypeLink;
    MemberTypesItem[] memberTypes;
    int arrayDimensions;
|};

type FunctionTypesItem record {|
    string accessor?;
    string resourcePath?;
    boolean isLambda;
    boolean isIsolated;
    boolean isExtern;
    string functionKind;
    ParamTypesItem[] paramTypes;
    ReturnType returnType;
    string name;
    string description;
    string category;
    boolean isAnonymousUnionType;
    boolean isInclusion;
    boolean isArrayType;
    boolean isNullable;
    boolean isTuple;
    boolean isIntersectionType;
    boolean isParenthesisedType;
    boolean isTypeDesc;
    boolean isRestParam;
    boolean isDeprecated;
    boolean isPublic?;
    boolean generateUserDefinedTypeLink;
    anydata[] memberTypes;
    int arrayDimensions;
|};

type InclusionType record {|
    string orgName?;
    string moduleName?;
    string version?;
    string name;
    string category?;
    boolean isAnonymousUnionType;
    boolean isInclusion;
    boolean isArrayType;
    boolean isNullable;
    boolean isTuple;
    boolean isIntersectionType;
    boolean isParenthesisedType;
    boolean isTypeDesc;
    boolean isRestParam;
    boolean isDeprecated;
    boolean isPublic?;
    boolean generateUserDefinedTypeLink;
    MemberTypesItem[] memberTypes;
    int arrayDimensions;
    FunctionTypesItem[] functionTypes?;
    string description?;
|};

type FieldsItem record {|
    boolean isDeprecated;
    boolean isReadOnly;
    string defaultValue?;
    Type 'type?;
    string name?;
    string description?;
    anydata[] annotationAttachments?;
    InclusionType inclusionType?;
|};

type RecordsItem record {|
    string description;
    string id?;
    string moduleId?;
    string moduleOrgName?;
    string moduleVersion?;
    anydata[] fields?;
    boolean isClosed?;
    string name?;
    anydata[] descriptionSections?;
    boolean isDeprecated?;
    boolean isReadOnly?;
|};

type ServiceTypesItem record {|
    anydata[] fields?;
    anydata[] methods;
    boolean isDistinct;
    string name?;
    string description;
    anydata[] descriptionSections?;
    boolean isDeprecated;
    boolean isReadOnly;
|};

type ParametersItem record {|
    string defaultValue;
    Type 'type;
    string name;
    string description;
    boolean isDeprecated;
    boolean isReadOnly;
    anydata[] annotationAttachments?;
|};

type ReturnParametersItem record {|
    Type 'type;
    string name;
    string description;
    boolean isDeprecated;
    boolean isReadOnly;
|};

type LifeCycleMethodsItem record {|
    string accessor?;
    string resourcePath;
    boolean isIsolated;
    boolean isRemote?;
    boolean isResource?;
    boolean isExtern;
    ParametersItem[] parameters;
    ReturnParametersItem[] returnParameters;
    anydata[] annotationAttachments;
    string name;
    string description;
    anydata[] descriptionSections?;
    boolean isDeprecated;
    boolean isReadOnly;
|};

type MethodsItem record {|
    string accessor?;
    string resourcePath?;
    boolean isIsolated;
    boolean isRemote?;
    boolean isResource?;
    boolean isExtern;
    ParametersItem[] parameters;
    ReturnParametersItem[] returnParameters;
    anydata[] annotationAttachments?;
    string name;
    string description;
    anydata[] descriptionSections?;
    boolean isDeprecated;
    boolean isReadOnly;
|};

type InitMethod record {|
    string accessor?;
    string resourcePath?;
    boolean isIsolated;
    boolean isRemote?;
    boolean isResource?;
    boolean isExtern;
    ParametersItem[] parameters;
    ReturnParametersItem[] returnParameters;
    anydata[] annotationAttachments;
    string name;
    string description;
    anydata[] descriptionSections?;
    boolean isDeprecated;
    boolean isReadOnly;
|};

type OtherMethodsItem record {|
    string accessor?;
    string resourcePath?;
    boolean isIsolated;
    boolean isRemote?;
    boolean isResource?;
    boolean isExtern;
    ParametersItem[] parameters;
    ReturnParametersItem[] returnParameters;
    anydata[] annotationAttachments;
    string name;
    string description;
    anydata[] descriptionSections?;
    boolean isDeprecated;
    boolean isReadOnly;
|};

type ClassesItem record {|
    string description;
    string id?;
    string moduleId?;
    string moduleOrgName?;
    string moduleVersion?;
    anydata[] fields?;
    anydata[] methods?;
    InitMethod initMethod?;
    anydata[] otherMethods?;
    boolean isIsolated?;
    boolean isService?;
    string name?;
    boolean isDeprecated?;
    boolean isReadOnly?;
|};

type ObjectTypesItem record {|
    string description;
    string id?;
    string moduleId?;
    string moduleOrgName?;
    string moduleVersion?;
    anydata[] fields?;
    anydata[] methods?;
    boolean isDistinct?;
    string name?;
    boolean isDeprecated?;
    boolean isReadOnly?;
|};

type ListenersItem record {|
    string description;
    LifeCycleMethodsItem[] lifeCycleMethods?;
    anydata[] fields?;
    MethodsItem[] methods?;
    InitMethod initMethod?;
    OtherMethodsItem[] otherMethods?;
    boolean isIsolated?;
    boolean isService?;
    string name?;
    anydata[] descriptionSections?;
    boolean isDeprecated?;
    boolean isReadOnly?;
    string id?;
    string moduleId?;
    string moduleOrgName?;
    string moduleVersion?;
|};

type FunctionsItem record {|
    string description;
    string id?;
    string moduleId?;
    string moduleOrgName?;
    string moduleVersion?;
    string accessor?;
    string resourcePath?;
    boolean isIsolated?;
    boolean isRemote?;
    boolean isResource?;
    boolean isExtern?;
    ParametersItem[] parameters?;
    ReturnParametersItem[] returnParameters?;
    anydata[] annotationAttachments?;
    string name?;
    anydata[] descriptionSections?;
    boolean isDeprecated?;
    boolean isReadOnly?;
|};

type DetailType record {|
    string orgName?;
    string moduleName?;
    string version?;
    string name?;
    string category?;
    boolean isAnonymousUnionType;
    boolean isInclusion;
    boolean isArrayType;
    boolean isNullable;
    boolean isTuple;
    boolean isIntersectionType;
    boolean isParenthesisedType;
    boolean isTypeDesc;
    boolean isRestParam;
    boolean isDeprecated;
    boolean isPublic?;
    boolean generateUserDefinedTypeLink;
    anydata[] memberTypes;
    int arrayDimensions;
|};

type ErrorsItem record {|
    string description;
    string id?;
    string moduleId?;
    string moduleOrgName?;
    string moduleVersion?;
    boolean isDistinct?;
    string name?;
    anydata[] descriptionSections?;
    boolean isDeprecated?;
    boolean isReadOnly?;
    DetailType detailType?;
|};

type UnionTypesItem record {|
    string name?;
    string description;
    boolean isAnonymousUnionType;
    boolean isInclusion;
    boolean isArrayType;
    boolean isNullable;
    boolean isTuple;
    boolean isIntersectionType;
    boolean isParenthesisedType;
    boolean isTypeDesc;
    boolean isRestParam;
    boolean isDeprecated;
    boolean isPublic?;
    boolean generateUserDefinedTypeLink;
    MemberTypesItem[] memberTypes;
    int arrayDimensions;
|};

type MembersItem record {|
    string name;
    string description;
    anydata[] descriptionSections?;
    boolean isDeprecated;
    boolean isReadOnly;
|};

type EnumsItem record {|
    string description;
    string id?;
    string moduleId?;
    string moduleOrgName?;
    string moduleVersion?;
    MembersItem[] members?;
    string name?;
    anydata[] descriptionSections?;
    boolean isDeprecated?;
    boolean isReadOnly?;
|};

type VariablesItem record {|
    string defaultValue;
    Type 'type;
    string name;
    string description;
    boolean isDeprecated;
    boolean isReadOnly;
|};

type ModulesItem record {|
    string id;
    string description;
    string orgName?;
    string version;
    boolean isDefaultModule?;
    anydata[] relatedModules?;
    RecordsItem[] records?;
    ClassesItem[] classes?;
    ObjectTypesItem[] objectTypes?;
    ServiceTypesItem[] serviceTypes?;
    ClientItem[] clients?;
    ListenersItem[] listeners?;
    FunctionsItem[] functions?;
    anydata[] constants?;
    anydata[] annotations?;
    ErrorsItem[] errors?;
    anydata[] types?;
    UnionTypesItem[] unionTypes?;
    anydata[] simpleNameReferenceTypes?;
    anydata[] tupleTypes?;
    anydata[] tableTypes?;
    anydata[] mapTypes?;
    anydata[] intersectionTypes?;
    anydata[] typeDescriptorTypes?;
    anydata[] functionTypes?;
    anydata[] streamTypes?;
    anydata[] arrayTypes?;
    anydata[] anyDataTypes?;
    anydata[] anyTypes?;
    anydata[] stringTypes?;
    anydata[] integerTypes?;
    anydata[] decimalTypes?;
    anydata[] xmlTypes?;
    EnumsItem[] enums?;
    VariablesItem[] variables?;
    anydata[] configurables?;
    anydata[] resources?;
    string summary?;
|};

type DocsData record {|
    string releaseVersion;
    anydata[] langLibs;
    ModulesItem[] modules;
|};

type SearchData record {|
    ModulesItem[] modules;
    ClassesItem[] classes;
    FunctionsItem[] functions;
    RecordsItem[] records;
    anydata[] constants;
    ErrorsItem[] errors;
    anydata[] types;
    ClientItem[] clients;
    ListenersItem[] listeners;
    anydata[] annotations;
    ObjectTypesItem[] objectTypes;
    EnumsItem[] enums;
|};

type DocsResponse record {|
    string apiDocsVersion?;
    DocsData docsData;
    SearchData searchData;
|};


type RemoteMethodsItem record {
    string accessor?;
    string resourcePath?;
    boolean isIsolated;
    boolean isRemote?;
    boolean isResource?;
    boolean isExtern;
    ParametersItem[] parameters;
    ReturnParametersItem[] returnParameters;
    anydata[] annotationAttachments?;
    string name;
    string description;
    anydata[] descriptionSections?;
    boolean isDeprecated?;
    boolean isReadOnly;
};


type ClientItem record {
    RemoteMethodsItem[] remoteMethods?;
    anydata[] resourceMethods?;
    FieldsItem[] fields?;
    MethodsItem initMethod?;
    MethodsItem[] methods?;
    OtherMethodsItem[] otherMethods?;
    boolean isIsolated?;
    boolean isService?;
    string name?;
    string description?;
    anydata[] descriptionSections?;
    boolean isDeprecated?;
    boolean isReadOnly?;
    string id?;
};
