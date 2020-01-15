
import XCTest
import SwiftSyntax

import SwiftSyntaxBuilder

final class TypeTests: XCTestCase {
  func testIdentifier() {
    let leadingTrivia = Trivia.garbageText("␣")

    let testCases: [UInt: (Type, String)] = [
      #line: (Type("Test"), "␣Test"),
      #line: ("Test", "␣Test"), // ExpressibleByStringLiteral
    ]

    for (line, testCase) in testCases {
      let (builder, expected) = testCase
      let syntax = builder.buildSyntax(format: Format(), leadingTrivia: leadingTrivia)

      var text = ""
      syntax.write(to: &text)

      XCTAssertEqual(text, expected, line: line)
    }
  }
  
  func testTuple() {
    let leadingTrivia = Trivia.garbageText("␣")

    let testCases: [UInt: (Type, String)] = [
      #line: (Type.tuple(),
              "␣()"),
      #line: (Type.tuple("String"),
              "␣(String)"),
      #line: (Type.tuple("String", "Int"),
              "␣(String, Int)"),
      #line: (Type.tuple("String", "Int", "Float"),
              "␣(String, Int, Float)"),
      #line: (["": "String", "num": "Int"], // ExpressibleByDictionaryLiteral
              "␣(String, num: Int)"),
      #line: (["String", "Int"],            // ExpressibleByArrayLiteral
              "␣(String, Int)"),
    ]

    for (line, testCase) in testCases {
      let (builder, expected) = testCase
      let syntax = builder.buildSyntax(format: Format(), leadingTrivia: leadingTrivia)

      var text = ""
      syntax.write(to: &text)

      XCTAssertEqual(text, expected, line: line)
    }
  }

  func testFunctionType() {
    let leadingTrivia = Trivia.garbageText("␣")

    let testCases: [UInt: (Type, String)] = [
      #line: (Type.function(returnType: "String"),
              "␣() -> String"),
      #line: (Type.function(parameters: [("foo", "String")], returnType: "String"),
              "␣(foo: String) -> String"),
    ]

    for (line, testCase) in testCases {
      let (builder, expected) = testCase
      let syntax = builder.buildSyntax(format: Format(), leadingTrivia: leadingTrivia)

      var text = ""
      syntax.write(to: &text)

      XCTAssertEqual(text, expected, line: line)
    }
  }

  func testArrayType() {
    let leadingTrivia = Trivia.garbageText("␣")

    let testCases: [UInt: (Type, String)] = [
      #line: (Type.array("String"),
              "␣[String]"),
    ]

    for (line, testCase) in testCases {
      let (builder, expected) = testCase
      let syntax = builder.buildSyntax(format: Format(), leadingTrivia: leadingTrivia)

      var text = ""
      syntax.write(to: &text)

      XCTAssertEqual(text, expected, line: line)
    }
  }

  func testDictionaryType() {
    let leadingTrivia = Trivia.garbageText("␣")

    let testCases: [UInt: (Type, String)] = [
      #line: (Type.dictionary(key: "String", value: "Int"),
              "␣[String: Int]"),
    ]

    for (line, testCase) in testCases {
      let (builder, expected) = testCase
      let syntax = builder.buildSyntax(format: Format(), leadingTrivia: leadingTrivia)

      var text = ""
      syntax.write(to: &text)

      XCTAssertEqual(text, expected, line: line)
    }
  }

  func testOptionalType() {
    let leadingTrivia = Trivia.garbageText("␣")

    let testCases: [UInt: (Type, String)] = [
      #line: (Type.optional(.wrapped("String")),
              "␣String?"),
      #line: (Type.optional("String"),
              "␣String?"),

      #line: (Type.optional(.implicitlyUnwrapped("String")),
              "␣String!"),
    ]

    for (line, testCase) in testCases {
      let (builder, expected) = testCase
      let syntax = builder.buildSyntax(format: Format(), leadingTrivia: leadingTrivia)

      var text = ""
      syntax.write(to: &text)

      XCTAssertEqual(text, expected, line: line)
    }
  }

  func testCompositionType() {
    let leadingTrivia = Trivia.garbageText("␣")

    let testCases: [UInt: (Type, String)] = [
      #line: (Type.composition([]),
              ""),
      #line: (Type.composition(["Encodable"]),
              "␣Encodable"),
      #line: (Type.composition(["Encodable", "Decodable"]),
              "␣Encodable & Decodable"),
    ]

    for (line, testCase) in testCases {
      let (builder, expected) = testCase
      let syntax = builder.buildSyntax(format: Format(), leadingTrivia: leadingTrivia)

      var text = ""
      syntax.write(to: &text)

      XCTAssertEqual(text, expected, line: line)
    }
  }

  func testOpaqueType() {
    let leadingTrivia = Trivia.garbageText("␣")

    let testCases: [UInt: (Type, String)] = [
      #line: (Type.opaque("Equatable"), "␣some Equatable"),
    ]

    for (line, testCase) in testCases {
      let (builder, expected) = testCase
      let syntax = builder.buildSyntax(format: Format(), leadingTrivia: leadingTrivia)

      var text = ""
      syntax.write(to: &text)

      XCTAssertEqual(text, expected, line: line)
    }
  }

  func testMetatypeType() {
    let leadingTrivia = Trivia.garbageText("␣")

    let testCases: [UInt: (Type, String)] = [
      #line: (Type.metatype(of: .type("String")),
              "␣String.Type"),
      #line: (Type.metatype(of: .protocol("Equatable")),
              "␣Equatable.Protocol"),
    ]

    for (line, testCase) in testCases {
      let (builder, expected) = testCase
      let syntax = builder.buildSyntax(format: Format(), leadingTrivia: leadingTrivia)

      var text = ""
      syntax.write(to: &text)

      XCTAssertEqual(text, expected, line: line)
    }
  }

  func testSelfType() {
    let leadingTrivia = Trivia.garbageText("␣")

    let testCases: [UInt: (Type, String)] = [
      #line: (Type.selfType, "␣Self"),
    ]

    for (line, testCase) in testCases {
      let (builder, expected) = testCase
      let syntax = builder.buildSyntax(format: Format(), leadingTrivia: leadingTrivia)

      var text = ""
      syntax.write(to: &text)

      XCTAssertEqual(text, expected, line: line)
    }
  }
}
