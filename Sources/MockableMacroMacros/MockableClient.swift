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
              binding.typeAnnotation?.type.as(FunctionTypeSyntax.self) != nil
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
}
