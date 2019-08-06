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

public protocol DeclListBuildable: SyntaxListBuildable {
  func buildDeclList(format: Format, leadingTrivia: Trivia) -> [DeclSyntax]
}

public protocol DeclBuildable: SyntaxBuildable, DeclListBuildable {
  func buildDecl(format: Format, leadingTrivia: Trivia) -> DeclSyntax
}

extension DeclBuildable {
  public func buildSyntax(format: Format, leadingTrivia: Trivia) -> Syntax {
    buildDecl(format: format, leadingTrivia: leadingTrivia)
  }

  public func buildDeclList(format: Format, leadingTrivia: Trivia) -> [DeclSyntax] {
    [buildDecl(format: format, leadingTrivia: leadingTrivia)]
  }
}
