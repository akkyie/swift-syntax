import XCTest
import SwiftSyntax

@testable import SwiftSyntaxBuilder

final class SourceFileTests: XCTestCase {
  let format = Format(indentWidth: 2).indented()

  func testSourceFile() {
    let sourceFile = SourceFile {
      Import("SwiftSyntax")

      Struct("ExampleStruct") {
        Let("syntax", of: "Syntax")
      }
    }

    let syntax = sourceFile.buildSyntax(format: format, leadingTrivia: .zero)

    var text = ""
    syntax.write(to: &text)
    XCTAssertEqual(text, """
      import SwiftSyntax
      struct ExampleStruct {
        let syntax: Syntax
      }
    """)
  }
}
