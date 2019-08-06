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

public struct Import: DeclBuildable {
  let moduleName: String

  public init(_ moduleName: String) {
    self.moduleName = moduleName
  }

  public func buildDecl(format: Format, leadingTrivia: Trivia) -> DeclSyntax {
    let importToken = Tokens.import.withLeadingTrivia(leadingTrivia + format.makeIndent())
    let moduleNameToken = SyntaxFactory.makeIdentifier(moduleName)

    return ImportDeclSyntax {
      $0.useImportTok(importToken)
      $0.addPathComponent(AccessPathComponentSyntax {
        $0.useName(moduleNameToken)
      })
    }
  }
}
