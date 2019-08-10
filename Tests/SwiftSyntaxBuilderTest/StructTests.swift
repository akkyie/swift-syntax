import XCTest
import SwiftSyntax

@testable import SwiftSyntaxBuilder

final class StructTests: XCTestCase {
  let format = Format(indentWidth: 2).indented()

  func testStruct() {
    let testCases: [UInt: (Struct, String)] = [
      #line: (
        Struct("TestStruct"),
        """
          struct TestStruct {
          }
        """
      ),

      #line: (
        Struct("TestStruct") {
          Let("name", of: "String")
        },
        """
          struct TestStruct {
            let name: String
          }
        """
      ),
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
