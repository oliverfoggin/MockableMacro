//
//  File.swift
//  MockableMacro
//
//  Created by Oliver Foggin on 31/08/2024.
//

import Foundation
@testable import MockableMacroClient
import XCTest

final class ClientTests: XCTestCase {
    func testFeature() {
        var dependency = MyDependency.test
        dependency.expectDoOtherThing(with: "abc", and: true, int0: 42, returning: 32.0)
        
        let sut = Feature(dependency: dependency)
        
        XCTAssertEqual(sut.doThing(with: "abc", and: true, int: 42), 32.0)
    }
}
