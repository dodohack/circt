//===- HWStructure.td - HW structure ops -------------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This describes the MLIR ops for structure.
//
//===----------------------------------------------------------------------===//

/// Ensure symbol is one of the hw module.* types.  Passes on failed lookup, so
/// more basic symbol validation can provide more useful error messages.
def isModuleSymbol : AttrConstraint<
    CPred<"!::mlir::SymbolTable::lookupNearestSymbolFrom("
            "&$_op, $_self.cast<::mlir::FlatSymbolRefAttr>()) || "
          "hw::isAnyModule(::mlir::SymbolTable::lookupNearestSymbolFrom("
            "&$_op, $_self.cast<::mlir::FlatSymbolRefAttr>()))"
    >, "is module like">;

def HWModuleOp : HWOp<"module",
      [IsolatedFromAbove, FunctionOpInterface, Symbol, RegionKindInterface,
       SingleBlockImplicitTerminator<"OutputOp">, HasParent<"mlir::ModuleOp">,
       OpAsmOpInterface]>{
  let summary = "HW Module";
  let description = [{
    The "hw.module" operation represents a Verilog module, including a given
    name, a list of ports, a list of parameters, and a body that represents the
    connections within the module.
  }];
  let arguments = (ins StrArrayAttr:$argNames, StrArrayAttr:$resultNames,
                       ParamDeclArrayAttr:$parameters,
                       StrAttr:$comment);
  let results = (outs);
  let regions = (region SizedRegion<1>:$body);

  let skipDefaultBuilders = 1;
  let builders = [
    OpBuilder<(ins "StringAttr":$name, "ArrayRef<PortInfo>":$ports,
                   CArg<"ArrayAttr", "{}">:$parameters,
                   CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes,
                   CArg<"StringAttr", "{}">:$comment)>,
    OpBuilder<(ins "StringAttr":$name, "const ModulePortInfo &":$ports,
                   CArg<"ArrayAttr", "{}">:$parameters,
                   CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes,
                   CArg<"StringAttr", "{}">:$comment)>
  ];

  let extraClassDeclaration = [{
    using mlir::detail::FunctionOpInterfaceTrait<HWModuleOp>::front;
    using mlir::detail::FunctionOpInterfaceTrait<HWModuleOp>::getBody;

    // Implement RegionKindInterface.
    static RegionKind getRegionKind(unsigned index) { return RegionKind::Graph;}

    /// Decode information about the input and output ports on this module.
    ModulePortInfo getPorts() {
      return getModulePortInfo(*this);
    }

    /// Return all the module ports merged into one list.
    SmallVector<PortInfo> getAllPorts() {
      return getAllModulePortInfos(*this);
    }

    /// Return the PortInfo for the specified input or inout port.
    PortInfo getInOrInoutPort(size_t i) {
      return getModuleInOrInoutPort(*this, i);
    }

    /// Return the PortInfo for the specified output port.
    PortInfo getOutputPort(size_t i) {
      return getModuleOutputPort(*this, i);
    }

    // TODO(mlir): FunctionLike shouldn't produce a getBody() helper, it is
    // squatting on the name.
    Block *getBodyBlock() { return &body().front(); }

    // Get the module's symbolic name as StringAttr.
    StringAttr getNameAttr() {
      return (*this)->getAttrOfType<StringAttr>(
        ::mlir::SymbolTable::getSymbolAttrName());
    }

    // Get the module's symbolic name.
    StringRef getName() {
      return getNameAttr().getValue();
    }
    void getAsmBlockArgumentNames(mlir::Region &region,
                                  mlir::OpAsmSetValueNameFn setNameFn);

    /// Returns the type of this function.
    FunctionType getType() { 
      return getTypeAttr().getValue().cast<FunctionType>();
    }

    /// Returns the argument types of this function.
    ArrayRef<Type> getArgumentTypes() { return getType().getInputs(); }

    /// Returns the result types of this function.
    ArrayRef<Type> getResultTypes() { return getType().getResults(); }

    /// Verify the type attribute of this function. Returns failure and emits
    /// an error if the attribute is invalid.
    LogicalResult verifyType() {
      auto type = getTypeAttr().getValue();
      if (!type.isa<FunctionType>())
        return emitOpError("requires '" + getTypeAttrName() +
                           "' attribute of function type");
      return success();
    }
  }];

  let hasCustomAssemblyFormat = 1;
  let verifier = "return ::verify$cppClass(*this);";
}

