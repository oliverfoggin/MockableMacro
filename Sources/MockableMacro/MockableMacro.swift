// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(peer, names: arbitrary)
public macro MockableEndpoint() = #externalMacro(module: "MockableMacroMacros", type: "MockableEndpointMacro")

@attached(memberAttribute)
public macro Mockable() = #externalMacro(module: "MockableMacroMacros", type: "MockableClientMacro")
