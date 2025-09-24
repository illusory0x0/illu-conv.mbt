// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
let syntax_err = "invalid syntax"

///|
let base_err = "invalid base"

///|
fn tokenize_as_result(s : String, base~ : Int) -> Result[Int64, String] {
  try @lexer_string.tokenize_int64(s, base~).0 |> Ok catch {
    @lexer_string.StrConvError(err) => Err(err)
  }
}

///|
test "tokenize_int64_invalid_base" {
  assert_eq(tokenize_as_result("12345", base=1), Err(base_err))
  assert_eq(tokenize_as_result("12345", base=37), Err(base_err))
  assert_eq(tokenize_as_result("12345", base=-1), Err(base_err))
  assert_eq(tokenize_as_result("12345", base=100), Err(base_err))
}

///|
test "tokenize_int64_uncovered_lines" {
  let tests : Array[(String, Int, Result[Int64, String])] = [
    // Test cases for uncovered lines in strconv/int.mbt:69
    ("A", 16, Ok(10L)),
    ("a", 16, Ok(10L)),
    ("Z", 36, Ok(35L)),
    ("z", 36, Ok(35L)),
    ("G", 16, Err(syntax_err)),
    ("g", 16, Err(syntax_err)),
    ("@", 16, Err(syntax_err)),
    ("`", 16, Err(syntax_err)),
    ("[", 16, Err(syntax_err)),
    ("{", 16, Err(syntax_err)),
  ]
  for i in 0..<tests.length() {
    let t = tests[i]
    assert_eq(tokenize_as_result(t.0, base=t.1), t.2)
  }
}

///|
test "@lexer_string.tokenize_int64/base_parsing" {
  // Test different bases
  inspect(@lexer_string.tokenize_int64("1010", base=2), content="(10, 4)")
  inspect(@lexer_string.tokenize_int64("777", base=8), content="(511, 3)")
  inspect(@lexer_string.tokenize_int64("ff", base=16), content="(255, 2)")
  // Test auto-detection of base
  inspect(@lexer_string.tokenize_int64("0xFF"), content="(255, 4)")
  inspect(@lexer_string.tokenize_int64("0b1010"), content="(10, 6)")
  inspect(@lexer_string.tokenize_int64("0o777"), content="(511, 5)")
}

///|
test "panic @lexer_string.tokenize_int64/invalid_input" {
  // Empty string
  ignore(@lexer_string.tokenize_int64(""))
  // Invalid characters for given base
  ignore(@lexer_string.tokenize_int64("2", base=2))
  // Invalid base
  ignore(@lexer_string.tokenize_int64("123", base=37))
}

///|
test "@lexer_string.tokenize_int64/boundary_values" {
  // Test minimum and maximum values
  inspect(
    @lexer_string.tokenize_int64("-9223372036854775808"),
    content="(-9223372036854775808, 20)",
  )
  inspect(
    @lexer_string.tokenize_int64("9223372036854775807"),
    content="(9223372036854775807, 19)",
  )
  // Test with underscores
  inspect(
    @lexer_string.tokenize_int64("922_3372_0368_5477_5807"),
    content="(9223372036854775807, 23)",
  )
  // Test with different sign prefixes
  inspect(@lexer_string.tokenize_int64("+42"), content="(42, 3)")
  inspect(@lexer_string.tokenize_int64("-42"), content="(-42, 3)")
}

///|
test "@lexer_string.tokenize_int64/base10" {
  inspect(@lexer_string.tokenize_int64("12345"), content="(12345, 5)")
  inspect(@lexer_string.tokenize_int64("-12345"), content="(-12345, 6)")
  inspect(@lexer_string.tokenize_int64("0"), content="(0, 1)")
  inspect(@lexer_string.tokenize_int64("-0"), content="(0, 2)")
}

///|
test "@lexer_string.tokenize_int64/boundary_cases" {
  inspect(
    @lexer_string.tokenize_int64("9223372036854775807"),
    content="(9223372036854775807, 19)",
  )
  inspect(
    @lexer_string.tokenize_int64("-9223372036854775808"),
    content="(-9223372036854775808, 20)",
  )
}

///|
test "panic @lexer_string.tokenize_int64/invalid_base" {
  ignore(@lexer_string.tokenize_int64("12345x"))
}

///|
test "edge cases" {
  // Invalid: Missing digits after hex prefix
  inspect(
    try? @lexer_string.tokenize_int64("0x"),
    content="Err(invalid syntax)",
  )
  inspect(
    try? @lexer_string.tokenize_int64("0x_"),
    content="Err(invalid syntax)",
  )

  // Underscore is allowed between the prefix and the first digit
  inspect(
    try? @lexer_string.tokenize_int64("0x_DEADBEEF"),
    content="Ok((3735928559, 11))",
  )
}

///|
test "more edge cases" {
  inspect(
    try? @lexer_string.tokenize_int64("0b01", base=16),
    content="Ok((2817, 4))",
  )
  inspect(
    try? @lexer_string.tokenize_int64("0o01", base=16),
    content="Err(invalid syntax)",
  )
  inspect(
    try? @lexer_string.tokenize_int64("0x01", base=16),
    content="Ok((1, 4))",
  )
  inspect(
    try? @lexer_string.tokenize_int64("0b01", base=16),
    content="Ok((2817, 4))",
  )
  inspect(
    try? @lexer_string.tokenize_int64("0o01", base=16),
    content="Err(invalid syntax)",
  )
  inspect(
    try? @lexer_string.tokenize_int64("0x01", base=16),
    content="Ok((1, 4))",
  )
  inspect(
    try? @lexer_string.tokenize_int64("0b01", base=16),
    content="Ok((2817, 4))",
  )
  inspect(
    try? @lexer_string.tokenize_int64("0o01", base=16),
    content="Err(invalid syntax)",
  )
  inspect(
    try? @lexer_string.tokenize_int64("0x01", base=16),
    content="Ok((1, 4))",
  )
  inspect(
    try? @lexer_string.tokenize_int64("0b01", base=16),
    content="Ok((2817, 4))",
  )
  inspect(
    try? @lexer_string.tokenize_int64("0o01", base=16),
    content="Err(invalid syntax)",
  )
  inspect(
    try? @lexer_string.tokenize_int64("0x01", base=16),
    content="Ok((1, 4))",
  )
  inspect(
    try? @lexer_string.tokenize_int64("0b01", base=10),
    content="Err(invalid syntax)",
  )
  inspect(
    try? @lexer_string.tokenize_int64("0o01", base=10),
    content="Err(invalid syntax)",
  )
  inspect(
    try? @lexer_string.tokenize_int64("0x01", base=10),
    content="Err(invalid syntax)",
  )
}