def HWModuleExternOp : HWOp<"module.extern",
      [FunctionOpInterface, Symbol, OpAsmOpInterface,
       HasParent<"mlir::ModuleOp">]> {
  let summary = "HW external Module";
  let description = [{
    The "hw.module.extern" operation represents an external reference to a
    Verilog module, including a given name and a list of ports.

    The 'verilogName' attribute (when present) specifies the spelling of the
    module name in Verilog we can use.  TODO: This is a hack because we don't
    have proper parameterization in the hw.dialect.  We need a way to represent
    parameterized types instead of just concrete types.
  }];
  let arguments = (ins StrArrayAttr:$argNames, StrArrayAttr:$resultNames,
                       ParamDeclArrayAttr:$parameters,
                       OptionalAttr<StrAttr>:$verilogName);
  let results = (outs);
  let regions = (region AnyRegion:$body);

  let skipDefaultBuilders = 1;
  let builders = [
    OpBuilder<(ins "StringAttr":$name, "ArrayRef<PortInfo>":$ports,
                   CArg<"StringRef", "StringRef()">:$verilogName,
                   CArg<"ArrayAttr", "{}">:$parameters,
                   CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes)>,
    OpBuilder<(ins "StringAttr":$name, "const ModulePortInfo &":$ports,
                   CArg<"StringRef", "StringRef()">:$verilogName,
                   CArg<"ArrayAttr", "{}">:$parameters,
                   CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes)>
  ];

  let extraClassDeclaration = [{
    /// Decode information about the input and output ports on this module.
    ModulePortInfo getPorts() {
      return getModulePortInfo(*this);
    }

    /// Return all the module ports merged into one list.
    SmallVector<PortInfo> getAllPorts() {
      return getAllModulePortInfos(*this);
    }

    /// Return the PortInfo for the specified input or inout port.
    PortInfo getInOrInoutPort(size_t i) {
      return getModuleInOrInoutPort(*this, i);
    }

    /// Return the PortInfo for the specified output port.
    PortInfo getOutputPort(size_t i) {
      return getModuleOutputPort(*this, i);
    }

    /// Return the name to use for the Verilog module that we're referencing
    /// here.  This is typically the symbol, but can be overridden with the
    /// verilogName attribute.
    StringRef getVerilogModuleName() {
      return getVerilogModuleNameAttr().getValue();
    }

    /// Return the name to use for the Verilog module that we're referencing
    /// here.  This is typically the symbol, but can be overridden with the
    /// verilogName attribute.
    StringAttr getVerilogModuleNameAttr();

    // Get the module's symbolic name as StringAttr.
    StringAttr getNameAttr() {
      return (*this)->getAttrOfType<StringAttr>(
        ::mlir::SymbolTable::getSymbolAttrName());
    }

    // Get the module's symbolic name.
    StringRef getName() {
      return getNameAttr().getValue();
    }

    void getAsmBlockArgumentNames(mlir::Region &region,
                                  mlir::OpAsmSetValueNameFn setNameFn);

    /// Returns the type of this function.
    FunctionType getType() { 
      return getTypeAttr().getValue().cast<FunctionType>();
    }

    /// Returns the argument types of this function.
    ArrayRef<Type> getArgumentTypes() { return getType().getInputs(); }

    /// Returns the result types of this function.
    ArrayRef<Type> getResultTypes() { return getType().getResults(); }

    /// Verify the type attribute of this function. Returns failure and emits
    /// an error if the attribute is invalid.
    LogicalResult verifyType() {
      auto type = getTypeAttr().getValue();
      if (!type.isa<FunctionType>())
        return emitOpError("requires '" + getTypeAttrName() +
                           "' attribute of function type");
      return success();
    }
  }];

  let hasCustomAssemblyFormat = 1;
  let verifier = "return ::verify$cppClass(*this);";
}

def HWGeneratorSchemaOp : HWOp<"generator.schema",
      [Symbol, HasParent<"mlir::ModuleOp">]> {
  let summary = "HW Generator Schema declaration";
  let description = [{
    The "hw.generator.schema" operation declares a kind of generated module by
    declaring the schema of meta-data required.
    A generated module instance of a schema is independent of the external
    method of producing it.  It is assumed that for well known schema instances,
    multiple external tools might exist which can process it.  Generator nodes
    list attributes required by hw.module.generated instances.

    For example:
    generator.schema @MEMORY, "Simple-Memory", ["ports", "write_latency", "read_latency"]
    module.generated @mymem, @MEMORY(ports)
      -> (ports) {write_latency=1, read_latency=1, ports=["read","write"]}
  }];

  let arguments = (ins SymbolNameAttr:$sym_name, StrAttr:$descriptor,
                       StrArrayAttr:$requiredAttrs);
  let results = (outs);
  let assemblyFormat = "$sym_name `,` $descriptor `,` $requiredAttrs attr-dict";
}

