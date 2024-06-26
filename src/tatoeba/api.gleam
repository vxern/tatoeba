import gleam/http.{type Header}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/uri.{type Uri, Uri}

/// A URL pointing to the address of the Tatoeba API.
///
pub const url = Uri(
  scheme: Some("https"),
  userinfo: None,
  host: Some("tatoeba.org"),
  port: None,
  query: None,
  path: "/eng/api_v0",
  fragment: None,
)

/// A list of headers to be included in requests sent to Tatoeba.
///
pub const headers: List(Header) = [
  #("User-Agent", "tatoeba.gleam (https://github.com/vxern/tatoeba)"),
]

/// The possible errors API calls can fail with.
///
pub type ApiError(error) {
  /// Failed to make a request to Tatoeba.
  RequestError(error)
  /// Failed to decode the response data.
  DecodeError(json.DecodeError)
}

/// Represents a function used to send a request to Tatoeba.
///
pub type RequestSender(error) =
  fn(Request(String)) -> Result(Response(String), error)

/// Creates a new request to the given endpoint.
/// 
/// This function is used over the bare `request.from_uri()` to add a step
/// to set any additional headers that we'd like to have on the request.
///
pub fn new_request_to(endpoint: String) -> Request(String) {
  let assert Ok(request) = request.from_uri(url)

  request
  |> request.set_path(request.path <> endpoint)
  |> list.fold(
    headers,
    _,
    fn(request, header) { request.set_header(request, header.0, header.1) },
  )
}
