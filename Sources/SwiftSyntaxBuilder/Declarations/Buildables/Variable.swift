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

public protocol VariableMutability {
  static var token: TokenSyntax { get }
}

public enum VariableLetMutability: VariableMutability {
  public static let token = Tokens.let
}

public enum VariableVarMutability: VariableMutability {
  public static let token = Tokens.var
}

public typealias Let = Variable<VariableLetMutability>
public typealias Var = Variable<VariableVarMutability>

public struct Variable<Mutability: VariableMutability>: DeclBuildable {
  let name: String
  let type: String
  let initializer: ExprBuildable?

  public init(_ name: String, of type: String, value: ExprBuildable? = nil) {
    self.name = name
    self.type = type
    self.initializer = value
  }

  public func buildDecl(format: Format, leadingTrivia: Trivia) -> DeclSyntax {
    let mutabilityKeyword = Mutability.token
      .withLeadingTrivia(leadingTrivia + format.makeIndent())

    let nameIdentifier = SyntaxFactory.makeIdentifier(name)
    let namePattern = SyntaxFactory.makeIdentifierPattern(identifier: nameIdentifier)

    let typeIdentifier = SyntaxFactory.makeTypeIdentifier(type)
    let typeAnnotation = SyntaxFactory.makeTypeAnnotation(
      colon: Tokens.colon,
      type: typeIdentifier
    )

    let initClause = initializer.flatMap { builder -> InitializerClauseSyntax in
      let expr = builder.buildExpr(format: format, leadingTrivia: leadingTrivia)
      return SyntaxFactory.makeInitializerClause(equal: Tokens.equal, value: expr)
    }

    return VariableDeclSyntax {
      $0.useLetOrVarKeyword(mutabilityKeyword)
      $0.addBinding(PatternBindingSyntax {
        $0.usePattern(namePattern)
        $0.useTypeAnnotation(typeAnnotation)

        if let initClause = initClause {
          $0.useInitializer(initClause)
        }
      })
    }
  }
}
