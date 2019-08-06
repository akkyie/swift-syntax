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

public struct SyntaxList: SyntaxListBuildable {
  let builders: [SyntaxListBuildable]

  public func buildSyntaxList(format: Format, leadingTrivia: Trivia) -> [Syntax] {
    // Returns indented newlines to join syntaxes
    func trivia(for index: Int) -> Trivia {
      leadingTrivia + (index > builders.startIndex ? .newlines(1) : .zero)
    }

    return builders
      .enumerated()
      .flatMap { index, builder in
        builder.buildSyntaxList(format: format, leadingTrivia: trivia(for: index))
    }
  }
}

extension SyntaxList {
  public static let empty = SyntaxList(builders: [])
}