def HWModuleGeneratedOp : HWOp<"module.generated",
      [IsolatedFromAbove, FunctionOpInterface, Symbol, OpAsmOpInterface,
       HasParent<"mlir::ModuleOp">]> {
  let summary = "HW Generated Module";
  let description = [{
    The "hw.module.generated" operation represents a reference to an external
    module that will be produced by some external process.
    This represents the name and list of ports to be generated.

    The 'verilogName' attribute (when present) specifies the spelling of the
    module name in Verilog we can use.  See hw.module for an explanation.
  }];
  let arguments = (ins FlatSymbolRefAttr:$generatorKind,
                       StrArrayAttr:$argNames, StrArrayAttr:$resultNames,
                       ParamDeclArrayAttr:$parameters,
                       OptionalAttr<StrAttr>:$verilogName);
  let results = (outs);
  let regions = (region AnyRegion:$body);

  let skipDefaultBuilders = 1;
  let builders = [
    OpBuilder<(ins "FlatSymbolRefAttr":$genKind, "StringAttr":$name,
                   "ArrayRef<PortInfo>":$ports,
                   CArg<"StringRef", "StringRef()">:$verilogName,
                   CArg<"ArrayAttr", "{}">:$parameters,
                   CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes)>,
    OpBuilder<(ins "FlatSymbolRefAttr":$genKind, "StringAttr":$name,
                   "const ModulePortInfo &":$ports,
                   CArg<"StringRef", "StringRef()">:$verilogName,
                   CArg<"ArrayAttr", "{}">:$parameters,
                   CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes)>
  ];

  let extraClassDeclaration = [{
    /// Decode information about the input and output ports on this module.
    ModulePortInfo getPorts() {
      return getModulePortInfo(*this);
    }

    /// Return all the module ports merged into one list.
    SmallVector<PortInfo> getAllPorts() {
      return getAllModulePortInfos(*this);
    }

    /// Return the name to use for the Verilog module that we're referencing
    /// here.  This is typically the symbol, but can be overridden with the
    /// verilogName attribute.
    StringRef getVerilogModuleName() {
      return getVerilogModuleNameAttr().getValue();
    }

    /// Return the name to use for the Verilog module that we're referencing
    /// here.  This is typically the symbol, but can be overridden with the
    /// verilogName attribute.
    StringAttr getVerilogModuleNameAttr();

    /// Lookup the generator kind for the symbol.  This returns null on
    /// invalid IR.
    Operation *getGeneratorKindOp();

    void getAsmBlockArgumentNames(mlir::Region &region,
                                  mlir::OpAsmSetValueNameFn setNameFn);

    /// Returns the type of this function.
    FunctionType getType() { 
      return getTypeAttr().getValue().cast<FunctionType>();
    }

    /// Returns the argument types of this function.
    ArrayRef<Type> getArgumentTypes() { return getType().getInputs(); }

    /// Returns the result types of this function.
    ArrayRef<Type> getResultTypes() { return getType().getResults(); }

    /// Verify the type attribute of this function. Returns failure and emits
    /// an error if the attribute is invalid.
    LogicalResult verifyType() {
      auto type = getTypeAttr().getValue();
      if (!type.isa<FunctionType>())
        return emitOpError("requires '" + getTypeAttrName() +
                           "' attribute of function type");
      return success();
    }
  }];

  let hasCustomAssemblyFormat = 1;
  let verifier = "return ::verify$cppClass(*this);";
}

