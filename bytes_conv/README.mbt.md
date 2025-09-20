# bytes_conv

A MoonBit library for parsing various data types from `BytesView`, providing efficient conversion functionality for integers, decimals, booleans and other data types with support for multiple numeric bases and comprehensive error handling.

## Quick Start

```moonbit
///|
test "basic usage" {
  // Parse integers from bytes
  let num = @bytes_conv.parse_int(b"42")
  @json.inspect(num, content=42)

  // Parse with different bases
  let hex = @bytes_conv.parse_int(b"ff", base=16)
  @json.inspect(hex, content=255)

  // Parse booleans
  let flag = @bytes_conv.parse_bool(b"true")
  @json.inspect(flag, content=true)
}
```

## Error Handling

All parsing functions can raise `StrConvError` when the input cannot be parsed:

```moonbit
///|
test "error handling" {
  // Using try? to get Result type
  let result = try? @bytes_conv.parse_int(b"invalid")
  match result {
    Ok(_) =>
      @json.inspect("Should not reach here", content="Should not reach here")
    Err(@bytes_conv.StrConvError(msg)) =>
      @json.inspect(msg, content="invalid syntax")
  }

  // Handle specific errors
  let safe_result = @bytes_conv.parse_double(b"not_a_number") catch {
    @bytes_conv.StrConvError(msg) => {
      @json.inspect(msg, content="invalid syntax")
      0.0
    }
  }
  @json.inspect(safe_result, content=0.0)
}
```

## Integer Parsing

### parse_int

Parse integers from `BytesView` with optional base specification:

```moonbit
///|
test "parse_int examples" {
  // Default base 10
  @json.inspect(@bytes_conv.parse_int(b"123"), content=123)
  @json.inspect(@bytes_conv.parse_int(b"-456"), content=-456)

  // Different bases
  @json.inspect(@bytes_conv.parse_int(b"ff", base=16), content=255)
  @json.inspect(@bytes_conv.parse_int(b"1010", base=2), content=10)
  @json.inspect(@bytes_conv.parse_int(b"77", base=8), content=63)

  // Edge cases
  @json.inspect(@bytes_conv.parse_int(b"0"), content=0)
  @json.inspect(@bytes_conv.parse_int(b"+42"), content=42)
}
```

### parse_int64

Parse 64-bit integers from `BytesView`:

```moonbit
///|
test "parse_int64 examples" {
  inspect(
    @bytes_conv.parse_int64(b"9223372036854775807"),
    content="9223372036854775807",
  )
  inspect(
    @bytes_conv.parse_int64(b"-9223372036854775808"),
    content="-9223372036854775808",
  )

  // With different bases
  inspect(@bytes_conv.parse_int64(b"deadbeef", base=16), content="3735928559")
  inspect(@bytes_conv.parse_int64(b"1111000011110000", base=2), content="61680")
}
```

### parse_uint

Parse unsigned integers from `BytesView`:

```moonbit
///|
test "parse_uint examples" {
  inspect(@bytes_conv.parse_uint(b"4294967295"), content="4294967295")
  inspect(@bytes_conv.parse_uint(b"0"), content="0")

  // With different bases
  inspect(@bytes_conv.parse_uint(b"ffffffff", base=16), content="4294967295")
  inspect(@bytes_conv.parse_uint(b"377", base=8), content="255")
}
```

### parse_uint64

Parse 64-bit unsigned integers from `BytesView`:

```moonbit
///|
test "parse_uint64 examples" {
  inspect(
    @bytes_conv.parse_uint64(b"18446744073709551615"),
    content="18446744073709551615",
  )
  inspect(@bytes_conv.parse_uint64(b"0"), content="0")

  // With different bases
  inspect(
    @bytes_conv.parse_uint64(b"ffffffffffffffff", base=16),
    content="18446744073709551615",
  )
}
```

## Floating Point Parsing

### parse_double

Parse double-precision floating point numbers from `BytesView`:

```moonbit
///|
test "parse_double examples" {
  @json.inspect(@bytes_conv.parse_double(b"3.14159"), content=3.14159)
  @json.inspect(@bytes_conv.parse_double(b"-2.718"), content=-2.718)
  @json.inspect(@bytes_conv.parse_double(b"0.0"), content=0.0)

  // Scientific notation
  @json.inspect(@bytes_conv.parse_double(b"1.5e10"), content=15000000000.0)
  @json.inspect(@bytes_conv.parse_double(b"2.5e-3"), content=0.0025)

  // Special values  
  let inf_val = @bytes_conv.parse_double(b"inf")
  let neg_inf_val = @bytes_conv.parse_double(b"-inf")
  inspect(inf_val > 0.0 && inf_val.is_inf(), content="true")
  inspect(neg_inf_val < 0.0 && neg_inf_val.is_inf(), content="true")
}
```

