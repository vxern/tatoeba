import gleam/dynamic.{type Dynamic, string}
import gleam/result

/// Converts a stringified `Int` representation of a boolean value to a `Bool`.
///
pub fn stringified_int_bool(
  from data: Dynamic,
) -> Result(Bool, List(dynamic.DecodeError)) {
  use string <- result.try(data |> string())

  case string {
    "1" -> Ok(True)
    "0" -> Ok(False)
    string ->
      Error([
        dynamic.DecodeError(
          expected: "One of: \"1\" or \"0\"",
          found: string,
          path: [],
        ),
      ])
  }
}
