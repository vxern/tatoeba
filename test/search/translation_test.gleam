import gleam/option.{None, Some}
import gleeunit/should
import structs
import tatoeba/search/translation as translation_options

pub fn new() {
  let translation_options = translation_options.new()

  translation_options.filter_strategy |> should.equal(translation_options.Limit)
  translation_options.language |> should.equal(None)
  translation_options.link |> should.equal(None)
  translation_options.owner_id |> should.equal(None)
  translation_options.is_orphan |> should.equal(None)
  translation_options.is_unapproved |> should.equal(None)
  translation_options.has_audio |> should.equal(None)
}

pub fn set_filter_strategy() {
  let translation_options =
    translation_options.new()
    |> translation_options.set_filter_strategy(translation_options.Limit)

  translation_options.filter_strategy |> should.equal(translation_options.Limit)
}

pub fn set_language() {
  let translation_options =
    translation_options.new()
    |> translation_options.set_language("ron")

  translation_options.language |> should.equal(Some("ron"))
}

pub fn set_link() {
  let translation_options =
    translation_options.new()
    |> translation_options.set_link(translation_options.Direct)

  translation_options.link |> should.equal(Some(translation_options.Direct))
}

pub fn set_owner_id() {
  let translation_options =
    translation_options.new()
    |> translation_options.set_owner_id(5)

  translation_options.owner_id |> should.equal(Some(5))
}

pub fn set_is_orphan() {
  let translation_options =
    translation_options.new()
    |> translation_options.set_is_orphan(True)

  translation_options.link |> should.equal(Some(translation_options.Direct))
}

pub fn set_is_unapproved() {
  let translation_options =
    translation_options.new()
    |> translation_options.set_is_unapproved(True)

  translation_options.is_unapproved
  |> should.equal(Some(True))
}

pub fn set_has_audio() {
  let translation_options =
    translation_options.new()
    |> translation_options.set_has_audio(True)

  translation_options.has_audio
  |> should.equal(Some(True))
}

pub fn to_query_parameters() {
  structs.translation_options()
  |> translation_options.to_query_parameters()
  |> should.equal([
    #("trans_filter", "limit"),
    #("trans_to", "ron"),
    #("trans_link", "direct"),
    #("trans_user", "123"),
    #("trans_orphan", "yes"),
    #("trans_unapproved", "no"),
    #("trans_has_audio", "yes"),
  ])
}
