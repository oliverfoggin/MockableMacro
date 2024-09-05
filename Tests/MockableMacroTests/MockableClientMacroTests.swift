import XCTest
import MacroTesting

#if canImport(MockableMacroMacros)
import MockableMacroMacros
#endif

final class MockableClientMacroTests: XCTestCase {
    func testMockable() throws {
        #if canImport(MockableMacroMacros)
        assertMacro(["Mockable": MockableClientMacro.self], record: false) {
            """
            @Mockable
            struct Foo {
                var bad: (Int) -> String { { _ in "" } }
                let good: (Int) -> String
            }
            """
        } expansion: {
            """
            struct Foo {
                var bad: (Int) -> String { { _ in "" } }
                let good: (Int) -> String
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
