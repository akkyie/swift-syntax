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

public struct SourceFile: SyntaxBuildable {
  let builder: SyntaxListBuildable

  public init(@SyntaxListBuilder makeBuilder: () -> SyntaxListBuildable) {
    self.builder = makeBuilder()
  }

  public func buildSyntax(format: Format, leadingTrivia: Trivia) -> Syntax {
    let syntaxList = builder.buildSyntaxList(format: format, leadingTrivia: leadingTrivia)

    return SourceFileSyntax {
      for syntax in syntaxList {
        $0.addStatement(CodeBlockItemSyntax {
            $0.useItem(syntax)
        })
      }
    }
  }
}
