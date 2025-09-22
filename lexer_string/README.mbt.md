# string_conv

A MoonBit library for parsing various data types from `String` and `StringView`, providing efficient conversion functionality for integers, decimals, booleans and other data types with support for multiple numeric bases and comprehensive error handling.

## Quick Start

```moonbit
///|
test "basic usage" {
  // Parse integers from strings
  let num = @lexer_string.tokenize_int("42")
  @json.inspect(num, content=42)

  // Parse with different bases
  let hex = @lexer_string.tokenize_int("ff", base=16)
  @json.inspect(hex, content=255)

  // Parse booleans
  let flag = @lexer_string.tokenize_bool("true")
  @json.inspect(flag, content=true)
}
```

## Error Handling

All parsing functions can raise `StrConvError` when the input cannot be parsed:

```moonbit
///|
test "error handling" {
  // Using try? to get Result type
  let result = try? @lexer_string.tokenize_int("invalid")
  match result {
    Ok(_) =>
      @json.inspect("Should not reach here", content="Should not reach here")
    Err(@lexer_string.StrConvError(msg)) =>
      @json.inspect(msg, content="invalid syntax")
  }

  // Handle specific errors
  let safe_result = @lexer_string.tokenize_double("not_a_number") catch {
    @lexer_string.StrConvError(msg) => {
      @json.inspect(msg, content="invalid syntax")
      0.0
    }
  }
  @json.inspect(safe_result, content=0.0)
}
```

## Integer Parsing

### tokenize_int

Parse integers from `StringView` with optional base specification:

```moonbit
///|
test "tokenize_int examples" {
  // Default base 10
  @json.inspect(@lexer_string.tokenize_int("123"), content=123)
  @json.inspect(@lexer_string.tokenize_int("-456"), content=-456)

  // Different bases
  @json.inspect(@lexer_string.tokenize_int("ff", base=16), content=255)
  @json.inspect(@lexer_string.tokenize_int("1010", base=2), content=10)
  @json.inspect(@lexer_string.tokenize_int("77", base=8), content=63)

  // Edge cases
  @json.inspect(@lexer_string.tokenize_int("0"), content=0)
  @json.inspect(@lexer_string.tokenize_int("+42"), content=42)
}
```

### tokenize_int64

Parse 64-bit integers from `StringView`:

```moonbit
///|
test "tokenize_int64 examples" {
  inspect(
    @lexer_string.tokenize_int64("9223372036854775807"),
    content="9223372036854775807",
  )
  inspect(
    @lexer_string.tokenize_int64("-9223372036854775808"),
    content="-9223372036854775808",
  )

  // With different bases
  inspect(
    @lexer_string.tokenize_int64("deadbeef", base=16),
    content="3735928559",
  )
  inspect(
    @lexer_string.tokenize_int64("1111000011110000", base=2),
    content="61680",
  )
}
```

### tokenize_uint

Parse unsigned integers from `StringView`:

```moonbit
///|
test "tokenize_uint examples" {
  inspect(@lexer_string.tokenize_uint("4294967295"), content="4294967295")
  inspect(@lexer_string.tokenize_uint("0"), content="0")

  // With different bases
  inspect(
    @lexer_string.tokenize_uint("ffffffff", base=16),
    content="4294967295",
  )
  inspect(@lexer_string.tokenize_uint("377", base=8), content="255")
}
```

### tokenize_uint64

Parse 64-bit unsigned integers from `StringView`:

```moonbit
///|
test "tokenize_uint64 examples" {
  inspect(
    @lexer_string.tokenize_uint64("18446744073709551615"),
    content="18446744073709551615",
  )
  inspect(@lexer_string.tokenize_uint64("0"), content="0")

  // With different bases
  inspect(
    @lexer_string.tokenize_uint64("ffffffffffffffff", base=16),
    content="18446744073709551615",
  )
}
```

## Floating Point Parsing

### tokenize_double

Parse double-precision floating point numbers from `StringView`:

```moonbit
///|
test "tokenize_double examples" {
  @json.inspect(@lexer_string.tokenize_double("3.14159"), content=3.14159)
  @json.inspect(@lexer_string.tokenize_double("-2.718"), content=-2.718)
  @json.inspect(@lexer_string.tokenize_double("0.0"), content=0.0)

  // Scientific notation
  @json.inspect(@lexer_string.tokenize_double("1.5e10"), content=15000000000.0)
  @json.inspect(@lexer_string.tokenize_double("2.5e-3"), content=0.0025)

  // Special values  
  let inf_val = @lexer_string.tokenize_double("inf")
  let neg_inf_val = @lexer_string.tokenize_double("-inf")
  inspect(inf_val > 0.0 && inf_val.is_inf(), content="true")
  inspect(neg_inf_val < 0.0 && neg_inf_val.is_inf(), content="true")
}
```

## Boolean Parsing

### tokenize_bool

Parse boolean values from `StringView`:

