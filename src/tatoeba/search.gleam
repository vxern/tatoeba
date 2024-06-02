import gleam/dynamic
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import tatoeba/api
import tatoeba/search/sentence.{type SentenceOptions} as sentence_options
import tatoeba/search/translation.{type TranslationOptions} as translation_options
import tatoeba/search/utils
import tatoeba/sentence.{type Sentence}

/// The sort strategy used to arrange sentences from the result of the search query.
///
pub type SortStrategy {
  /// Sort by relevance (closeness) to the search query.
  Relevance
  /// Place the ones that have fewer words first.
  FewestWordsFirst
  /// Place the oldest ones first.
  LastCreatedFirst
  /// Place the most recently modified ones first.
  LastModifiedFirst
  /// Order the sentences randomly.
  /// 
  /// Note: This is not the same as not sorting at all; Without having specified a
  /// sort strategy, you cannot rely on the ordering of the results, since they
  /// could be returned in any arbitrary order from Tatoeba's side. With a random
  /// sort, the results are always ensured to be returned in a deterministically
  /// random order.
  Random
}

/// Converts the sort strategy to its string representation ready to encode
/// in the query.
///
pub fn sort_strategy_to_string(strategy: SortStrategy) -> String {
  case strategy {
    Relevance -> "relevance"
    FewestWordsFirst -> "words"
    LastCreatedFirst -> "created"
    LastModifiedFirst -> "modified"
    Random -> "random"
  }
}

/// Represents a set of options used in searching for sentences and their
/// translations in the Tatoeba corpus.
///
pub type SearchOptions {
  SearchOptions(
    /// The options applied when searching for sentences.
    sentence_options: SentenceOptions,
    /// The options applied when searching for translations.
    translation_options: TranslationOptions,
    /// The sort strategy applied on the results.
    sort_strategy: Option(SortStrategy),
    /// Whether to perform the sort in reverse.
    reverse_sort: Option(Bool),
  )
}

/// Creates blank search options.
///
pub fn new() -> SearchOptions {
  SearchOptions(
    sentence_options: sentence_options.new(),
    translation_options: translation_options.new(),
    sort_strategy: None,
    reverse_sort: None,
  )
}

/// Sets the value of the `sentence_options` field on search options.
pub fn set_sentence_options(
  options: SearchOptions,
  sentence_options: SentenceOptions,
) -> SearchOptions {
  SearchOptions(..options, sentence_options: sentence_options)
}

/// Sets the value of the `translation_options` field on search options.
pub fn set_translation_options(
  options: SearchOptions,
  translation_options: TranslationOptions,
) -> SearchOptions {
  SearchOptions(..options, translation_options: translation_options)
}

/// Sets the value of the `sort_strategy` field on search options.
pub fn set_sort_strategy(
  options: SearchOptions,
  sort_strategy: SortStrategy,
) -> SearchOptions {
  SearchOptions(..options, sort_strategy: Some(sort_strategy))
}

/// Sets the value of the `reverse_sort` field on search options.
pub fn set_reverse_sort(
  options: SearchOptions,
  reverse_sort: Bool,
) -> SearchOptions {
  SearchOptions(..options, reverse_sort: Some(reverse_sort))
}

/// Converts search options to a set of query parameters to be encoded in the
/// search query.
///
pub fn to_query_parameters(options: SearchOptions) -> List(#(String, String)) {
  let parameters =
    [
      #("sort", options.sort_strategy |> option.map(sort_strategy_to_string)),
      #(
        "sort_reverse",
        options.reverse_sort |> option.map(utils.bool_to_yes_no),
      ),
    ]
    |> utils.select_present()

  list.concat([
    parameters,
    sentence_options.to_query_parameters(options.sentence_options),
    translation_options.to_query_parameters(options.translation_options),
  ])
}

/// Runs a search query using the passed `options` to filter the results.
///
pub fn run(options: SearchOptions) -> Result(List(Sentence), Nil) {
  let request =
    api.new_request_to("/search")
    |> request.set_method(http.Get)
    |> request.set_query(to_query_parameters(options))

  use response <- result.try(httpc.send(request) |> result.nil_error)
  use payload <- result.try(
    json.decode(response.body, dynamic.dynamic) |> result.nil_error,
  )

  io.debug(payload)

  Ok([])
}
