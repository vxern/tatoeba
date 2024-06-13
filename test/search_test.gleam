import gleam/list
import gleam/option.{None, Some}
import gleeunit/should
import structs
import tatoeba/search
import tatoeba/search/sentence
import tatoeba/search/translation

pub fn sort_strategy_to_string_test() {
  [
    search.Relevance,
    search.FewestWordsFirst,
    search.LastCreatedFirst,
    search.LastModifiedFirst,
    search.Random,
  ]
  |> list.map(search.sort_strategy_to_string)
  |> should.equal(["relevance", "words", "created", "modified", "random"])
}

pub fn new_test() {
  let search = search.new()

  search.sentence_options |> should.equal(sentence.new())
  search.translation_options |> should.equal(translation.new())
  search.sort_strategy |> should.equal(None)
  search.reverse_sort |> should.equal(None)
}

pub fn set_sentence_options_test() {
  let sentence_options =
    sentence.new()
    // Eastern Armenian
    |> sentence.set_source_language("hye")
  let search =
    search.new()
    |> search.set_sentence_options(sentence_options)

  search.sentence_options |> should.equal(sentence_options)
}

pub fn set_translation_options_test() {
  let translation_options =
    translation.new()
    // Romanian
    |> translation.set_language("ron")
  let search =
    search.new()
    |> search.set_translation_options(translation_options)

  search.translation_options |> should.equal(translation_options)
}

pub fn set_sort_strategy_test() {
  let search = search.new() |> search.set_sort_strategy(search.Relevance)

  search.sort_strategy |> should.equal(Some(search.Relevance))
}

pub fn set_reverse_sort_test() {
  let search = search.new() |> search.set_reverse_sort(True)

  search.reverse_sort |> should.equal(Some(True))
}

pub fn to_query_parameters_test() {
  structs.search_options()
  |> search.to_query_parameters()

  todo
}

pub fn run_test() {
  todo
}
