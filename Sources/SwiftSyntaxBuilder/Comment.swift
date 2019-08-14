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

public enum CommentType {
  case line
  case block
  case docLine
  case docBlock
}

extension CommentType {
  private var linePrefix: String? {
    switch self {
    case .line:
      return "// "
    case .docLine:
      return "/// "
    case .block, .docBlock:
      return nil
    }
  }

  private var blockPrefix: String? {
    switch self {
    case .line, .docLine:
      return nil
    case .block:
      return "/*"
    case .docBlock:
      return "/**"
    }
  }

  private var blockSuffix: String? {
    switch self {
    case .line, .docLine:
      return nil
    case .block, .docBlock:
      return " */"
    }
  }

  fileprivate func makeTrivia(_ text: String, _ format: Format) -> Trivia {
    let lines = text.split(separator: "\n").map(String.init)
    let block = ([blockPrefix] + lines + [blockSuffix]).compactMap { $0 }
    return block.reduce(Trivia.zero) { result, line in
      result
        + .newlines(1)
        + format.makeIndent()
    }
  }
}

public struct Commented<Buildable> {
  let type: CommentType
  let text: String
  let buildable: Buildable

  init(
    type: CommentType,
    text: String,
    buildable: Buildable
  ) {
    self.type = type
    self.text = text
    self.buildable = buildable
  }
}

extension Commented: SyntaxListBuildable where Buildable: SyntaxListBuildable {
  public func buildSyntaxList(format: Format, leadingTrivia: Trivia) -> [Syntax] {
    let comment = type.makeTrivia(text, format)
    return buildable.buildSyntaxList(
      format: format,
      leadingTrivia: comment + leadingTrivia
    )
  }
}

extension Commented: SyntaxBuildable where Buildable: SyntaxBuildable {
  public func buildSyntax(format: Format, leadingTrivia: Trivia) -> Syntax {
    let comment = type.makeTrivia(text, format)
    return buildable.buildSyntax(
      format: format,
      leadingTrivia: comment + leadingTrivia
    )
  }
}

extension Commented: DeclListBuildable where Buildable: DeclListBuildable {
  public func buildDeclList(format: Format, leadingTrivia: Trivia) -> [DeclSyntax] {
    let comment = type.makeTrivia(text, format)
    return buildable.buildDeclList(
      format: format,
      leadingTrivia: comment + leadingTrivia
    )
  }
}

extension Commented: DeclBuildable where Buildable: DeclBuildable {
  public func buildDecl(format: Format, leadingTrivia: Trivia) -> DeclSyntax {
    let comment = type.makeTrivia(text, format)
    return buildable.buildDecl(
      format: format,
      leadingTrivia: comment + leadingTrivia
    )
  }
}

extension SyntaxBuildable {
  public func withComment(_ text: String, type: CommentType = .line) -> Commented<Self> {
    Commented(type: type, text: text, buildable: self)
  }
}