```moonbit
///|
test "tokenize_bool examples" {
  // True values
  @json.inspect(@lexer_string.tokenize_bool("true"), content=true)
  @json.inspect(@lexer_string.tokenize_bool("True"), content=true)
  @json.inspect(@lexer_string.tokenize_bool("TRUE"), content=true)
  @json.inspect(@lexer_string.tokenize_bool("1"), content=true)

  // False values
  @json.inspect(@lexer_string.tokenize_bool("false"), content=false)
  @json.inspect(@lexer_string.tokenize_bool("False"), content=false)
  @json.inspect(@lexer_string.tokenize_bool("FALSE"), content=false)
  @json.inspect(@lexer_string.tokenize_bool("0"), content=false)
}
```

## Generic Parsing

### parse

Generic parsing function that works with any type implementing `FromStringView` and takes a `String` input:

```moonbit
///|
test "generic parse examples" {
  // Parse integers from String
  let int_val : Int = @lexer_string.tokenize("42")
  @json.inspect(int_val, content=42)

  // Parse doubles from String
  let double_val : Double = @lexer_string.tokenize("3.14")
  @json.inspect(double_val, content=3.14)

  // Parse booleans from String  
  let bool_val : Bool = @lexer_string.tokenize("true")
  @json.inspect(bool_val, content=true)

  // Parse unsigned integers from String
  let uint_val : UInt = @lexer_string.tokenize("123")
  inspect(uint_val, content="123")
}
```

## FromStringView Trait

The `FromStringView` trait enables types to be parsed from `StringView`. Built-in implementations are provided for:

- `Bool`
- `Int` 
- `Int64`
- `UInt`
- `UInt64`
- `Double`

```moonbit
///|
test "trait usage examples" {
  // Using trait methods directly
  let int_result = @lexer_string.FromStringView::tokenize("100")
  let int_val : Int = int_result
  @json.inspect(int_val, content=100)
  let bool_result = @lexer_string.FromStringView::tokenize("false")
  let bool_val : Bool = bool_result
  @json.inspect(bool_val, content=false)
  let double_result = @lexer_string.FromStringView::tokenize("2.718")
  let double_val : Double = double_result
  @json.inspect(double_val, content=2.718)
}
```

## Error Types

### StrConvError

All parsing functions can raise `StrConvError` when conversion fails:

```moonbit
///|
test "error examples" {
  // Integer parsing errors
  let int_err = try? @lexer_string.tokenize_int("abc")
  match int_err {
    Err(@lexer_string.StrConvError(msg)) =>
      @json.inspect(msg, content="invalid syntax")
    _ => @json.inspect("unexpected", content="unexpected")
  }

  // Double parsing errors  
  let double_err = try? @lexer_string.tokenize_double("not_a_number")
  match double_err {
    Err(@lexer_string.StrConvError(msg)) =>
      @json.inspect(msg, content="invalid syntax")
    _ => @json.inspect("unexpected", content="unexpected")
  }

  // Boolean parsing errors
  let bool_err = try? @lexer_string.tokenize_bool("maybe")
  match bool_err {
    Err(@lexer_string.StrConvError(msg)) =>
      @json.inspect(msg, content="invalid syntax")
    _ => @json.inspect("unexpected", content="unexpected")
  }
}
```

## Advanced Usage

### Working with StringView

```moonbit
///|
test "stringview usage" {
  let data = "123,456,789"
  let parts_array = data.split(",").to_array()

  // Parse each part individually
  let num1 = @lexer_string.tokenize_int(parts_array[0])
  let num2 = @lexer_string.tokenize_int(parts_array[1])
  let num3 = @lexer_string.tokenize_int(parts_array[2])
  inspect([num1, num2, num3], content="[123, 456, 789]")
}
```

### String vs StringView

```moonbit
///|
test "string vs stringview" {
  let original = "42"

  // Using parse with String (calls generic function)
  let from_string : Int = @lexer_string.tokenize(original)
  @json.inspect(from_string, content=42)

  // Using tokenize_int with StringView (calls specific function)
  let from_stringview = @lexer_string.tokenize_int(original)
  @json.inspect(from_stringview, content=42)

  // Both produce the same result
  @json.inspect(from_string == from_stringview, content=true)
}
```

### Base Conversion Examples

```moonbit
///|
test "base conversion showcase" {
  let binary = "11010110"
  let octal = "326"
  let decimal = "214"
  let hex = "d6"

  // All represent the same number (214 in decimal)
  @json.inspect(@lexer_string.tokenize_int(binary, base=2), content=214)
  @json.inspect(@lexer_string.tokenize_int(octal, base=8), content=214)
  @json.inspect(@lexer_string.tokenize_int(decimal, base=10), content=214)
  @json.inspect(@lexer_string.tokenize_int(hex, base=16), content=214)
}
```

### Unicode and International Numbers

```moonbit
///|
test "unicode support" {
  // Standard ASCII digits
  @json.inspect(@lexer_string.tokenize_int("12345"), content=12345)

  // Positive and negative signs
  @json.inspect(@lexer_string.tokenize_int("+123"), content=123)
  @json.inspect(@lexer_string.tokenize_int("-123"), content=-123)

  // Whitespace handling (should fail as expected)
  let whitespace_err = try? @lexer_string.tokenize_int(" 123 ")
  match whitespace_err {
    Err(@lexer_string.StrConvError(_)) => @json.inspect(true, content=true)
    _ => @json.inspect(false, content=false)
  }
}
```











































