import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MockableClientMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        
        guard let varDecl = member.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              isValidBindingType(binding: binding)
        else {
            return []
        }
        
        guard varDecl.bindingSpecifier.text == "var" else {
            return []
        }
        
        if let accessorBlock = binding.accessorBlock,
            accessorBlock.accessors.is(CodeBlockItemListSyntax.self) {
            return []
        }
        
        return ["@MockableEndpoint"]
    }
    
    private static func isValidBindingType(binding: PatternBindingSyntax) -> Bool {
        guard let typeAnnotation = binding.typeAnnotation else {
            return false
        }
        
        if let attributedType = typeAnnotation.type.as(AttributedTypeSyntax.self) {
            return attributedType.baseType.is(FunctionTypeSyntax.self)
        }
        
        return typeAnnotation.type.is(FunctionTypeSyntax.self)
    }
}
