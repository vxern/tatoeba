import gleam/dynamic
import gleeunit/should
import tatoeba/utils

pub fn stringified_int_bool_test() {
  utils.stringified_int_bool(dynamic.from("1"))
  |> should.equal(Ok(True))

  utils.stringified_int_bool(dynamic.from("0"))
  |> should.equal(Ok(False))

  utils.stringified_int_bool(dynamic.from("invalid"))
  |> should.equal(
    Error([dynamic.DecodeError("One of: \"1\" or \"0\"", "invalid", [])]),
  )
}
