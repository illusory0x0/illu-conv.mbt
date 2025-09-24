# conv_error

Common error types for the lexer packages.

## LexError

The primary error type used by lexer packages for parsing failures.

```moonbit
///|
test "lex error example" {
  // Create a LexError
  let err = @conv_error.LexError("invalid syntax")
  @json.inspect(err.to_string(), content="invalid syntax")
}
```

## Error Messages

Pre-defined error message constants:

```moonbit
///|
test "error messages" {
  @json.inspect(@conv_error.range_err_str, content="value out of range")
  @json.inspect(@conv_error.syntax_err_str, content="invalid syntax")
  @json.inspect(@conv_error.base_err_str, content="invalid base")
}
```

## Helper Functions

Functions to raise errors with standard messages:

```moonbit
///|
test "helper functions" {
  // These functions raise LexError with predefined messages
  let range_result : Result[Unit, @conv_error.LexError] = try? @conv_error.range_err()
  let syntax_result : Result[Unit, @conv_error.LexError] = try? @conv_error.syntax_err()
  let base_result : Result[Unit, @conv_error.LexError] = try? @conv_error.base_err()
  match range_result {
    Err(@conv_error.LexError(msg)) =>
      @json.inspect(msg, content="value out of range")
    _ => @json.inspect("unexpected", content="unexpected")
  }
  match syntax_result {
    Err(@conv_error.LexError(msg)) =>
      @json.inspect(msg, content="invalid syntax")
    _ => @json.inspect("unexpected", content="unexpected")
  }
  match base_result {
    Err(@conv_error.LexError(msg)) => @json.inspect(msg, content="invalid base")
    _ => @json.inspect("unexpected", content="unexpected")
  }
}
```

## Usage

This package is used internally by lexer_string and lexer_bytes packages. For end users, errors are exposed as `StrConvError` in those packages for backward compatibility.