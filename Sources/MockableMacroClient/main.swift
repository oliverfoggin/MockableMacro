import MockableMacro

struct Foo {
    let string: String
}

struct MyDependency {
    @Mockable var doThing: () -> Void
    
    @Mockable var doOtherThing: (_ with: String, _ and: Bool, Int) -> Float
    
    @Mockable var doSomething: (Foo) -> Void
}

extension MyDependency {
    static var test: Self {
        .init(
            doThing: {},
            doOtherThing: { _, _, _ in 0.0 },
            doSomething: { _ in }
        )
    }
}

var dependency = MyDependency(
    doThing: { print("Hello!") },
    doOtherThing: { with, and, int in
        and ? Float(int) : -1
    },
    doSomething: { _ in
        print("Foo")
    }
)

dependency.expectDoOtherThing(with: "abc", and: true, int0: 42, returning: 7)

print(dependency.doOtherThing("abc", true, 42))

struct Feature {
    var dependency: MyDependency
    
    init(dependency: MyDependency) {
        self.dependency = dependency
    }
    
    func doThing(with: String, and: Bool, int: Int) -> Float {
        dependency.doOtherThing(with, and, int)
    }
    
    func doSomething(_ foo: Foo) {
        dependency.doSomething(foo)
    }
}
