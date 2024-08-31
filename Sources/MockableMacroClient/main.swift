import MockableMacro

struct MyDependency {
    @Mockable var doThing: () -> Void
    
    @Mockable var doOtherThing: (_ with: String, _ and: Bool, Int) -> Float
}

extension MyDependency {
    static var test: Self {
        .init(
            doThing: {},
            doOtherThing: { _, _, _ in 0.0 }
        )
    }
}

var dependency = MyDependency(
    doThing: { print("Hello!") },
    doOtherThing: { with, and, int in
        and ? Float(int) : -1
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
}