def InstanceOp : HWOp<"instance", [
        DeclareOpInterfaceMethods<SymbolUserOpInterface>,
        DeclareOpInterfaceMethods<OpAsmOpInterface, ["getAsmResultNames"]>]> {
  let summary = "Create an instance of a module";
  let description = [{
    This represents an instance of a module. The inputs and results are
    the referenced module's inputs and outputs.  The `argNames` and
    `resultNames` attributes must match the referenced module.
    
    Any parameters in the "old" format (slated to be removed) are stored in the
    `oldParameters` dictionary.
  }];

  let arguments = (ins StrAttr:$instanceName,
                       Confined<FlatSymbolRefAttr, [isModuleSymbol]>:$moduleName,
                       Variadic<AnyType>:$inputs,
                       StrArrayAttr:$argNames, StrArrayAttr:$resultNames,
                       ParamDeclArrayAttr:$parameters,
                       OptionalAttr<SymbolNameAttr>:$inner_sym);
  let results = (outs Variadic<AnyType>);

  let builders = [
    /// Create a instance that refers to a known module.
    OpBuilder<(ins "Operation*":$module, "StringAttr":$name,
                   "ArrayRef<Value>":$inputs,
                   CArg<"ArrayAttr", "{}">:$parameters,
                   CArg<"StringAttr", "{}">:$sym_name)>,
    /// Create a instance that refers to a known module.
    OpBuilder<(ins "Operation*":$module, "StringRef":$name,
                   "ArrayRef<Value>":$inputs,
                   CArg<"ArrayAttr", "{}">:$parameters,
                   CArg<"StringAttr", "{}">:$sym_name), [{
      build($_builder, $_state, module, $_builder.getStringAttr(name), inputs,
            parameters, sym_name);
    }]>,
  ];

  let extraClassDeclaration = [{
    /// Return the name of the specified input port or null if it cannot be
    /// determined.
    StringAttr getArgumentName(size_t i);

    /// Return the name of the specified result or null if it cannot be
    /// determined.
    StringAttr getResultName(size_t i);

    /// Change the name of the specified input port.
    void setArgumentName(size_t i, StringAttr name);

    /// Change the name of the specified output port.
    void setResultName(size_t i, StringAttr name);

    /// Change the names of all the input ports.
    void setArgumentNames(ArrayAttr names) {
      argNamesAttr(names);
    }

    /// Change the names of all the result ports.
    void setResultNames(ArrayAttr names) {
      resultNamesAttr(names);
    }

    /// Lookup the module or extmodule for the symbol.  This returns null on
    /// invalid IR.
    Operation *getReferencedModule(const SymbolCache *cache = nullptr);

    /// Get the instances's name.
    StringAttr getName() {
      return instanceNameAttr();
    }

    /// Set the instance's name.
    void setName(StringAttr name) {
      instanceNameAttr(name);
    }

    LogicalResult verifyCustom();

    //===------------------------------------------------------------------===//
    // SymbolOpInterface Methods
    //===------------------------------------------------------------------===//

    /// An InstanceOp may optionally define a symbol.
    bool isOptionalSymbol() { return true; }
  }];

  let hasCustomAssemblyFormat = 1;
  let verifier = "return this->verifyCustom();";
}

def OutputOp : HWOp<"output", [Terminator, HasParent<"HWModuleOp">,
                                NoSideEffect, ReturnLike]> {
  let summary = "HW termination operation";
  let description = [{
    "hw.output" marks the end of a region in the HW dialect and the values
    to put on the output ports.
  }];

  let arguments = (ins Variadic<AnyType>:$operands);

  let builders = [
    OpBuilder<(ins), "build($_builder, $_state, llvm::None);">
  ];

  let assemblyFormat = "attr-dict ($operands^ `:` qualified(type($operands)))?";

  let verifier = "return ::verifyOutputOp(this);";
}

def GlobalRefOp : HWOp<"globalRef", [IsolatedFromAbove, Symbol]> {
  let summary = "A global reference to uniquely identify each"
                                    "instance of an operation";
  let description = [{
    This works like a symbol reference to an operation by specifying the
    instance path to uniquely identify it globally.
    It can be used to attach per instance metadata (non-local attributes).
    This also lets components of the path point to a common entity.
  }];

  let extraClassDeclaration = [{
    LogicalResult verifyGlobalRef();
  }];

  let arguments = (ins SymbolNameAttr:$sym_name, NameRefArrayAttr:$namepath);

  let assemblyFormat = [{ $sym_name $namepath attr-dict}];

  let verifier = "return this->verifyGlobalRef();";
}

def ProbeOp : HWOp<"probe", []> {
  let summary = "Probe values for use in remote references";
  let description = [{
    Captures values without binding to any accidental name.  This allows
    capturing names holding values of interest while allowing the name to
    resolved only at emission time.
  }];

  let arguments = (ins SymbolNameAttr:$inner_sym,
                       Variadic<AnyType>:$operands);
  let results = (outs);

  let assemblyFormat = "$inner_sym attr-dict (`,` $operands^ `:` qualified(type($operands)))?";

}

