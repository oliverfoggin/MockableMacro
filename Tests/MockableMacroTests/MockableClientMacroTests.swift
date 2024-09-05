import XCTest
import MacroTesting

#if canImport(MockableMacroMacros)
import MockableMacroMacros
#endif

final class MockableClientMacroTests: XCTestCase {
    func testMockable() throws {
        #if canImport(MockableMacroMacros)
        assertMacro(["Mockable": MockableClientMacro.self], record: true) {
            """
            @Mockable
            struct Foo {
                public var int: @Sendable (_ forKey: Key) -> Int = { _ in 0 }
            }
            """
        } expansion: {
            """
            struct Foo {
                @MockableEndpoint
                public var int: @Sendable (_ forKey: Key) -> Int = { _ in 0 }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
