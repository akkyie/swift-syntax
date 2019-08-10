import XCTest
import SwiftSyntax

@testable import SwiftSyntaxBuilder

final class ImportTests: XCTestCase {
  func testImport() {
    let format = Format(indentWidth: 2).indented()

    let testCases: [UInt: (Import, String)] = [
      #line: (Import("SwiftSyntax"),
              "  import SwiftSyntax"),
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
