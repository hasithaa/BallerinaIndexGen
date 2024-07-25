/*
 *  Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
 *
 *  WSO2 LLC. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */
package io.ballerina.lib.compiler.api;

import io.ballerina.compiler.api.SemanticModel;
import io.ballerina.compiler.api.symbols.Documentation;
import io.ballerina.compiler.api.symbols.FunctionSymbol;
import io.ballerina.compiler.api.symbols.FunctionTypeSymbol;
import io.ballerina.compiler.api.symbols.ParameterKind;
import io.ballerina.compiler.api.symbols.ParameterSymbol;
import io.ballerina.compiler.api.symbols.Qualifier;
import io.ballerina.compiler.api.symbols.Symbol;
import io.ballerina.compiler.api.symbols.SymbolKind;
import io.ballerina.projects.ModuleId;
import io.ballerina.projects.Package;
import io.ballerina.projects.PackageCompilation;
import io.ballerina.projects.Project;
import io.ballerina.projects.ProjectEnvironmentBuilder;
import io.ballerina.projects.directory.ProjectLoader;
import io.ballerina.projects.repos.FileSystemCache;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.utils.JsonUtils;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Optional;

public class Compiler {

    private static void handleFunctionParam(ParameterSymbol parameterSymbol, String defaultParamName,
                                            Documentation documentation, BMap<BString, Object> properties) {
        final BMap<BString, Object> property = ValueCreator.createMapValue();
        boolean optional = !(parameterSymbol.paramKind() == ParameterKind.REQUIRED);
        final BMap<BString, Object> metadata = ValueCreator.createMapValue();

        final String actualParamName = parameterSymbol.getName().orElse(null);
        final BString paramName = StringUtils.fromString(Optional.ofNullable(actualParamName).orElse(defaultParamName));
        metadata.put(StringUtils.fromString("label"), paramName);
        final String description = documentation != null ? documentation.parameterMap().getOrDefault(actualParamName,
                                                                                                     "") : "";
        metadata.put(StringUtils.fromString("description"), StringUtils.fromString(description));
        property.put(StringUtils.fromString("metadata"), metadata);
        property.put(StringUtils.fromString("valueType"), StringUtils.fromString("expression"));
        property.put(StringUtils.fromString("optional"), optional);
        property.put(StringUtils.fromString("editable"), true);
        property.put(StringUtils.fromString("value"), null);
        property.put(StringUtils.fromString("valueTypeConstraints"),
                     StringUtils.fromString(parameterSymbol.typeDescriptor().signature()));

        properties.put(paramName, property);
    }

    public static BMap<BString, Object> buildBala(BString path) {
        final String ballerinaHomeKey = "ballerina.home";
        Path balaPath = Paths.get(path.toString());
        Path jBalToolsPath = Paths.get("/Library/Ballerina/distributions/ballerina-2201.9.0/");
        Path repo = jBalToolsPath.resolve("repo");
        System.setProperty(ballerinaHomeKey, repo.getParent().toString());
        ProjectEnvironmentBuilder defaultBuilder = ProjectEnvironmentBuilder.getDefaultBuilder();
        defaultBuilder.addCompilationCacheFactory(new FileSystemCache.FileSystemCacheFactory(repo.resolve("cache")));
        Project balaProject = ProjectLoader.loadProject(balaPath, defaultBuilder);
        Package currentPackage = balaProject.currentPackage();
        final PackageCompilation compilation = currentPackage.getCompilation();
        final MapType mapType = TypeCreator.createMapType(PredefinedTypes.TYPE_JSON);
        final BMap<BString, Object> functions = ValueCreator.createMapValue(mapType);

        for (ModuleId moduleId : currentPackage.moduleIds()) {
            SemanticModel semanticModel = compilation.getSemanticModel(moduleId);
            for (Symbol symbol : semanticModel.moduleSymbols()) {
                if (symbol.kind() == SymbolKind.FUNCTION && ((FunctionSymbol) symbol).qualifiers().contains(
                        Qualifier.PUBLIC)) {

                    final FunctionSymbol funcSymbol = (FunctionSymbol) symbol;
                    funcSymbol.getName().ifPresent(functionName -> {
                        final BMap<BString, Object> function = ValueCreator.createMapValue(mapType);

                        final FunctionTypeSymbol functionTypeSymbol = funcSymbol.typeDescriptor();
                        final BMap<BString, Object> properties = ValueCreator.createMapValue(mapType);

                        final Documentation documentation = funcSymbol.documentation().orElse(null);
                        functionTypeSymbol.params().ifPresent(params -> {
                            int i = 0;
                            for (ParameterSymbol parameterSymbol : params) {
                                handleFunctionParam(parameterSymbol, "param" + i++, documentation, properties);
                            }
                        });

                        functionTypeSymbol.restParam().ifPresent(parameterSymbol -> {
                            handleFunctionParam(parameterSymbol, "restParam", documentation, properties);
                        });

                        final BMap<BString, Object> metadata = ValueCreator.createMapValue(mapType);
                        metadata.put(StringUtils.fromString("label"), StringUtils.fromString(functionName));
                        metadata.put(StringUtils.fromString("description"), StringUtils.fromString(
                                documentation != null ? documentation.description().orElse("") : ""));

                        final BMap<BString, Object> codeData = ValueCreator.createMapValue(mapType);
                        codeData.put(StringUtils.fromString("node"), StringUtils.fromString("FUNCTION_CALL"));
                        codeData.put(StringUtils.fromString("module"), StringUtils.fromString(currentPackage.module(
                                moduleId).moduleName().toString()));
                        codeData.put(StringUtils.fromString("org"),
                                     StringUtils.fromString(currentPackage.packageOrg().value()));
                        codeData.put(StringUtils.fromString("symbol"), StringUtils.fromString(functionName));

                        function.put(StringUtils.fromString("codeData"), codeData);
                        function.put(StringUtils.fromString("metadata"), metadata);
                        function.put(StringUtils.fromString("properties"), properties);
                        functions.put(StringUtils.fromString(functionName), function);
                    });
                }
            }
        }
        JsonUtils.convertJSON(functions, TypeUtils.fromString("json"));
        return functions;
    }
}

