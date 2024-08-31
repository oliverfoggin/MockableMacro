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
              let type = binding.typeAnnotation?.type.as(FunctionTypeSyntax.self)
        else {
            throw FooBarError.onlyApplicableToFunctionType
        }
        
        guard varDecl.bindingSpecifier.text == "var" else {
            throw FooBarError.onlyApplicaableToVariable
        }
        
        var modifiers = varDecl.modifiers
        modifiers.append(.init(name: .keyword(.mutating)))
        
        var count = 0
        
        let params: [ParameterDefinition] = type.parameters
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
//            .filter {
//                $0.type.isProtocol()
//            }
        
        var mutatingFunc: FunctionDeclSyntax = FunctionDeclSyntax(
            leadingTrivia: [],
            attributes: [],
            modifiers: modifiers,
            name: .identifier("expect\(identifier.uppercasedFirst())"),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: FunctionParameterListSyntax {
                        params.map {
                            .init(
                                firstName: "\(raw: $0.firstName)",
                                secondName: "\(raw: $0.secondName)",
                                type: $0.type
                            )
                        }
                        
                        if !type.returnClause.isVoid {
                            FunctionParameterSyntax(
                                firstName: "returning",
                                secondName: "returnValue",
                                type: type.returnClause.type
                            )
                        }
                    }
                )
            )
        )
        
        if type.parameters.isEmpty {
            mutatingFunc.body = CodeBlockSyntax(
                stringLiteral:
                """
                {
                    let fulfill = expectation(description: "expect \(identifier)")
                    self.\(identifier) = {
                        fulfill()
                        \(type.returnClause.isVoid ? "" : "return returnValue")
                    }
                }
                """
            )
        } else {
            // check each
            mutatingFunc.body = CodeBlockSyntax(
                stringLiteral:
                """
                {
                    let fulfill = expectation(description: "expect \(identifier)")
                    self.\(identifier) = { [self] \(params.map(\.firstName).joined(separator: ", ")) in
                        if \(params.map { "\($0.firstName) == \($0.secondName)" }.joined(separator: ",\n")) {
                            fulfill()
                            \(type.returnClause.isVoid ? "" : "return returnValue")
                        } else {
                            \(type.returnClause.isVoid ? "" : "return")
                            self.\(identifier)(\(params.map(\.firstName).joined(separator: ", ")))
                        }
                    }
                }
                """
            )
        }
        
        return [
            DeclSyntax(mutatingFunc)
        ]
    }
}

struct ParameterDefinition {
    let firstName: String
    let secondName: String
    let type: TypeSyntax
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
