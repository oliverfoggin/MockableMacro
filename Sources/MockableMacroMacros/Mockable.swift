import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum FooBarError: Error {
    case onlyApplicableToFunctionType
    case onlyApplicaableToVariable
}

public struct MockableMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
              let function = binding.typeAnnotation?.type.as(FunctionTypeSyntax.self)
        else {
            throw FooBarError.onlyApplicableToFunctionType
        }
        
        guard varDecl.bindingSpecifier.text == "var" else {
            throw FooBarError.onlyApplicaableToVariable
        }
        
        var modifiers = varDecl.modifiers
        modifiers.append(.init(name: .keyword(.mutating)))
        
        let params = parameters(of: function)
        let returnParam = [
            function.returnClause.isVoid ? nil : ParameterDefinition(
                firstName: "returning",
                secondName: "returnValue",
                type: function.returnClause.type
            )
        ]
        .compactMap { $0 }
        
        let functionName = "expect\(identifier.uppercasedFirst())"
        let functionParams = "(\((params + returnParam).map(\.paramString).joined(separator: ", ")))"
        
        let functionSignature = "public mutating func \(functionName)\(functionParams)"
        
        let functionBody: String
        
        if function.parameters.isEmpty {
            functionBody =
                """
                {
                    let fulfill = expectation(description: "expect \(identifier)")
                    self.\(identifier) = {
                        fulfill()
                        \(function.returnClause.isVoid ? "" : "return returnValue")
                    }
                }
                """
        } else {
            // check each
            functionBody =
                """
                {
                    let fulfill = expectation(description: "expect \(identifier)")
                    self.\(identifier) = { [self] \(params.map(\.firstName).joined(separator: ", ")) in
                        if \(params.map { "isTheSameOrNotEquatable(\($0.firstName), \($0.secondName))" }.joined(separator: ",\n")) {
                            fulfill()
                            \(function.returnClause.isVoid ? "" : "return returnValue")
                        } else {
                            \(function.returnClause.isVoid ? "" : "return")
                            self.\(identifier)(\(params.map(\.firstName).joined(separator: ", ")))
                        }
                    }
                }
                """
        }
        
        return [DeclSyntax(
            """
            \(raw: functionSignature)
            \(raw: functionBody)
            """
        )]
    }
    
    private static func parameters(of functionType: FunctionTypeSyntax) -> [ParameterDefinition] {
        var count = 0
        
        return functionType.parameters
            .filter {
                !$0.type.is(FunctionTypeSyntax.self)
            }
            .map { element in
                let name: String
                
                if let secondName = element.secondName?.text {
                    name = secondName
                } else {
                    name = element.type.as(IdentifierTypeSyntax.self)!.name.text.lowercasedFirst() + "\(count)"
                    
                    count += 1
                }
                
                return .init(
                    firstName: name,
                    secondName: "expected\(name.uppercasedFirst())",
                    type: element.type
                )
            }
    }
}

struct ParameterDefinition {
    let firstName: String
    let secondName: String
    let type: TypeSyntax
    
    var paramString: String {
        "\(firstName) \(secondName): \(type)"
    }
}

extension ReturnClauseSyntax {
    var isVoid: Bool {
        type.as(IdentifierTypeSyntax.self)?.name.text == "Void"
    }
}

extension String {
    func uppercasedFirst() -> String {
        prefix(1).uppercased() + dropFirst()
    }
    func lowercasedFirst() -> String {
        prefix(1).lowercased() + dropFirst()
    }
}
