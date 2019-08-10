import XCTest
import SwiftSyntax

@testable import SwiftSyntaxBuilder

final class VariableTests: XCTestCase {
  let format = Format(indentWidth: 2).indented()

  func testLet() {
    let testCases: [UInt: (Let, String)] = [
      #line: (Let("str", of: "String"),
              #"  let str: String"#),
      #line: (Let("str", of: "String", value: StringLiteral("asdf")),
              #"  let str: String = "asdf""#),
      #line: (Let("num", of: "Int", value: IntegerLiteral(123)),
              #"  let num: Int = 123"#),
    ]

    for (line, testCase) in testCases {
      let (builder, expected) = testCase
      let syntax = builder.buildSyntax(format: format, leadingTrivia: .zero)

      var text = ""
      syntax.write(to: &text)

      XCTAssertEqual(text, expected, line: line)
    }
  }

  func testVar() {
    let testCases: [UInt: (Var, String)] = [
      #line: (Var("str", of: "String"),
              #"  var str: String"#),
      #line: (Var("str", of: "String", value: StringLiteral("asdf")),
              #"  var str: String = "asdf""#),
      #line: (Var("num", of: "Int", value: IntegerLiteral(123)),
              #"  var num: Int = 123"#),
    ]

    for (line, testCase) in testCases {
      let (builder, expected) = testCase
      let syntax = builder.buildSyntax(format: format, leadingTrivia: .zero)

      var text = ""
      syntax.write(to: &text)

      XCTAssertEqual(text, expected, line: line)
    }
  }
}
