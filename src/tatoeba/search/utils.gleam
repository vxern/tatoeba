import gleam/list
import gleam/option.{type Option, Some}

/// Given a list of pairs of keys and optional values, picks out the pairs
/// where the value is supplied.
///
pub fn select_present(
  optional_pairs: List(#(String, Option(String))),
) -> List(#(String, String)) {
  optional_pairs
  |> list.fold([], fn(list, pair) {
    case pair {
      #(key, Some(value)) -> list |> list.prepend(#(key, value))
      _ -> list
    }
  })
}

/// Converts a `Bool` to the Tatoeba representation of literal 'yes' and 'no'.
///
pub fn bool_to_yes_no(bool: Bool) -> String {
  case bool {
    True -> "yes"
    False -> "no"
  }
}
