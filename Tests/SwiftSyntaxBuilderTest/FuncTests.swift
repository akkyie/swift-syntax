import XCTest
import SwiftSyntax

@testable import SwiftSyntaxBuilder

final class FuncTests: XCTestCase {
  let format = Format(indentWidth: 2).indented()

  func testFunc() {
    let builder = Func("doSomething") {
      Let("number", of: "Int")
    }

    let syntax = builder.buildSyntax(format: format, leadingTrivia: .zero)

    var text = ""
    syntax.write(to: &text)

    XCTAssertEqual(text, """
      func doSomething () {
        let number: Int
      }
    """)
  }
}
