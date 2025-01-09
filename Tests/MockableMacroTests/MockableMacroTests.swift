import XCTest
import MacroTesting

#if canImport(MockableMacroMacros)
import MockableMacroMacros
#endif

final class MockableMacroTests: XCTestCase {
  func testMockableWithParamsAndReturn() throws {
#if canImport(MockableMacroMacros)
    assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: false) {
            """
            @MockableEndpoint public var doThing: @Sendable (Any?, _ other: Bool) -> Int
            """
    } expansion: {
      """
      public var doThing: @Sendable (Any?, _ other: Bool) -> Int
      
      public  mutating func expectDoThing(_ p0: Any?, other p1: Bool, returning returnValue: Int)
      {
        let fulfill = expectation(description: "expect doThing")
        self.doThing = { [self] ip0, ip1 in
          if isTheSameOrNotEquatable(ip0, p0),
          isTheSameOrNotEquatable(ip1, p1) {
            fulfill()
            return returnValue
          } else {
            return   self.doThing(ip0, ip1)
          }
        }
      }
      """
    }
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
  func testMockableWithParamsAndReturnNonPublic() throws {
#if canImport(MockableMacroMacros)
    assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: false) {
            """
            @MockableEndpoint var doThing: @Sendable (Any?, _ other: Bool) -> Int
            """
    } expansion: {
      """
      var doThing: @Sendable (Any?, _ other: Bool) -> Int

      mutating func expectDoThing(_ p0: Any?, other p1: Bool, returning returnValue: Int)
      {
        let fulfill = expectation(description: "expect doThing")
        self.doThing = { [self] ip0, ip1 in
          if isTheSameOrNotEquatable(ip0, p0),
          isTheSameOrNotEquatable(ip1, p1) {
            fulfill()
            return returnValue
          } else {
            return   self.doThing(ip0, ip1)
          }
        }
      }
      """
    }
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }

  func testMockableWithParamsAndAsyncReturn() throws {
#if canImport(MockableMacroMacros)
    assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: false) {
            """
            @MockableEndpoint public var doThing: @Sendable (Any?, _ other: Bool) async -> Int
            """
    } expansion: {
      """
      public var doThing: @Sendable (Any?, _ other: Bool) async -> Int

      public  mutating func expectDoThing(_ p0: Any?, other p1: Bool, returning returnValue: Int)
      {
        let fulfill = expectation(description: "expect doThing")
        self.doThing = { [self] ip0, ip1 in
          if isTheSameOrNotEquatable(ip0, p0),
          isTheSameOrNotEquatable(ip1, p1) {
            fulfill()
            return returnValue
          } else {
            return  await self.doThing(ip0, ip1)
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
    assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: false) {
            """
            @MockableEndpoint public var doThing: @Sendable () -> Int
            """
    } expansion: {
      """
      public var doThing: @Sendable () -> Int

      public  mutating func expectDoThing(returning returnValue: Int)
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
    assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: false) {
            """
            @MockableEndpoint public var doThing: @Sendable (_ value: String, _ other: Bool) -> Void
            """
    } expansion: {
      """
      public var doThing: @Sendable (_ value: String, _ other: Bool) -> Void

      public  mutating func expectDoThing(value p0: String, other p1: Bool)
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
    assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: false) {
            """
            @MockableEndpoint public var doThing: @Sendable () -> Void
            """
    } expansion: {
      """
      public var doThing: @Sendable () -> Void

      public  mutating func expectDoThing()
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
    assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: false) {
            """
            @MockableEndpoint public var doThing: @Sendable (_ named: String, Bool) -> Void
            """
    } expansion: {
      """
      public var doThing: @Sendable (_ named: String, Bool) -> Void

      public  mutating func expectDoThing(named p0: String, _ p1: Bool)
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

  func testMockableAsyncWithReturn() throws {
#if canImport(MockableMacroMacros)
    assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: false) {
      """
      @MockableEndpoint public var doThing: (_ named: String, Bool) async -> String
      """
    } expansion: {
      """
      public var doThing: (_ named: String, Bool) async -> String

      public  mutating func expectDoThing(named p0: String, _ p1: Bool, returning returnValue: String)
      {
        let fulfill = expectation(description: "expect doThing")
        self.doThing = { [self] ip0, ip1 in
          if isTheSameOrNotEquatable(ip0, p0),
          isTheSameOrNotEquatable(ip1, p1) {
            fulfill()
            return returnValue
          } else {
            return  await self.doThing(ip0, ip1)
          }
        }
      }
      """
    }
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }

  func testMockableAsyncWithVoid() throws {
#if canImport(MockableMacroMacros)
    assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: false) {
      """
      @MockableEndpoint public var doThing: (_ named: String, Bool) async -> Void
      """
    } expansion: {
      """
      public var doThing: (_ named: String, Bool) async -> Void

      public  mutating func expectDoThing(named p0: String, _ p1: Bool)
      {
        let fulfill = expectation(description: "expect doThing")
        self.doThing = { [self] ip0, ip1 in
          if isTheSameOrNotEquatable(ip0, p0),
          isTheSameOrNotEquatable(ip1, p1) {
            fulfill()

          } else {
              await self.doThing(ip0, ip1)
          }
        }
      }
      """
    }
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }

  func testMockableThrowingWithVoid() throws {
#if canImport(MockableMacroMacros)
    assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: false) {
      """
      @MockableEndpoint public var doThing: (_ named: String, Bool) throws -> Void
      """
    } expansion: {
      """
      public var doThing: (_ named: String, Bool) throws -> Void

      public  mutating func expectDoThing(named p0: String, _ p1: Bool)
      {
        let fulfill = expectation(description: "expect doThing")
        self.doThing = { [self] ip0, ip1 in
          if isTheSameOrNotEquatable(ip0, p0),
          isTheSameOrNotEquatable(ip1, p1) {
            fulfill()

          } else {
             try  self.doThing(ip0, ip1)
          }
        }
      }

      public  mutating func expectDoThing(named p0: String, _ p1: Bool, throwing error: any Error)
      {
        let fulfill = expectation(description: "expect doThing")
        self.doThing = { [self] ip0, ip1 in
          if isTheSameOrNotEquatable(ip0, p0),
      isTheSameOrNotEquatable(ip1, p1) {
            fulfill()
            throw error
          } else {
             try  self.doThing(ip0, ip1)
          }
        }
      }
      """
    }
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }

  func testMockableThrowingWithReturn() throws {
#if canImport(MockableMacroMacros)
    assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: false) {
      """
      @MockableEndpoint public var doThing: (_ named: String, Bool) throws -> String
      """
    } expansion: {
      """
      public var doThing: (_ named: String, Bool) throws -> String

      public  mutating func expectDoThing(named p0: String, _ p1: Bool, returning returnValue: String)
      {
        let fulfill = expectation(description: "expect doThing")
        self.doThing = { [self] ip0, ip1 in
          if isTheSameOrNotEquatable(ip0, p0),
          isTheSameOrNotEquatable(ip1, p1) {
            fulfill()
            return returnValue
          } else {
            return try  self.doThing(ip0, ip1)
          }
        }
      }

      public  mutating func expectDoThing(named p0: String, _ p1: Bool, throwing error: any Error)
      {
        let fulfill = expectation(description: "expect doThing")
        self.doThing = { [self] ip0, ip1 in
          if isTheSameOrNotEquatable(ip0, p0),
      isTheSameOrNotEquatable(ip1, p1) {
            fulfill()
            throw error
          } else {
            return try  self.doThing(ip0, ip1)
          }
        }
      }
      """
    }
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }

  func testMockableAsyncThrowingWithReturn() throws {
#if canImport(MockableMacroMacros)
    assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: false) {
      """
      @MockableEndpoint public var doThing: (_ named: String, Bool) async throws -> String
      """
    } expansion: {
      """
      public var doThing: (_ named: String, Bool) async throws -> String

      public  mutating func expectDoThing(named p0: String, _ p1: Bool, returning returnValue: String)
      {
        let fulfill = expectation(description: "expect doThing")
        self.doThing = { [self] ip0, ip1 in
          if isTheSameOrNotEquatable(ip0, p0),
          isTheSameOrNotEquatable(ip1, p1) {
            fulfill()
            return returnValue
          } else {
            return try await self.doThing(ip0, ip1)
          }
        }
      }

      public  mutating func expectDoThing(named p0: String, _ p1: Bool, throwing error: any Error)
      {
        let fulfill = expectation(description: "expect doThing")
        self.doThing = { [self] ip0, ip1 in
          if isTheSameOrNotEquatable(ip0, p0),
      isTheSameOrNotEquatable(ip1, p1) {
            fulfill()
            throw error
          } else {
            return try await self.doThing(ip0, ip1)
          }
        }
      }
      """
    }
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }

  func testMockableAsyncThrowingWithVoid() throws {
#if canImport(MockableMacroMacros)
    assertMacro(["MockableEndpoint": MockableEndpointMacro.self], record: false) {
      """
      @MockableEndpoint public var doThing: (_ named: String, Bool) async throws -> Void
      """
    } expansion: {
      """
      public var doThing: (_ named: String, Bool) async throws -> Void

      public  mutating func expectDoThing(named p0: String, _ p1: Bool)
      {
        let fulfill = expectation(description: "expect doThing")
        self.doThing = { [self] ip0, ip1 in
          if isTheSameOrNotEquatable(ip0, p0),
          isTheSameOrNotEquatable(ip1, p1) {
            fulfill()

          } else {
             try await self.doThing(ip0, ip1)
          }
        }
      }

      public  mutating func expectDoThing(named p0: String, _ p1: Bool, throwing error: any Error)
      {
        let fulfill = expectation(description: "expect doThing")
        self.doThing = { [self] ip0, ip1 in
          if isTheSameOrNotEquatable(ip0, p0),
      isTheSameOrNotEquatable(ip1, p1) {
            fulfill()
            throw error
          } else {
             try await self.doThing(ip0, ip1)
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