## Boolean Parsing

### parse_bool

Parse boolean values from `BytesView`:

```moonbit
///|
test "parse_bool examples" {
  // True values
  @json.inspect(@bytes_conv.parse_bool(b"true"), content=true)
  @json.inspect(@bytes_conv.parse_bool(b"True"), content=true)
  @json.inspect(@bytes_conv.parse_bool(b"TRUE"), content=true)
  @json.inspect(@bytes_conv.parse_bool(b"1"), content=true)

  // False values
  @json.inspect(@bytes_conv.parse_bool(b"false"), content=false)
  @json.inspect(@bytes_conv.parse_bool(b"False"), content=false)
  @json.inspect(@bytes_conv.parse_bool(b"FALSE"), content=false)
  @json.inspect(@bytes_conv.parse_bool(b"0"), content=false)
}
```

## Generic Parsing

### parse

Generic parsing function that works with any type implementing `FromBytesView`:

```moonbit
///|
test "generic parse examples" {
  // Parse integers
  let int_val : Int = @bytes_conv.parse(b"42")
  @json.inspect(int_val, content=42)

  // Parse doubles
  let double_val : Double = @bytes_conv.parse(b"3.14")
  @json.inspect(double_val, content=3.14)

  // Parse booleans  
  let bool_val : Bool = @bytes_conv.parse(b"true")
  @json.inspect(bool_val, content=true)

  // Parse unsigned integers
  let uint_val : UInt = @bytes_conv.parse(b"123")
  inspect(uint_val, content="123")
}
```

## FromBytesView Trait

The `FromBytesView` trait enables types to be parsed from `BytesView`. Built-in implementations are provided for:

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
  let int_result = @bytes_conv.FromBytesView::from(b"100")
  let int_val : Int = int_result
  @json.inspect(int_val, content=100)
  let bool_result = @bytes_conv.FromBytesView::from(b"false")
  let bool_val : Bool = bool_result
  @json.inspect(bool_val, content=false)
  let double_result = @bytes_conv.FromBytesView::from(b"2.718")
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
  let int_err = try? @bytes_conv.parse_int(b"abc")
  match int_err {
    Err(@bytes_conv.StrConvError(msg)) =>
      @json.inspect(msg, content="invalid syntax")
    _ => @json.inspect("unexpected", content="unexpected")
  }

  // Double parsing errors  
  let double_err = try? @bytes_conv.parse_double(b"not_a_number")
  match double_err {
    Err(@bytes_conv.StrConvError(msg)) =>
      @json.inspect(msg, content="invalid syntax")
    _ => @json.inspect("unexpected", content="unexpected")
  }

  // Boolean parsing errors
  let bool_err = try? @bytes_conv.parse_bool(b"maybe")
  match bool_err {
    Err(@bytes_conv.StrConvError(msg)) =>
      @json.inspect(msg, content="invalid syntax")
    _ => @json.inspect("unexpected", content="unexpected")
  }
}
```

## Advanced Usage

### Working with BytesView

```moonbit
///|
test "bytesview usage" {
  // Work with individual BytesViews
  let part1 = b"123"
  let part2 = b"456"
  let part3 = b"789"

  // Parse each part individually
  let num1 = @bytes_conv.parse_int(part1)
  let num2 = @bytes_conv.parse_int(part2)
  let num3 = @bytes_conv.parse_int(part3)
  inspect([num1, num2, num3], content="[123, 456, 789]")
}
```

### Base Conversion Examples

```moonbit
///|
test "base conversion showcase" {
  let binary = b"11010110"
  let octal = b"326"
  let decimal = b"214"
  let hex = b"d6"

  // All represent the same number (214 in decimal)
  @json.inspect(@bytes_conv.parse_int(binary, base=2), content=214)
  @json.inspect(@bytes_conv.parse_int(octal, base=8), content=214)
  @json.inspect(@bytes_conv.parse_int(decimal, base=10), content=214)
  @json.inspect(@bytes_conv.parse_int(hex, base=16), content=214)
}
```
















































