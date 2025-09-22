# illusory0x0/lexer

A MoonBit tokenization library for parsing Token payloads from strings and bytes. This library provides efficient tokenization functionality for various data types including integers, decimals, booleans, and more, with support for multiple numeric bases and comprehensive error handling.

## Features

- **Dual Input Support**: Parse from both `StringView` and `BytesView`
- **Type-Safe Tokenization**: Parse integers, floats, booleans with proper error handling
- **Multiple Numeric Bases**: Support for binary (2), octal (8), decimal (10), hexadecimal (16), and custom bases (2-36)
- **Trait-Based API**: Generic parsing through `FromStringView` and `FromBytesView` traits
- **Comprehensive Error Handling**: Detailed error messages for parsing failures
- **Helper Functions**: Convenient utilities for common tokenization tasks

## Packages

This library consists of two main packages:

- `lexer_string`: Tokenization from `StringView` and `String`
- `lexer_bytes`: Tokenization from `BytesView` and `Bytes`

## Quick Start

### String Tokenization

```moonbit
///|
test "string tokenization basics" {
  // Parse integers with different bases
  let decimal = @lexer_string.tokenize_int("123")
  @json.inspect(decimal, content=123)
  let hex = @lexer_string.tokenize_int("0xFF", base=16)
  @json.inspect(hex, content=255)
  let binary = @lexer_string.tokenize_int("1010", base=2)
  @json.inspect(binary, content=10)

  // Parse floating point numbers
  let pi = @lexer_string.tokenize_double("3.14159")
  @json.inspect(pi, content=3.14159)

  // Parse booleans
  let flag_true = @lexer_string.tokenize_bool("true")
  @json.inspect(flag_true, content=true)
  let flag_false = @lexer_string.tokenize_bool("false")
  @json.inspect(flag_false, content=false)
}
```

### Bytes Tokenization

```moonbit
///|
test "bytes tokenization basics" {
  // Parse from byte sequences
  let number = @lexer_bytes.tokenize_int(b"456")
  @json.inspect(number, content=456)
  let hex_bytes = @lexer_bytes.tokenize_uint(b"DEADBEEF", base=16)
  @json.inspect(hex_bytes, content=3735928559)
  let float_bytes = @lexer_bytes.tokenize_double(b"2.71828")
  @json.inspect(float_bytes, content=2.71828)
}
```

### Generic Parsing with Traits

```moonbit
///|
test "generic parsing" {
  // Using FromStringView trait for generic parsing
  let int_result : Int = @lexer_string.tokenize("42")
  @json.inspect(int_result, content=42)
  let double_result : Double = @lexer_string.tokenize("3.14")
  @json.inspect(double_result, content=3.14)
  let bool_result : Bool = @lexer_string.tokenize("true")
  @json.inspect(bool_result, content=true)
}
```

## Error Handling

All tokenization functions can raise `StrConvError` for invalid input:

```moonbit
///|
test "error handling" {
  // Test invalid integer parsing
  let invalid_int = try? @lexer_string.tokenize_int("not_a_number")
  match invalid_int {
    Ok(_) =>
      @json.inspect("unexpected success", content="should not reach here")
    Err(_) => @json.inspect("Got expected error", content="Got expected error")
  }

  // Test invalid boolean parsing
  let invalid_bool = try? @lexer_string.tokenize_bool("maybe")
  match invalid_bool {
    Ok(_) =>
      @json.inspect("unexpected success", content="should not reach here")
    Err(_) =>
      @json.inspect(
        "Got expected error for bool",
        content="Got expected error for bool",
      )
  }
}
```

## Supported Data Types

### Integer Types

- `Int`: Platform-specific signed integer
- `Int64`: 64-bit signed integer  
- `UInt`: Platform-specific unsigned integer
- `UInt64`: 64-bit unsigned integer

### Floating Point Types

- `Double`: Double-precision floating point

### Boolean Type

- `Bool`: Boolean values (`true`/`false`)

## Advanced Usage

### Custom Numeric Bases

