import gleam/int
import gleam/option.{type Option, None, Some}
import tatoeba/search/utils

/// Represents the strategy used in filtering Tatoeba results.
///
pub type FilterStrategy {
  /// Limit the results to the search options. (inclusive search)
  Limit
  /// Exclude the results that the search options match to. (exclusive search)
  Exclude
}

/// Converts the filter strategy to its string representation ready to encode
/// in the query.
///
pub fn filter_strategy_to_string(strategy: FilterStrategy) -> String {
  case strategy {
    Limit -> "limit"
    Exclude -> "exclude"
  }
}

/// Represents a link between the sentence and its translation.
///
pub type Link {
  /// A direct link, where a translation was created specifically for a given
  /// sentence.
  Direct
  /// An indirect link, where a translation was translated further into other
  /// languages.
  Indirect
}

/// Converts the link to its string representation ready to encode in the
/// query.
pub fn link_to_string(link: Link) -> String {
  case link {
    Direct -> "direct"
    Indirect -> "indirect"
  }
}

/// Represents a set of options used in searching for translations in the Tatoeba
/// corpus.
///
pub type TranslationOptions {
  TranslationOptions(
    /// The filter strategy applied when searching for translations.
    filter_strategy: FilterStrategy,
    /// The language of the translations.
    language: Option(String),
    /// Specifies the link between the translations and the original sentence.
    link: Option(Link),
    /// Matches against the ID of the current owner of the translation.
    owner_id: Option(Int),
    /// Matches to orphaned translations (i.e. translations without an owner).
    is_orphan: Option(Bool),
    /// Matches to translations that have not been approved.
    is_unapproved: Option(Bool),
    /// Matches to translations with audio entries.
    has_audio: Option(Bool),
  )
}

/// Creates blank translation options.
///
pub fn new() -> TranslationOptions {
  TranslationOptions(
    filter_strategy: Limit,
    language: None,
    link: None,
    owner_id: None,
    is_orphan: None,
    is_unapproved: None,
    has_audio: None,
  )
}

/// Sets the value of the `filter_strategy` field on translation options.
///
pub fn set_filter_strategy(
  options: TranslationOptions,
  filter_strategy: FilterStrategy,
) -> TranslationOptions {
  TranslationOptions(..options, filter_strategy: filter_strategy)
}

/// Sets the value of the `language` field on translation options.
///
pub fn set_language(
  options: TranslationOptions,
  language: String,
) -> TranslationOptions {
  TranslationOptions(..options, language: Some(language))
}

/// Sets the value of the `link` field on translation options.
///
pub fn set_link(options: TranslationOptions, link: Link) -> TranslationOptions {
  TranslationOptions(..options, link: Some(link))
}

/// Sets the value of the `owner_id` field on translation options.
///
pub fn set_owner_id(
  options: TranslationOptions,
  owner_id: Int,
) -> TranslationOptions {
  TranslationOptions(..options, owner_id: Some(owner_id))
}

/// Sets the value of the `is_orphan` field on translation options.
///
pub fn set_is_orphan(
  options: TranslationOptions,
  is_orphan: Bool,
) -> TranslationOptions {
  TranslationOptions(..options, is_orphan: Some(is_orphan))
}

/// Sets the value of the `is_unapproved` field on translation options.
///
pub fn set_is_unapproved(
  options: TranslationOptions,
  is_unapproved: Bool,
) -> TranslationOptions {
  TranslationOptions(..options, is_unapproved: Some(is_unapproved))
}

/// Sets the value of the `has_audio` field on translation options.
///
pub fn set_has_audio(
  options: TranslationOptions,
  has_audio: Bool,
) -> TranslationOptions {
  TranslationOptions(..options, has_audio: Some(has_audio))
}

/// Converts translation options to a set of query parameters to be encoded in the
/// search query.
///
pub fn to_query_parameters(
  options: TranslationOptions,
) -> List(#(String, String)) {
  [
    #(
      "trans_filter",
      Some(options.filter_strategy |> filter_strategy_to_string()),
    ),
    #("trans_to", options.language),
    #("trans_link", options.link |> option.map(link_to_string)),
    #("trans_user", options.owner_id |> option.map(int.to_string)),
    #("trans_orphan", options.is_orphan |> option.map(utils.bool_to_yes_no)),
    #(
      "trans_unapproved",
      options.is_unapproved |> option.map(utils.bool_to_yes_no),
    ),
    #("trans_has_audio", options.has_audio |> option.map(utils.bool_to_yes_no)),
  ]
  |> utils.select_present()
}
