import XCTest
import SwiftSyntax

@testable import SwiftSyntaxBuilder

final class StringLiteralTests: XCTestCase {
  let format = Format(indentWidth: 2).indented()

  func testStringLiteral() {
    let testCases: [UInt: (StringLiteral, String)] = [
      #line: (StringLiteral(""), "\"\""),
      #line: (StringLiteral("asdf"), #""asdf""#),
      #line: ("", "\"\""),
      #line: ("asdf", #""asdf""#),
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
