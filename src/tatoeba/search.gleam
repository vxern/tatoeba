import gleam/dynamic.{type Dynamic, bool, field, int, list, optional, string}
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
import tatoeba/sentence.{type Sentence, sentence}

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

/// Checks to see whether a `Dynamic` value is a sort strategy, and returns the sort strategy
/// if it is.
///
fn sort_strategy(
  from data: Dynamic,
) -> Result(SortStrategy, List(dynamic.DecodeError)) {
  use string <- result.try(data |> string())

  case string {
    "relevance" -> Ok(Relevance)
    "words" -> Ok(FewestWordsFirst)
    "created" -> Ok(LastCreatedFirst)
    "modified" -> Ok(LastModifiedFirst)
    "random" -> Ok(Random)
    string ->
      Error([
        dynamic.DecodeError(
          expected: "One of: \"relevance\", \"words\", \"created\", \"modified\", \"random\"",
          found: string,
          path: [],
        ),
      ])
  }
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

// TODO(vxern): Document.
pub type Finder {
  // TODO(vxern): Document.
  All
}

/// Checks to see whether a `Dynamic` value is a finder, and returns the finder if it is.
///
fn finder(
  from data: dynamic.Dynamic,
) -> Result(Finder, List(dynamic.DecodeError)) {
  use string <- result.try(data |> string())

  case string {
    "all" -> Ok(All)
    string ->
      Error([dynamic.DecodeError(expected: "\"all\"", found: string, path: [])])
  }
}

/// Represents data describing how the search results are paged.
///
pub type Paging {
  Paging(
    // TODO(vxern): Document.
    finder: Finder,
    // TODO(vxern): Document.
    page: Int,
    // TODO(vxern): Document.
    current_page: Int,
    // TODO(vxern): Document.
    page_count: Int,
    // TODO(vxern): Document.
    per_page: Int,
    // TODO(vxern): Document.
    start: Int,
    // TODO(vxern): Document.
    end: Int,
    // TODO(vxern): Document.
    previous_page: Bool,
    // TODO(vxern): Document.
    next_page: Bool,
    /// The sort strategy used in the search query.
    sort_strategy: Option(SortStrategy),
    // TODO(vxern): Document.
    direction: Option(Bool),
    // TODO(vxern): Document.
    limit: Option(sentence.Unknown),
    // TODO(vxern): Document.
    sort_default: Bool,
    // TODO(vxern): Document.
    direction_default: Bool,
    // TODO(vxern): Document.
    scope: Option(sentence.Unknown),
    // TODO(vxern): Document.
    complete_sort: List(sentence.Unknown),
  )
}

/// Checks to see whether a `Dynamic` value contains paging data, and returns the
/// data if it does.
///
fn paging(from data: Dynamic) -> Result(Paging, List(dynamic.DecodeError)) {
  use finder <- result.try(data |> field("finder", finder))
  use page <- result.try(data |> field("page", int))
  use current_page <- result.try(data |> field("current", int))
  use page_count <- result.try(data |> field("count", int))
  use per_page <- result.try(data |> field("per_page", int))
  use start <- result.try(data |> field("start", int))
  use end <- result.try(data |> field("end", int))
  use previous_page <- result.try(data |> field("previous_page", bool))
  use next_page <- result.try(data |> field("next_page", bool))
  use sort_strategy <- result.try(
    data |> field("sort", optional(sort_strategy)),
  )
  use direction <- result.try(
    data |> field("direction", optional(dynamic.dynamic)),
  )
  use limit <- result.try(data |> field("limit", optional(dynamic.dynamic)))
  use sort_default <- result.try(data |> field("sort_default", bool))
  use direction_default <- result.try(data |> field("direction_default", bool))
  use scope <- result.try(data |> field("scope", optional(dynamic.dynamic)))
  use complete_sort <- result.try(
    data |> field("complete_sort", list(dynamic.dynamic)),
  )

  Paging(
    finder: finder,
    page: page,
    current_page: current_page,
    page_count: page_count,
    per_page: per_page,
    start: start,
    end: end,
    previous_page: previous_page,
    next_page: next_page,
    sort_strategy: sort_strategy,
    direction: direction,
    limit: limit,
    sort_default: sort_default,
    direction_default: direction_default,
    scope: scope,
    complete_sort: complete_sort,
  )
}

/// Represents the results of a search query run over the Tatoeba corpus.
///
pub type SearchResults {
  SearchResults(
    /// The state of paging of the results.
    paging: Paging,
    /// The sentences found as a result of the query.
    results: List(Sentence),
  )
}

/// Checks to see whether a `Dynamic` value contains search results, and returns the
/// results value if it does.
///
fn results(
  from data: Dynamic,
) -> Result(SearchResults, List(dynamic.DecodeError)) {
  use paging <- result.try(data |> field("paging", paging))
  use results <- result.try(data |> field("results", list(sentence)))

  Ok(SearchResults(paging: paging, results: results))
}

/// Runs a search query using the passed `options` to filter the results.
///
pub fn run(options: SearchOptions) -> Result(SearchResults, String) {
  let request =
    api.new_request_to("/search")
    |> request.set_method(http.Get)
    |> request.set_query(to_query_parameters(options))

  use response <- result.try(
    httpc.send(request)
    |> result.map_error(fn(_) { "Failed to send request to Tatoeba." }),
  )
  use results <- result.try(
    json.decode(response.body, results)
    |> result.map_error(fn(error) {
      "Failed to decode sentence data: "
      <> dynamic.classify(dynamic.from(error))
    }),
  )

  Ok(results)
}
