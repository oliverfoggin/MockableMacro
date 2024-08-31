import XCTest
import MacroTesting

#if canImport(MockableMacroMacros)
import MockableMacroMacros
#endif

final class MockableMacroTests: XCTestCase {
    func testMockableWithParamsAndReturn() throws {
        #if canImport(MockableMacroMacros)
        assertMacro(["Mockable": MockableMacro.self], record: false) {
            """
            @Mockable public var doThing: (_ value: String, _ other: Bool) -> Int
            """
        } expansion: {
            """
            public var doThing: (_ value: String, _ other: Bool) -> Int

            public mutating func expectDoThing(value expectedValue: String, other expectedOther: Bool, returning returnValue: Int) {
                let fulfill = expectation(description: "expect doThing")
                self.doThing = { [self] value, other in
                    if value == expectedValue,
                    other == expectedOther {
                        fulfill()
                        return returnValue
                    } else {
                        return
                        self.doThing(value, other)
                    }
                }
            }
            """
        }
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMockableWithoutParamsAndReturn() throws {
        #if canImport(MockableMacroMacros)
        assertMacro(["Mockable": MockableMacro.self], record: false) {
            """
            @Mockable public var doThing: () -> Int
            """
        } expansion: {
            """
            public var doThing: () -> Int

            public mutating func expectDoThing(returning returnValue: Int) {
                let fulfill = expectation(description: "expect doThing")
                self.doThing = {
                    fulfill()
                    return returnValue
                }
            }
            """
        }
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMockableWithParamsAndNoReturn() throws {
        #if canImport(MockableMacroMacros)
        assertMacro(["Mockable": MockableMacro.self], record: false) {
            """
            @Mockable public var doThing: (_ value: String, _ other: Bool) -> Void
            """
        } expansion: {
            """
            public var doThing: (_ value: String, _ other: Bool) -> Void

            public mutating func expectDoThing(value expectedValue: String, other expectedOther: Bool) {
                let fulfill = expectation(description: "expect doThing")
                self.doThing = { [self] value, other in
                    if value == expectedValue,
                    other == expectedOther {
                        fulfill()

                    } else {

                        self.doThing(value, other)
                    }
                }
            }
            """
        }
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMockableWithoutParamsAndNoReturn() throws {
        #if canImport(MockableMacroMacros)
        assertMacro(["Mockable": MockableMacro.self], record: false) {
            """
            @Mockable public var doThing: () -> Void
            """
        } expansion: {
            """
            public var doThing: () -> Void

            public mutating func expectDoThing() {
                let fulfill = expectation(description: "expect doThing")
                self.doThing = {
                    fulfill()

                }
            }
            """
        }
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMockableWithUnnamedParamsAndNoReturn() throws {
        #if canImport(MockableMacroMacros)
        assertMacro(["Mockable": MockableMacro.self], record: false) {
            """
            @Mockable public var doThing: (_ named: String, Bool) -> Void
            """
        } expansion: {
            """
            public var doThing: (_ named: String, Bool) -> Void

            public mutating func expectDoThing(named expectedNamed: String, bool0 expectedBool0: Bool) {
                let fulfill = expectation(description: "expect doThing")
                self.doThing = { [self] named, bool0 in
                    if named == expectedNamed,
                    bool0 == expectedBool0 {
                        fulfill()

                    } else {

                        self.doThing(named, bool0)
                    }
                }
            }
            """
        }
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
