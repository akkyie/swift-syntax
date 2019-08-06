//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import SwiftSyntax

public struct StringLiteral: ExprBuildable {
    let value: String

    public init(_ value: String) {
        self.value = value
    }

    public func buildExpr(format: Format, leadingTrivia: Trivia) -> ExprSyntax {
        SyntaxFactory.makeStringLiteralExpr(value)
    }
}

extension StringLiteral: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}
