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

public protocol TypeListBuildable: SyntaxListBuildable {
  func buildTypeList(format: Format, leadingTrivia: Trivia) -> [TypeSyntax]
}

public protocol TypeBuildable: SyntaxBuildable, TypeListBuildable {
  func buildType(format: Format, leadingTrivia: Trivia) -> TypeSyntax
}

extension TypeBuildable {
  public func buildSyntax(format: Format, leadingTrivia: Trivia) -> Syntax {
    Syntax(buildType(format: format, leadingTrivia: leadingTrivia))
  }
  
  public func buildTypeList(format: Format, leadingTrivia: Trivia) -> [TypeSyntax] {
    [buildType(format: format, leadingTrivia: leadingTrivia)]
  }
}

// MARK: - Type

public indirect enum Type: TypeBuildable {
  public enum OptionalType {
    case wrapped(Type)
    case implicitlyUnwrapped(Type)
  }

  public enum BaseType {
    case type(Type)
    case `protocol`(Type)
  }

  case identifier(String)
  case tuple([(String, Type)])
  case function(parameters: [(String, Type)] = [], returnType: Type)
  case array(Type)
  case dictionary(key: Type, value: Type)
  case optional(OptionalType)
  case composition([Type])
  case opaque(Type)
  case metatype(of: BaseType)
  case selfType
  
  public func buildType(format: Format, leadingTrivia: Trivia) -> TypeSyntax {
    let typeSyntax: TypeSyntax

    switch self {
    case let .identifier(identifier):
      typeSyntax = SyntaxFactory.makeTypeIdentifier(identifier)
    
    case let .tuple(elements):
      let elementList = SyntaxFactory.makeTupleTypeElementList(
        elements.map(distinguishingLast: { element, isLast in
          let (name, type) = element
          return SyntaxFactory.makeTupleTypeElement(
            type: type.buildType(format: format, leadingTrivia: .zero),
            trailingComma: isLast ? nil : Tokens.comma
          )
            .withName(name.isEmpty ? nil : SyntaxFactory.makeIdentifier(name))
            .withColon(name.isEmpty ? nil : Tokens.colon)
        })
      )
      let tupleType = SyntaxFactory.makeTupleType(
        leftParen: Tokens.leftParen,
        elements: elementList,
        rightParen: Tokens.rightParen
      )
      typeSyntax = TypeSyntax(tupleType)
      
    case let .function(parameters, returnType):
      let elementList = SyntaxFactory.makeTupleTypeElementList(
        parameters.map(distinguishingLast: { element, isLast in
          let (name, type) = element
          return SyntaxFactory.makeTupleTypeElement(
            type: type.buildType(format: format, leadingTrivia: .zero),
            trailingComma: isLast ? nil : Tokens.comma
          )
            .withName(name.isEmpty ? nil : SyntaxFactory.makeIdentifier(name))
            .withColon(name.isEmpty ? nil : Tokens.colon)
        })
      )
      let functionType = SyntaxFactory.makeFunctionType(
        leftParen: Tokens.leftParen,
        arguments: elementList,
        rightParen: Tokens.rightParen,
        throwsOrRethrowsKeyword: nil,
        arrow: Tokens.arrow,
        returnType: returnType.buildType(format: format, leadingTrivia: .zero)
      )
      typeSyntax = TypeSyntax(functionType)
      
    case let .array(type):
      let arrayType = SyntaxFactory.makeArrayType(
        leftSquareBracket: Tokens.leftBrancket,
        elementType: type.buildType(format: format, leadingTrivia: .zero),
        rightSquareBracket: Tokens.rightBrancket
      )
      typeSyntax = TypeSyntax(arrayType)

    case let .dictionary(keyType, valueType):
      let dictionaryType = SyntaxFactory.makeDictionaryType(
        leftSquareBracket: Tokens.leftBrancket, 
        keyType: keyType.buildType(format: format, leadingTrivia: .zero), 
        colon: Tokens.colon, 
        valueType: valueType.buildType(format: format, leadingTrivia: .zero),
        rightSquareBracket: Tokens.rightBrancket
      )
      typeSyntax = TypeSyntax(dictionaryType)
      
    case let .optional(.wrapped(type)):
      let optionalType = SyntaxFactory.makeOptionalType(
        wrappedType: type.buildType(format: format, leadingTrivia: .zero), 
        questionMark: Tokens.questionMark.postfix
      )
      typeSyntax = TypeSyntax(optionalType)

    case let .optional(.implicitlyUnwrapped(type)):
      let optionalType = SyntaxFactory.makeImplicitlyUnwrappedOptionalType(
        wrappedType: type.buildType(format: format, leadingTrivia: .zero),
        exclamationMark: Tokens.exclamationMark
      )
      typeSyntax = TypeSyntax(optionalType)

    case let .composition(types):
      let elementList = SyntaxFactory.makeCompositionTypeElementList(
        types.map(distinguishingLast: { type, isLast in
          SyntaxFactory.makeCompositionTypeElement(
            type: type.buildType(format: format, leadingTrivia: .zero),
            ampersand: isLast ? nil : Tokens.ampersand.infix
          )
        })
      )
      let compositionType = SyntaxFactory.makeCompositionType(elements: elementList)
      typeSyntax = TypeSyntax(compositionType)

    case let .opaque(type):
      let someType = SyntaxFactory.makeSomeType(
        someSpecifier: Tokens.some,
        baseType: type.buildType(format: format, leadingTrivia: .zero)
      )
      typeSyntax = TypeSyntax(someType)

    case let .metatype(metatype):
      let metatypeType = SyntaxFactory.makeMetatypeType(
        baseType: metatype.baseType.buildType(format: format, leadingTrivia: leadingTrivia),
        period: Tokens.period,
        typeOrProtocol: metatype.makeTypeOrProtocolSyntax()
      )
      typeSyntax = TypeSyntax(metatypeType)

    case .selfType:
      typeSyntax = SyntaxFactory.makeSelfTypeIdentifier()
    }

    return typeSyntax.withLeadingTrivia(leadingTrivia)
  }
}

// MARK: - Simple Identifier

extension Type: ExpressibleByStringLiteral {
  public init(identifier: String) {
    self = .identifier(identifier)
  }
  
  public init(stringLiteral identifier: String) {
    self = .identifier(identifier)
  }
}

// MARK: - Tuple

extension Type: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral types: (String, Type)...) {
    self = .tuple(types)
  }
}

extension Type: ExpressibleByArrayLiteral {
  public static func tuple(_ types: [Type]) -> Type {
    return .tuple(types.map { ("", $0) })
  }
  
  public static func tuple(_ types: Type...) -> Type {
    return .tuple(types)
  }
  
  public init(arrayLiteral elements: Type...) {
    self = .tuple(elements)
  }
}

// MARK: - Utility Initializers

extension Type {
  public static func optional(_ type: Type) -> Type {
    .optional(.wrapped(type))
  }
}

// MARK: - Private Extensions

private extension Collection {
  func map<T>(distinguishingLast transform: (Element, _ isLast: Bool) throws -> T) rethrows -> [T] {
    guard count > 0 else { return [] }
    return try zip(self, repeatElement(false, count: count - 1) + [true]).map(transform)
  }
}

private extension Type.BaseType {
  var baseType: Type {
    switch self {
    case let .type(type), let .protocol(type):
      return type
    }
  }

  func makeTypeOrProtocolSyntax() -> TokenSyntax {
    switch self {
    case .type:
      return SyntaxFactory.makeIdentifier("Type")
    case .protocol:
      return SyntaxFactory.makeIdentifier("Protocol")
    }
  }
}
