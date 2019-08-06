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

public struct DeclList: DeclListBuildable {
  let builders: [DeclListBuildable]

  public func buildDeclList(format: Format, leadingTrivia: Trivia) -> [DeclSyntax] {
    builders.flatMap { $0.buildDeclList(format: format, leadingTrivia: leadingTrivia) }
  }

  public func buildSyntaxList(format: Format, leadingTrivia: Trivia) -> [Syntax] {
    buildDeclList(format: format, leadingTrivia: leadingTrivia)
  }
}

extension DeclList {
  public static let empty: DeclList = DeclList(builders: [])
}
