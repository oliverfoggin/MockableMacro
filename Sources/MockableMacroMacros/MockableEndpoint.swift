import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

enum FooBarError: Error {
  case onlyApplicableToFunctionType
  case onlyApplicaableToVariable
}

public struct MockableEndpointMacro: PeerMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.DeclSyntax] {
    guard let varDecl = declaration.as(VariableDeclSyntax.self),
          let binding = varDecl.bindings.first,
          let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
          let function = functionFromBinding(binding: binding)
    else {
      throw FooBarError.onlyApplicableToFunctionType
    }

    guard varDecl.bindingSpecifier.text == "var" else {
      throw FooBarError.onlyApplicaableToVariable
    }

    let params = parameters(of: function)
    let returnParam = [
      function.returnClause.isVoid ? nil : ParameterDefinition(
        firstName: "returning",
        secondName: "returnValue",
        type: function.returnClause.type
      )
    ]
    .compactMap { $0 }

    let isAsync: Bool = function.effectSpecifiers?.asyncSpecifier != nil
    let isThrowing: Bool = function.effectSpecifiers?.throwsSpecifier != nil

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
      functionBody =
        """
        {
          let fulfill = expectation(description: "expect \(identifier)")
          self.\(identifier) = { [self] \(params.map(\.inputParamName).joined(separator: ", ")) in
            if \(params.map { "isTheSameOrNotEquatable(\($0.inputParamName), \($0.secondName))" }.joined(separator: ",\n")) {
              fulfill()
              \(function.returnClause.isVoid ? "" : "return returnValue")
            } else {
              \(function.returnClause.isVoid ? "" : "return") \(isThrowing ? "try" : "") \(isAsync ? "await" : "") self.\(identifier)(\(params.map(\.inputParamName).joined(separator: ", ")))
            }
          }
        }
        """
    }

    let throwingParam = [
      ParameterDefinition(
        firstName: "throwing",
        secondName: "error",
        type: .init(stringLiteral: "any Error")
      )
    ]
    .compactMap { $0 }

    let throwingFunctionParams = "(\((params + throwingParam).map(\.paramString).joined(separator: ", ")))"

    let throwingFunctionSignature: String
    if isThrowing {
      throwingFunctionSignature = "public mutating func \(functionName)\(throwingFunctionParams)"
    } else {
      throwingFunctionSignature = ""
    }

    let throwingFunctionBody: String
    if isThrowing {
      if function.parameters.isEmpty {
        throwingFunctionBody =
        """
        {
          let fulfill = expectation(description: "expect \(identifier)")
          self.\(identifier) = {
            fulfill()
            throw error
          }
        }
        """
      } else {
        throwingFunctionBody =
        """
        {
          let fulfill = expectation(description: "expect \(identifier)")
          self.\(identifier) = { [self] \(params.map(\.inputParamName).joined(separator: ", ")) in
            if \(params.map { "isTheSameOrNotEquatable(\($0.inputParamName), \($0.secondName))" }.joined(separator: ",\n")) {
              fulfill()
              throw error
            } else {
              \(function.returnClause.isVoid ? "" : "return") \(isThrowing ? "try" : "") \(isAsync ? "await" : "") self.\(identifier)(\(params.map(\.inputParamName).joined(separator: ", ")))
            }
          }
        }
        """
      }
    } else {
      throwingFunctionBody = ""
    }

    return [DeclSyntax(
            """
            \(raw: functionSignature)
            \(raw: functionBody)
            
            \(raw: throwingFunctionSignature)
            \(raw: throwingFunctionBody)
            """
    )]
  }

  private static func functionFromBinding(binding: PatternBindingSyntax) -> FunctionTypeSyntax? {
    guard let typeAnnotation = binding.typeAnnotation else {
      return nil
    }

    if let attributedType = typeAnnotation.type.as(AttributedTypeSyntax.self) {
      return attributedType.baseType.as(FunctionTypeSyntax.self)
    }

    return typeAnnotation.type.as(FunctionTypeSyntax.self)
  }

  private static func parameters(of functionType: FunctionTypeSyntax) -> [ParameterDefinition] {
    functionType.parameters
      .filter {
        !$0.type.is(FunctionTypeSyntax.self)
      }
      .enumerated()
      .map { (index, element) in
          .init(
            firstName: element.secondName?.text ?? "_",
            secondName: "p\(index)",
            type: element.type
          )
      }
  }

  private static func typeNameFromElementType(_ element: TupleTypeElementSyntax) -> String {
    if let type = element.type.as(IdentifierTypeSyntax.self) {
      return type.name.text.lowercasedFirst()
    }

    if let type = element.type.as(OptionalTypeSyntax.self),
       let wrappedType = type.wrappedType.as(IdentifierTypeSyntax.self) {
      return wrappedType.name.text.lowercasedFirst()
    }

    return UUID().uuidString
  }
}

struct ParameterDefinition {
  let firstName: String
  let secondName: String
  let type: TypeSyntax

  var paramString: String {
    "\(firstName) \(secondName): \(type)"
  }

  var inputParamName: String {
    "i\(secondName)"
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
