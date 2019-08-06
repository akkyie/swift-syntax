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

public protocol ExprListBuildable: SyntaxListBuildable {
  func buildExprList(format: Format, leadingTrivia: Trivia) -> [ExprSyntax]
}

public protocol ExprBuildable: SyntaxBuildable, ExprListBuildable {
  func buildExpr(format: Format, leadingTrivia: Trivia) -> ExprSyntax
}

extension ExprBuildable {
  public func buildSyntax(format: Format, leadingTrivia: Trivia) -> Syntax {
    buildExpr(format: format, leadingTrivia: leadingTrivia)
  }

  public func buildExprList(format: Format, leadingTrivia: Trivia) -> [ExprSyntax] {
    [buildExpr(format: format, leadingTrivia: leadingTrivia)]
  }
}
