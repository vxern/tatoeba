import gleam/set
import tatoeba/search
import tatoeba/search/sentence
import tatoeba/search/translation

pub fn word_count_options() -> sentence.WordCountOptions {
  sentence.new_word_count_options()
  |> sentence.set_at_least(10)
  |> sentence.set_at_most(20)
}

pub fn sentence_options() -> sentence.SentenceOptions {
  sentence.new()
  |> sentence.set_query("betwixt")
  |> sentence.set_source_language("eng")
  |> sentence.set_target_language("ron")
  |> sentence.set_word_count_options(word_count_options())
  |> sentence.set_owner_id(7031)
  |> sentence.set_is_orphan(True)
  |> sentence.set_is_unapproved(False)
  |> sentence.set_has_audio(False)
  |> sentence.set_claimed_native(True)
  |> sentence.set_tags(["MyTag", "YourTag", "TheirTag"] |> set.from_list())
  |> sentence.set_list_id(123)
}

pub fn translation_options() -> translation.TranslationOptions {
  translation.new()
  |> translation.set_filter_strategy(translation.Limit)
  |> translation.set_language("ron")
  |> translation.set_link(translation.Direct)
  |> translation.set_owner_id(123)
  |> translation.set_is_orphan(True)
  |> translation.set_is_unapproved(False)
  |> translation.set_has_audio(True)
}

pub fn search_options() -> search.SearchOptions {
  search.new()
  |> search.set_sentence_options(sentence_options())
  |> search.set_translation_options(translation_options())
}
