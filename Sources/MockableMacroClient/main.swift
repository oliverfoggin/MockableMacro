import MockableMacro

struct Foo {
    let string: String
}

@Mockable
struct MyDependency {
    var string: String
    var doThing: () -> Void
    var doOtherThing: (_ with: String, _ and: Bool, Int) -> Float
    var doSomething: (Foo) -> Void
    var bad: (Int) -> String {
        { _ in "" }
    }
    var good: (Int) -> String {
        didSet { print("Foo") }
    }
}

extension MyDependency {
    static var test: Self {
        .init(
            string: "",
            doThing: {},
            doOtherThing: { _, _, _ in 0.0 },
            doSomething: { _ in },
            good: { _ in "" }
        )
    }
}

var dependency = MyDependency(
    string: "",
    doThing: { print("Hello!") },
    doOtherThing: { with, and, int in
        and ? Float(int) : -1
    },
    doSomething: { _ in
        print("Foo")
    },
    good: { _ in "" }
)

//dependency.expectDoOtherThing(with: "abc", and: true, int0: 42, returning: 7)

print(dependency.doOtherThing("abc", true, 42))

//dependency.expectDoSomething(foo0: .init(string: "Goodbye"))

dependency.doSomething(.init(string: "Hello"))

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
