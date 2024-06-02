import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
import gleam/string
import tatoeba/search/utils

/// Represents a set of options for controlling:
/// - The number of words in languages with word boundaries.
/// - The number of characters in languages without word boundaries.
///
pub type WordCountOptions {
  WordCountOptions(
    /// Specifies the lowest number of words/characters to match.
    at_least: Option(Int),
    /// Specifies the highest number of words/characters to match.
    at_most: Option(Int),
  )
}

/// Creates blank length options.
///
pub fn new_word_count_options() -> WordCountOptions {
  WordCountOptions(at_least: None, at_most: None)
}

/// Sets the value of the `at_least` field on word count options.
///
pub fn set_at_least(options: WordCountOptions, count: Int) -> WordCountOptions {
  WordCountOptions(..options, at_least: Some(count))
}

/// Sets the value of the `at_most` field on word count options.
///
pub fn set_at_most(options: WordCountOptions, count: Int) -> WordCountOptions {
  WordCountOptions(..options, at_most: Some(count))
}

/// Converts word count options to a set of query parameters to be encoded in the
/// search query.
/// 
fn word_count_options_to_query_parameters(
  options: WordCountOptions,
) -> List(#(String, String)) {
  [
    #("word_count_min", options.at_least |> option.map(int.to_string)),
    #("word_count_max", options.at_most |> option.map(int.to_string)),
  ]
  |> utils.select_present()
}

/// Represents a set of options used in searching for sentences in the Tatoeba
/// corpus.
///
pub type SentenceOptions {
  SentenceOptions(
    /// The query used in searching through the corpus.
    query: Option(String),
    /// Matches against the source language of sentences.
    source_language: Option(String),
    /// Matches against the language of translations. (i.e. the target language)
    target_language: Option(String),
    /// The options used in limiting word/character lengths.
    word_count_options: WordCountOptions,
    /// The ID of the user who owns the sentence.
    owner_id: Option(Int),
    /// Matches to orphaned sentences (i.e. sentences without an owner).
    is_orphan: Option(Bool),
    /// Matches to unapproved sentences (i.e. sentences without explicit
    /// verification).
    is_unapproved: Option(Bool),
    /// Matches to sentences with audio entries.
    has_audio: Option(Bool),
    /// Matches to sentence that were submitted by a self-proclaimed native
    /// speaker.
    /// 
    /// Note: This option does not guarantee that the returned sentences will
    /// be written by native speakers. It only instructs Tatoeba to return
    /// sentences written by users who merely *claimed* they're native
    /// speakers. 
    claimed_native: Option(Bool),
    /// Matches to the tags applied onto the sentence.
    tags: Set(String),
    /// Matches to the ID of the list the sentence belongs to.
    list_id: Option(Int),
  )
}

/// Creates blank sentence options.
///
pub fn new() -> SentenceOptions {
  SentenceOptions(
    query: None,
    source_language: None,
    target_language: None,
    word_count_options: new_word_count_options(),
    owner_id: None,
    is_orphan: None,
    is_unapproved: None,
    has_audio: None,
    claimed_native: None,
    tags: set.new(),
    list_id: None,
  )
}

/// Sets the value of the `query` field on sentence options.
///
pub fn set_query(options: SentenceOptions, query: String) -> SentenceOptions {
  SentenceOptions(..options, query: Some(query))
}

/// Sets the value of the `source_language` field on sentence options.
///
pub fn set_source_language(
  options: SentenceOptions,
  source_language: String,
) -> SentenceOptions {
  SentenceOptions(..options, source_language: Some(source_language))
}

/// Sets the value of the `target_language` field on sentence options.
///
pub fn set_target_language(
  options: SentenceOptions,
  target_language: String,
) -> SentenceOptions {
  SentenceOptions(..options, target_language: Some(target_language))
}

/// Sets the value of the `word_count_options` field on sentence options.
///
pub fn set_word_count_options(
  options: SentenceOptions,
  word_count_options: WordCountOptions,
) -> SentenceOptions {
  SentenceOptions(..options, word_count_options: word_count_options)
}

/// Sets the value of the `owner_id` field on sentence options.
///
pub fn set_owner_id(options: SentenceOptions, owner_id: Int) -> SentenceOptions {
  SentenceOptions(..options, owner_id: Some(owner_id))
}

/// Sets the value of the `is_orphan` field on sentence options.
///
pub fn set_is_orphan(
  options: SentenceOptions,
  is_orphan: Bool,
) -> SentenceOptions {
  SentenceOptions(..options, is_orphan: Some(is_orphan))
}

/// Sets the value of the `is_unapproved` field on sentence options.
///
pub fn set_is_unapproved(
  options: SentenceOptions,
  is_unapproved: Bool,
) -> SentenceOptions {
  SentenceOptions(..options, is_unapproved: Some(is_unapproved))
}

/// Sets the value of the `has_audio` field on sentence options.
///
pub fn set_has_audio(
  options: SentenceOptions,
  has_audio: Bool,
) -> SentenceOptions {
  SentenceOptions(..options, has_audio: Some(has_audio))
}

/// Sets the value of the `claimed_native` field on sentence options.
///
pub fn set_claimed_native(
  options: SentenceOptions,
  claimed_native: Bool,
) -> SentenceOptions {
  SentenceOptions(..options, claimed_native: Some(claimed_native))
}

/// Sets a single value in the `tags` field on sentence options.
/// 
/// Note: Once a tag is set, setting the tag again will not have any additional
/// effect on the resulting query, since `tags` are stored as a `Set` in the
/// sentence options.
///
pub fn set_tag(options: SentenceOptions, tag: String) -> SentenceOptions {
  SentenceOptions(..options, tags: options.tags |> set.insert(tag))
}

/// Sets multiple values in the `tags` field on sentence options.
/// 
/// Note: Once a tag is set, setting the tag again by passing it in a set to this
/// function or otherwise will not have any additional effect on the resulting
/// query, since `tags` are stored as a `Set` in the sentence options.
///
pub fn set_tags(options: SentenceOptions, tags: Set(String)) -> SentenceOptions {
  set.fold(tags, options, fn(options, tag_id) { options |> set_tag(tag_id) })
}

/// Sets the value of the `list_id` field on sentence options.
///
pub fn set_list_id(options: SentenceOptions, list_id: Int) -> SentenceOptions {
  SentenceOptions(..options, list_id: Some(list_id))
}

/// Converts sentence options to a set of query parameters to be encoded in the
/// search query.
///
pub fn to_query_parameters(options: SentenceOptions) -> List(#(String, String)) {
  [
    #("query", options.query),
    #("from", options.source_language),
    #("to", options.target_language),
    #("user", options.owner_id |> option.map(int.to_string)),
    #("orphans", options.is_orphan |> option.map(utils.bool_to_yes_no)),
    #("unapproved", options.is_unapproved |> option.map(utils.bool_to_yes_no)),
    #("has_audio", options.has_audio |> option.map(utils.bool_to_yes_no)),
    #("native", options.claimed_native |> option.map(utils.bool_to_yes_no)),
    #(
      "tags",
      Some(
        options.tags
        |> set.to_list()
        |> string.join(","),
      ),
    ),
    #("list", options.list_id |> option.map(int.to_string)),
  ]
  |> utils.select_present()
  |> list.append(word_count_options_to_query_parameters(
    options.word_count_options,
  ))
}
