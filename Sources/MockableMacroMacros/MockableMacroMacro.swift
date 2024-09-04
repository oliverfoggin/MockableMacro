import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct MockableMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MockableEndpointMacro.self,
        MockableClientMacro.self,
    ]
}
