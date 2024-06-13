import gleam/option.{None, Some}
import gleeunit/should
import tatoeba/search/utils

pub fn exclude_missing_test() {
  [
    #("key-with-present-value", Some("present")),
    #("key-with-missing-value", None),
  ]
  |> utils.select_present()
  |> should.equal([#("key-with-present-value", "present")])
}

pub fn bool_to_yes_no_test() {
  True |> utils.bool_to_yes_no() |> should.equal("yes")
  False |> utils.bool_to_yes_no() |> should.equal("no")
}
