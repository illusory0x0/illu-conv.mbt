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

// TODO:
// 
// - Format functions.
// - Support hexadecimal floating point number.
// - Implements Eisel-Lemire algorithm to speed up floating point parsing.

///|
pub(open) trait FromStringView {
  tokenize(StringView) -> (Self, Int) raise StrConvError
}

///|
pub impl FromStringView for Bool with tokenize(str) {
  tokenize_bool(str)
}

///|
pub impl FromStringView for Int with tokenize(str) {
  tokenize_int(str)
}

///|
pub impl FromStringView for Int64 with tokenize(str) {
  tokenize_int64(str)
}

///|
pub impl FromStringView for UInt with tokenize(str) {
  tokenize_uint(str)
}

///|
pub impl FromStringView for UInt64 with tokenize(str) {
  tokenize_uint64(str)
}

///|
pub impl FromStringView for Double with tokenize(str) {
  tokenize_double(str)
}

///|
pub fn[A : FromStringView] tokenize(
  str : String,
) -> (A, Int) raise StrConvError {
  FromStringView::tokenize(str)
}

///|
test "parse" {
  let (b, len_b) : (Bool, Int) = tokenize("true")
  inspect(b, content="true")
  assert_eq(len_b, 4)
  let (i, len_i) : (Int, Int) = tokenize("12345")
  inspect(i, content="12345")
  assert_eq(len_i, 5)
  let (i64, len_i64) : (Int64, Int) = tokenize("9223372036854775807")
  assert_eq(i64, 9223372036854775807L)
  assert_eq(len_i64, 19)
  let (ui, len_ui) : (UInt, Int) = tokenize("4294967295")
  inspect(ui, content="4294967295")
  assert_eq(len_ui, 10)
  let (ui64, len_ui64) : (UInt64, Int) = tokenize("18446744073709551615")
  assert_eq(ui64, 18446744073709551615UL)
  assert_eq(len_ui64, 20)
  let (d, len_d) : (Double, Int) = tokenize("1234.56789")
  assert_eq(d, 1234.56789)
  assert_eq(len_d, 10)
}
