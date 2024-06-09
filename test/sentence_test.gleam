import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import tatoeba/sentence

pub fn main() {
  gleeunit.main()
}

pub fn new_id_test() {
  sentence.new_id(1)
  |> should.be_ok()

  sentence.new_id(0)
  |> should.be_error()
  |> should.equal(sentence.InvalidValueError(0))

  sentence.new_id(-1)
  |> should.be_error()
  |> should.equal(sentence.InvalidValueError(-1))
}

pub fn sentence_exists_test() {
  let assert Ok(id) = sentence.new_id(12_212_258)
  let result = sentence.get(id)

  result |> should.be_ok()

  let assert Ok(sentence) = result

  sentence |> should.be_some()
}

pub fn failed_request_test() {
  // TODO: Test this.

  Nil
}

pub fn failed_decoding_test() {
  // TODO: Test this.

  Nil
}

pub fn sentence_removed_test() {
  let assert Ok(id) = sentence.new_id(4_802_955)
  let result = sentence.get(id)

  result |> should.be_ok()

  let assert Ok(sentence) = result

  should.be_none(sentence)
}

pub fn sentence_test() {
  let assert Ok(id) = sentence.new_id(12_212_258)
  let assert Ok(Some(sentence)) = sentence.get(id)

  sentence.id |> should.equal(12_212_258)
  sentence.text |> should.equal("This work is free of charge.")
  sentence.language |> should.equal(Some("eng"))
  sentence.language_tag |> should.equal("en")
  sentence.language_name |> should.equal("English")
  sentence.script |> should.equal(None)
  sentence.license |> should.equal("CC BY 2.0 FR")
  sentence.based_on_id |> should.equal(Some(5_686_783))
  sentence.correctness |> should.equal(0)
  sentence.translations
  |> should.equal([
    sentence.Translation(
      id: 5_686_783,
      text: "Această lucrare nu se plătește.",
      language: Some("ron"),
      language_tag: "ro",
      language_name: "Romanian",
      correctness: 0,
      script: None,
      transcriptions: [],
      audios: [],
    ),
  ])
  sentence.user_sentences |> should.equal(None)
  sentence.list_ids |> should.equal(None)
  sentence.transcriptions |> should.equal([])
  sentence.audios |> should.equal([])
  sentence.owner
  |> should.equal(Some(sentence.User(claimed_native: None, username: "vxern")))
  sentence.writing_direction |> should.equal(sentence.LeftToRight)
  sentence.is_favorite |> should.equal(None)
  sentence.is_owned_by_current_user |> should.equal(False)
  sentence.permissions |> should.equal(None)
  sentence.max_visible_translations |> should.equal(5)
  sentence.current_user_review |> should.equal(None)
}
