import gleam/option.{None, Some}
import gleam/set
import gleeunit/should
import structs
import tatoeba/search/sentence as sentence_options
import utils

pub fn new_word_count_options_test() {
  let word_count_options = sentence_options.new_word_count_options()

  word_count_options.at_least |> should.equal(None)
  word_count_options.at_most |> should.equal(None)
}

pub fn set_at_least_test() {
  let word_count_options =
    sentence_options.new_word_count_options()
    |> sentence_options.set_at_least(5)

  word_count_options.at_least |> should.equal(Some(5))
}

pub fn set_at_most_test() {
  let word_count_options =
    sentence_options.new_word_count_options()
    |> sentence_options.set_at_most(10)

  word_count_options.at_most |> should.equal(Some(10))
}

pub fn word_count_options_to_query_parameters_test() {
  structs.word_count_options()
  |> sentence_options.word_count_options_to_query_parameters()
  |> utils.sort_parameters()
  |> should.equal(
    [#("word_count_min", "10"), #("word_count_max", "20")]
    |> utils.sort_parameters(),
  )
}

pub fn new_test() {
  let sentence_options = sentence_options.new()

  sentence_options.query |> should.equal(None)
  sentence_options.source_language |> should.equal(None)
  sentence_options.target_language |> should.equal(None)
  sentence_options.word_count_options
  |> should.equal(sentence_options.new_word_count_options())
  sentence_options.owner_id |> should.equal(None)
  sentence_options.is_orphan |> should.equal(None)
  sentence_options.is_unapproved |> should.equal(None)
  sentence_options.has_audio |> should.equal(None)
  sentence_options.claimed_native |> should.equal(None)
  sentence_options.tags |> should.equal(set.new())
  sentence_options.list_id |> should.equal(None)
}

pub fn set_query_test() {
  let sentence_options =
    sentence_options.new()
    |> sentence_options.set_query("drepequamvisacircation")

  sentence_options.query |> should.equal(Some("drepequamvisacircation"))
}

pub fn set_source_language_test() {
  let sentence_options =
    sentence_options.new()
    |> sentence_options.set_source_language("ron")

  sentence_options.source_language |> should.equal(Some("ron"))
}

pub fn set_target_language_test() {
  let sentence_options =
    sentence_options.new()
    |> sentence_options.set_target_language("hye")

  sentence_options.target_language |> should.equal(Some("hye"))
}

pub fn set_word_count_options_test() {
  let word_count_options =
    sentence_options.new_word_count_options()
    |> sentence_options.set_at_least(5)
  let sentence_options =
    sentence_options.new()
    |> sentence_options.set_word_count_options(word_count_options)

  sentence_options.word_count_options |> should.equal(word_count_options)
}

pub fn set_owner_id_test() {
  let sentence_options =
    sentence_options.new()
    |> sentence_options.set_owner_id(5)

  sentence_options.owner_id |> should.equal(Some(5))
}

pub fn set_is_orphan_test() {
  let sentence_options =
    sentence_options.new()
    |> sentence_options.set_is_orphan(True)

  sentence_options.is_orphan |> should.equal(Some(True))
}

pub fn set_is_unapproved_test() {
  let sentence_options =
    sentence_options.new()
    |> sentence_options.set_is_unapproved(True)

  sentence_options.is_unapproved |> should.equal(Some(True))
}

pub fn set_has_audio_test() {
  let sentence_options =
    sentence_options.new()
    |> sentence_options.set_has_audio(True)

  sentence_options.has_audio |> should.equal(Some(True))
}

pub fn set_claimed_native_test() {
  let sentence_options =
    sentence_options.new()
    |> sentence_options.set_claimed_native(True)

  sentence_options.claimed_native |> should.equal(Some(True))
}

pub fn set_tag_test() {
  let sentence_options =
    sentence_options.new()
    |> sentence_options.set_tag("Fungi")

  sentence_options.tags |> should.equal(set.from_list(["Fungi"]))
}

pub fn set_tags_test() {
  let sentence_options =
    sentence_options.new()
    |> sentence_options.set_tags(set.from_list(["Animals", "Plants"]))

  sentence_options.tags |> should.equal(set.from_list(["Animals", "Plants"]))
}

pub fn set_list_id_test() {
  let sentence_options =
    sentence_options.new()
    |> sentence_options.set_list_id(5)

  sentence_options.list_id |> should.equal(Some(5))
}

pub fn to_query_parameters_test() {
  structs.sentence_options()
  |> sentence_options.to_query_parameters()
  |> utils.sort_parameters()
  |> should.equal(
    [
      #("query", "betwixt"),
      #("from", "eng"),
      #("to", "ron"),
      #("user", "7031"),
      #("orphans", "yes"),
      #("unapproved", "no"),
      #("has_audio", "no"),
      #("native", "yes"),
      #("tags", "MyTag,YourTag,TheirTag"),
      #("list", "123"),
      #("word_count_min", "10"),
      #("word_count_max", "20"),
    ]
    |> utils.sort_parameters(),
  )
}
