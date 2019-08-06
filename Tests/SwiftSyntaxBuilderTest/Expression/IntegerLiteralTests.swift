import XCTest
import SwiftSyntax

@testable import SwiftSyntaxBuilder

final class IntegerLiteralTests: XCTestCase {
  let format = Format(indentWidth: 2).indented()

  func testIntegerLiteral() {
    let testCases: [UInt: (IntegerLiteral, String)] = [
      #line: (IntegerLiteral(123), "123"),
      #line: (IntegerLiteral(-123), "-123"),
      #line: (123, "123"),
      #line: (-123, "-123"),
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
