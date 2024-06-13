import gleam/list
import gleam/order
import gleam/string

pub fn sort_parameters(parameters: List(#(String, String))) {
  parameters
  |> list.sort(fn(a, b) {
    order.compare(string.compare(a.0, b.0), string.compare(a.1, b.1))
  })
}
