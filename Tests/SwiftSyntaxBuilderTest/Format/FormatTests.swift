import XCTest
import SwiftSyntax

@testable import SwiftSyntaxBuilder

final class FormatTests: XCTestCase {
  func testMakeIndented() {
    for width in 1 ... 4 {
      let format = Format(indentWidth: width)

      XCTAssertEqual(format.makeIndent(), .zero)
      XCTAssertEqual(format.indented().makeIndent(), .spaces(width))
      XCTAssertEqual(format.indented().indented().makeIndent(), .spaces(width * 2))
    }
  }
}
