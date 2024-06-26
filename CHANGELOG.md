## 0.1.0 (Work in Progress)

- Introduced two endpoint functions corresponding to the two public endpoints:
  - `sentence.get(id)` (`/sentence/:id`)
    - Gets a sentence by its ID.
  - `search.run(search_options)` (`/search`)
    - Gets a list of sentences by performing a search over the Tatoeba corpus.
- Introduced types and functions to work with them:
  - `tatoeba/search/sentence`:
    - `WordCountOptions`:
      - `new_word_count_options()`
      - `set_at_least()`
      - `set_at_most()`
      - `word_count_options_to_query_parameters()`
    - `SentenceOptions`:
      - `new()`
      - `set_query()`
      - `set_source_language()`
      - `set_target_language()`
      - `set_word_count_options()`
      - `set_owner_id()`
      - `set_is_orphan()`
      - `set_is_unapproved()`
      - `set_has_audio()`
      - `set_claimed_native()`
      - `set_tag()`
      - `set_tags()`
      - `set_list_id()`
      - `to_query_parameters()`
  - `tatoeba/search/translation`:
    - `FilterStrategy`:
      - `filter_strategy_to_string()`
    - `Link`:
      - `link_to_string()`
    - `TranslationOptions`:
      - `new()`
      - `set_filter_strategy()`
      - `set_language()`
      - `set_link()`
      - `set_owner_id()`
      - `set_is_orphan()`
      - `set_is_unapproved()`
      - `set_has_audio()`
      - `to_query_parameters()`
  - `tatoeba/search/utils`:
    - `select_present()`
    - `bool_to_yes_no()`
  - `tatoeba/api`
    - `url()`
    - `headers()`
    - `new_request_to()`
  - `tatoeba/search`
    - `SortStrategy`
      - `sort_strategy_to_string()`
    - `SearchOptions`
      - `new()`
      - `set_sentence_options()`
      - `set_translation_options()`
      - `set_sort_strategy()`
      - `set_reverse_sort()`
      - `to_query_parameters()`
      - `run()`
  - `tatoeba/sentence`
    - `Unknown`
    - `DateTime`
    - `User`
    - `TranscriptionType`
      - `transcription_type()`
    - `Transcription`
    - `Audio`
    - `Translation`
    - `WritingDirection`
    - `Permissions`
    - `Sentence`
    - `get()`