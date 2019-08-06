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

public struct Struct: DeclBuildable {
  let name: String
  let memberList: DeclListBuildable

  public init(
    _ name: String,
    @DeclListBuilder buildMemberList: () -> DeclListBuildable = { DeclList.empty }
  ) {
    self.name = name
    self.memberList = buildMemberList()
  }

  public func buildDecl(format: Format, leadingTrivia: Trivia) -> DeclSyntax {
    let structKeyword = Tokens.struct.withLeadingTrivia(leadingTrivia + format.makeIndent())

    let declList = memberList.buildDeclList(
      format: format.indented(),
      leadingTrivia: .newlines(1)
    )

    return StructDeclSyntax {
      $0.useStructKeyword(structKeyword)
      $0.useIdentifier(SyntaxFactory.makeIdentifier(name))
      $0.useMembers(MemberDeclBlockSyntax {
        $0.useLeftBrace(Tokens.leftBrace.withLeadingTrivia(.spaces(1)))
        $0.useRightBrace(Tokens.rightBrace.withLeadingTrivia(.newlines(1) + format.makeIndent()))

        for decl in declList {
          $0.addMember(SyntaxFactory.makeMemberDeclListItem(decl: decl, semicolon: nil))
        }
      })
    }
  }
}
