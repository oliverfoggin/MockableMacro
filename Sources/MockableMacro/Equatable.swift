public extension Equatable {
  func isEqual(_ rhs: any Equatable) -> Bool {
    guard let rhs = rhs as? Self else {
      return false
    }
    return self == rhs
  }
}

public func isTheSameOrNotEquatable<T>(_ lhs: T, _ rhs: T) -> Bool {
    guard let left = lhs as? any Equatable, let right = rhs as? any Equatable else {
        return true
    }
    return left.isEqual(right)
}
