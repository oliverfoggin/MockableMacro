import XCTest
import MacroTesting

#if canImport(MockableMacroMacros)
import MockableMacroMacros
#endif

final class MockableMacroTests: XCTestCase {
    func testMockableWithParamsAndReturn() throws {
        #if canImport(MockableMacroMacros)
        assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: true) {
            """
            @MockableEndpoint public var doThing: @Sendable (Any?, _ other: Bool) -> Int
            """
        } expansion: {
            """
            public var doThing: @Sendable (Any?, _ other: Bool) -> Int

            public mutating func expectDoThing(_ p0: Any?, other p1: Bool, returning returnValue: Int)
            {
                let fulfill = expectation(description: "expect doThing")
                self.doThing = { [self] ip0, ip1 in
                    if isTheSameOrNotEquatable(ip0, p0),
                    isTheSameOrNotEquatable(ip1, p1) {
                        fulfill()
                        return returnValue
                    } else {
                        return
                        self.doThing(ip0, ip1)
                    }
                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMockableWithoutParamsAndReturn() throws {
        #if canImport(MockableMacroMacros)
        assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: true) {
            """
            @MockableEndpoint public var doThing: @Sendable () -> Int
            """
        } expansion: {
            """
            public var doThing: @Sendable () -> Int

            public mutating func expectDoThing(returning returnValue: Int)
            {
                let fulfill = expectation(description: "expect doThing")
                self.doThing = {
                    fulfill()
                    return returnValue
                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMockableWithParamsAndNoReturn() throws {
        #if canImport(MockableMacroMacros)
        assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: true) {
            """
            @MockableEndpoint public var doThing: @Sendable (_ value: String, _ other: Bool) -> Void
            """
        } expansion: {
            """
            public var doThing: @Sendable (_ value: String, _ other: Bool) -> Void

            public mutating func expectDoThing(value p0: String, other p1: Bool)
            {
                let fulfill = expectation(description: "expect doThing")
                self.doThing = { [self] ip0, ip1 in
                    if isTheSameOrNotEquatable(ip0, p0),
                    isTheSameOrNotEquatable(ip1, p1) {
                        fulfill()

                    } else {

                        self.doThing(ip0, ip1)
                    }
                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMockableWithoutParamsAndNoReturn() throws {
        #if canImport(MockableMacroMacros)
        assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: true) {
            """
            @MockableEndpoint public var doThing: @Sendable () -> Void
            """
        } expansion: {
            """
            public var doThing: @Sendable () -> Void

            public mutating func expectDoThing()
            {
                let fulfill = expectation(description: "expect doThing")
                self.doThing = {
                    fulfill()

                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMockableWithUnnamedParamsAndNoReturn() throws {
        #if canImport(MockableMacroMacros)
        assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: true) {
            """
            @MockableEndpoint public var doThing: @Sendable (_ named: String, Bool) -> Void
            """
        } expansion: {
            """
            public var doThing: @Sendable (_ named: String, Bool) -> Void

            public mutating func expectDoThing(named p0: String, _ p1: Bool)
            {
                let fulfill = expectation(description: "expect doThing")
                self.doThing = { [self] ip0, ip1 in
                    if isTheSameOrNotEquatable(ip0, p0),
                    isTheSameOrNotEquatable(ip1, p1) {
                        fulfill()

                    } else {

                        self.doThing(ip0, ip1)
                    }
                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