```moonbit
///|
test "custom bases" {
  // Base 36 (maximum supported base)
  let base36 = @lexer_string.tokenize_int("ZZ", base=36)
  @json.inspect(base36, content=1295) // Z=35, so ZZ = 35*36 + 35 = 1295

  // Base 8 (octal)
  let octal = @lexer_string.tokenize_int("755", base=8)
  @json.inspect(octal, content=493) // 7*64 + 5*8 + 5 = 493

  // Base 2 (binary)
  let binary = @lexer_string.tokenize_int("11111111", base=2)
  @json.inspect(binary, content=255)
}
```

### Working with Different Integer Sizes

```moonbit
///|
test "integer sizes" {
  // 64-bit integers for large numbers
  let large_num = @lexer_string.tokenize_int64("9223372036854775807")
  inspect(large_num, content="9223372036854775807")

  // Unsigned integers for positive-only values
  let unsigned = @lexer_string.tokenize_uint("4294967295")
  inspect(unsigned, content="4294967295")

  // 64-bit unsigned for very large positive numbers  
  let big_unsigned = @lexer_string.tokenize_uint64("18446744073709551615")
  inspect(big_unsigned, content="18446744073709551615")
}
```

### Trait Implementation Examples

The library provides trait implementations that allow for generic parsing:

```moonbit
///|
test "trait usage examples" {
  // Direct usage of the parse function with explicit types
  let int_token : Int = @lexer_string.tokenize("123")
  @json.inspect(int_token, content=123)
  let double_token : Double = @lexer_string.tokenize("45.67")
  @json.inspect(double_token, content=45.67)
  let bool_token : Bool = @lexer_string.tokenize("false")
  @json.inspect(bool_token, content=false)
}
```

## Token Payload Processing Helpers

This library is designed for processing token payloads in lexical analysis. Here are some common patterns:

```moonbit
///|
test "token payload processing" {
  // Helper function to safely parse token payloads
  fn safe_parse_int_token(payload : String) -> Int? {
    let result = try? @lexer_string.tokenize_int(payload)
    match result {
      Ok(value) => Some(value)
      Err(_) => None
    }
  }

  // Process various token payloads
  let tokens = ["123", "0xFF", "not_a_number", "42"]
  let parsed = Array::new()
  for token in tokens {
    match safe_parse_int_token(token) {
      Some(value) => parsed.push(value)
      None => continue
    }
  }
  @json.inspect(parsed, content=[123, 255, 42])
}
```

## API Reference

### lexer_string Package

#### Tokenization Functions

- `tokenize_int(StringView, base? : Int) -> Int`: Parse integer with optional base (default: 10)
- `tokenize_int64(StringView, base? : Int) -> Int64`: Parse 64-bit integer
- `tokenize_uint(StringView, base? : Int) -> UInt`: Parse unsigned integer  
- `tokenize_uint64(StringView, base? : Int) -> UInt64`: Parse 64-bit unsigned integer
- `tokenize_double(StringView) -> Double`: Parse floating point number
- `tokenize_bool(StringView) -> Bool`: Parse boolean value
- `parse[A : FromStringView](String) -> A`: Generic parse function

#### Traits

- `FromStringView`: Trait for types that can be parsed from `StringView`

### lexer_bytes Package

#### Tokenization Functions

- `tokenize_int(BytesView, base? : Int) -> Int`: Parse integer from bytes
- `tokenize_int64(BytesView, base? : Int) -> Int64`: Parse 64-bit integer from bytes
- `tokenize_uint(BytesView, base? : Int) -> UInt`: Parse unsigned integer from bytes
- `tokenize_uint64(BytesView, base? : Int) -> UInt64`: Parse 64-bit unsigned integer from bytes  
- `tokenize_double(BytesView) -> Double`: Parse floating point number from bytes
- `tokenize_bool(BytesView) -> Bool`: Parse boolean value from bytes
- `parse[A : FromBytesView](BytesView) -> A`: Generic parse function

#### Traits

- `FromBytesView`: Trait for types that can be parsed from `BytesView`

## License

This library is licensed under Apache-2.0.

## Acknowledgments

This library is adapted from [moonbitlang/core](https://github.com/moonbitlang/core/tree/main/strconv).