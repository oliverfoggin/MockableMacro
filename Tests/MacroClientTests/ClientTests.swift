import Foundation
@testable import MockableMacroClient
import XCTest

final class ClientTests: XCTestCase {
    func testFeature() {
        var dependency = MyDependency.test
        dependency.expectDoOtherThing(with: "abc", and: true, 42, returning: 32.0)
        
        let sut = Feature(dependency: dependency)
        
        XCTAssertEqual(sut.doThing(with: "abc", and: true, int: 42), 32.0)
    }
    
    func testDoSomething() {
        var dependency = MyDependency.test
        dependency.expectDoSomething(Foo(string: "Hello"))
        
        let sut = Feature(dependency: dependency)
        
        sut.doSomething(Foo(string: "Goodbye"))
    }
}
