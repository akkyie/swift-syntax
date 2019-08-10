import XCTest
import SwiftSyntax

@testable import SwiftSyntaxBuilder

final class ForEachTests: XCTestCase {
  let format = Format(indentWidth: 2).indented()

  func testForEachSyntax() {
    let sourceFile = SourceFile {
      ForEach(1 ... 3) { i in
        Import("Module\(i)")
      }
    }

    let syntax = sourceFile.buildSyntax(format: format, leadingTrivia: .zero)

    var text = ""
    syntax.write(to: &text)
    XCTAssertEqual(text, """
      import Module1
      import Module2
      import Module3
    """)
  }

  func testForEachDecl() {
    let sourceFile = Struct("TestStruct") {
      ForEach(1 ... 3) { i in
        Let("value\(i)", of: "String")
      }
    }

    let syntax = sourceFile.buildSyntax(format: format, leadingTrivia: .zero)

    var text = ""
    syntax.write(to: &text)
    XCTAssertEqual(text, """
      struct TestStruct {
        let value1: String
        let value2: String
        let value3: String
      }
    """)
  }
}
