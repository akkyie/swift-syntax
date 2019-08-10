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

// MARK: - Protocols

public protocol SyntaxListBuildable {
  func buildSyntaxList(format: Format, leadingTrivia: Trivia) -> [Syntax]
}

public protocol SyntaxBuildable: SyntaxListBuildable {
  func buildSyntax(format: Format, leadingTrivia: Trivia) -> Syntax
}

extension SyntaxBuildable {
  public func buildSyntaxList(format: Format, leadingTrivia: Trivia) -> [Syntax] {
    [buildSyntax(format: format, leadingTrivia: leadingTrivia)]
  }
}

// MARK: - Function Builder

@_functionBuilder
struct SyntaxListBuilder {
  static func buildBlock(_ builders: SyntaxListBuildable...) -> SyntaxListBuildable {
    SyntaxList(builders: builders)
  }
}

// MARK: - List

public struct SyntaxList: SyntaxListBuildable {
  let builders: [SyntaxListBuildable]

  public func buildSyntaxList(format: Format, leadingTrivia: Trivia) -> [Syntax] {
    builders.flatMap {
      $0.buildSyntaxList(format: format, leadingTrivia: leadingTrivia)
    }
  }
}

extension SyntaxList {
  public static let empty = SyntaxList(builders: [])
}

// MARK: - Buildables

// MARK: Source File

public struct SourceFile: SyntaxBuildable {
  let builder: SyntaxListBuildable

  public init(@SyntaxListBuilder makeBuilder: () -> SyntaxListBuildable) {
    self.builder = makeBuilder()
  }

  public func buildSyntax(format: Format, leadingTrivia: Trivia) -> Syntax {
    let syntaxList = builder.buildSyntaxList(format: format, leadingTrivia: leadingTrivia)

    return SourceFileSyntax {
      for (index, syntax) in syntaxList.enumerated() {
        let leadingTrivia: Trivia =
          index == syntaxList.startIndex
            ? format.makeIndent()
            : .newlines(1) + format.makeIndent()

        $0.addStatement(CodeBlockItemSyntax {
          $0.useItem(syntax)
        }.withLeadingTrivia(leadingTrivia))
      }
    }
  }
}

// MARK: - ForEach

public struct ForEach<Item, Body> {
  let builders: [Body]
}

extension ForEach: SyntaxListBuildable where Body: SyntaxListBuildable {
  public init<Data>(
    _ data: Data,
    @SyntaxListBuilder makeBuilder: (Item) -> Body
  ) where Data: Sequence, Data.Element == Item {
    self.builders = data.map(makeBuilder)
  }

  public func buildSyntaxList(format: Format, leadingTrivia: Trivia) -> [Syntax] {
    builders.flatMap {
      $0.buildSyntaxList(format: format, leadingTrivia: leadingTrivia)
    }
  }
}

extension ForEach: DeclListBuildable where Body: DeclListBuildable {
  public init<Data>(
    _ data: Data,
    @DeclListBuilder makeBuilder: (Item) -> Body
  ) where Data: Sequence, Data.Element == Item {
    self.builders = data.map(makeBuilder)
  }

  public func buildDeclList(format: Format, leadingTrivia: Trivia) -> [DeclSyntax] {
    builders.flatMap {
      $0.buildDeclList(format: format, leadingTrivia: leadingTrivia)
    }
  }
}
