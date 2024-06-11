import gleam/dynamic.{
  type Dynamic, bool, field, int, list, optional, optional_field, string,
}
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import tatoeba/api
import tatoeba/utils

/// Represents values of a yet undocumented type.
///
pub type Unknown {
  Unknown
}

/// Represents a timestamp.
/// 
/// Gleam does not currently have a standard interface for timestamps,
/// and the presence of a single date value did not warrant adding a
/// date-time library, but it was still a good idea to indicate that the
/// `String` contains a timestamp, and not just any random text.
/// 
type DateTime =
  String

/// Represents a user of the Tatoeba corpus.
///
pub type User {
  User(
    /// Whether the user claims to be a native speaker.
    claimed_native: Option(Bool),
    /// The user's username.
    username: String,
  )
}

/// Checks to see whether a `Dynamic` value is a user, and returns the user if
/// it is.
///
fn user(from data: Dynamic) -> Result(User, List(dynamic.DecodeError)) {
  use claimed_native <- result.try(
    data |> optional_field("is_native", utils.stringified_int_bool),
  )
  use username <- result.try(data |> field("username", string))

  Ok(User(claimed_native: claimed_native, username: username))
}

/// Represents the type of transcription.
///
pub type TranscriptionType {
  /// A transcription from one script to another.
  ForeignTranscription
  /// A transcription to an alternative script within the same language.
  AlternativeScript
}

// TODO(vxern): Document.
pub fn transcription_type(
  from data: Dynamic,
) -> Result(TranscriptionType, List(dynamic.DecodeError)) {
  use string <- result.try(data |> string())

  case string {
    "transcription" -> Ok(ForeignTranscription)
    "altscript" -> Ok(AlternativeScript)
    string ->
      Error([
        dynamic.DecodeError(
          expected: "One of: \"transcription\", \"altscript\"",
          found: string,
          path: [],
        ),
      ])
  }
}

/// Represents a transcription provided to a sentence or translation in the
/// Tatoeba corpus.
///
pub type Transcription {
  Transcription(
    /// The ID of the transcription.
    id: Int,
    /// The contents of the transcription.
    text: String,
    /// The ID of the sentence (or translation) the transcription is attached
    /// to.
    sentence_id: Int,
    /// The script the transcription is written in.
    script: Option(String),
    /// The type of the transcription.
    transcription_type: TranscriptionType,
    /// The timestamp of when the transcription was last modified.
    last_modified: DateTime,
    /// The ID of the current owner of this transcription.
    owner_id: Option(Int),
    /// The current owner of this transcription.
    owner: Option(User),
    /// The HTML representation of the transcription.
    html: String,
    /// The markup representation of the transcription.
    markup: Option(String),
    /// A helpful informational message shown alongside the transcription.
    info_message: String,
    /// Indicates whether the transcription is read-only.
    is_readonly: Bool,
    /// Indicates whether the transcription needs a review.
    needs_review: Bool,
  )
}

/// Checks to see whether a `Dynamic` value is a transcription, and returns the
/// transcription if it is.
///
fn transcription(
  from data: Dynamic,
) -> Result(Transcription, List(dynamic.DecodeError)) {
  use id <- result.try(data |> field("id", int))
  use text <- result.try(data |> field("text", string))
  use sentence_id <- result.try(data |> field("sentence_id", int))
  use script <- result.try(data |> field("script", optional(string)))
  use transcription_type <- result.try(
    data |> field("type", transcription_type),
  )
  use last_modified <- result.try(data |> field("modified", string))
  use owner_id <- result.try(data |> field("user_id", optional(int)))
  use owner <- result.try(data |> field("user", optional(user)))
  use html <- result.try(data |> field("html", string))
  use markup <- result.try(data |> field("markup", optional(string)))
  use info_message <- result.try(data |> field("info_message", string))
  use is_readonly <- result.try(data |> field("readonly", bool))
  use needs_review <- result.try(data |> field("needsReview", bool))

  Ok(Transcription(
    id: id,
    text: text,
    sentence_id: sentence_id,
    script: script,
    transcription_type: transcription_type,
    last_modified: last_modified,
    owner_id: owner_id,
    owner: owner,
    html: html,
    markup: markup,
    info_message: info_message,
    is_readonly: is_readonly,
    needs_review: needs_review,
  ))
}

/// Represents an audio entry for a sentence.
///
pub type Audio {
  Audio(
    /// The ID of the audio entry.
    id: Int,
    /// Indicates whether the audio entry comes from an external source.
    is_external: Option(Bool),
    /// The username of the author of this audio entry.
    author: Option(String),
    /// A URL pointing to the original source or author of the audio.
    attribution_url: Option(String),
    /// The license the audio entry is licensed under.
    license: Option(String),
  )
}

/// Checks to see whether a `Dynamic` value contains an audio entry, and returns the
/// audio entry if it is.
///
fn audio(from data: Dynamic) -> Result(Audio, List(dynamic.DecodeError)) {
  use id <- result.try(data |> field("id", int))
  use is_external <- result.try(
    data |> optional_field("external", optional(bool)),
  )
  use author <- result.try(data |> field("author", optional(string)))
  use attribution_url <- result.try(
    data |> field("attribution_url", optional(string)),
  )
  use license <- result.try(data |> field("license", optional(string)))

  Ok(Audio(
    id: id,
    is_external: is_external |> option.unwrap(None),
    author: author,
    attribution_url: attribution_url,
    license: license,
  ))
}

/// Represents a translation of a sentence in the Tatoeba corpus.
/// 
/// Note: A translation is, in essence, no different to a standalone sentence, and
/// the notion of a 'translation' as a separate entity is solely a semantic aid.
///
pub type Translation {
  Translation(
    /// The ID of the translation.
    id: Int,
    /// The contents of the translation.
    text: String,
    /// The ISO-639-3 code of the language the translation is written in.
    /// 
    /// This value is `None` in the case that a translation is written in a language
    /// that Tatoeba has not yet added support for, or one that simply hasn't been
    /// marked with any language in particular.
    language: Option(String),
    /// The BCP 47 tag of the language the translation is written in.
    language_tag: String,
    /// The full name of the language the translation is written in.
    language_name: String,
    /// Whether the translation has been created for a standalone sentence, i.e. not
    /// a translation of a translation.
    is_direct: Option(Bool),
    /// The direction of writing in the sentence.
    writing_direction: WritingDirection,
    /// Represents how reliable the translation is.
    /// 
    /// Note: This value is reported by Tatoeba as not currently being in use. 
    correctness: Int,
    /// The script the translation is written in.
    script: Option(String),
    /// A list of `Transcription`s of the translation.
    transcriptions: List(Transcription),
    /// A list of `Audio`s attached to the translation.
    audios: List(Audio),
  )
}

/// Checks to see whether a `Dynamic` value is a translation, and returns the
/// translation if it is.
///
fn translation(
  from data: Dynamic,
) -> Result(Translation, List(dynamic.DecodeError)) {
  use id <- result.try(data |> field("id", int))
  use text <- result.try(data |> field("text", string))
  use language <- result.try(data |> field("lang", optional(string)))
  use language_tag <- result.try(data |> field("lang_tag", string))
  use language_name <- result.try(data |> field("lang_name", string))
  use is_direct <- result.try(data |> optional_field("isDirect", bool))
  use writing_direction <- result.try(data |> field("dir", writing_direction))
  use correctness <- result.try(data |> field("correctness", int))
  use script <- result.try(data |> field("script", optional(string)))
  use transcriptions <- result.try(
    data |> field("transcriptions", list(transcription)),
  )
  use audios <- result.try(data |> field("audios", list(audio)))

  Ok(Translation(
    id: id,
    text: text,
    language: language,
    language_tag: language_tag,
    language_name: language_name,
    is_direct: is_direct,
    writing_direction: writing_direction,
    correctness: correctness,
    script: script,
    transcriptions: transcriptions,
    audios: audios,
  ))
}

fn translations(
  from data: Dynamic,
) -> Result(List(Translation), List(dynamic.DecodeError)) {
  use translations_raw <- result.try(data |> list(list(translation)))

  case translations_raw {
    [translations, ..] -> Ok(translations)
    _ ->
      Error([
        dynamic.DecodeError(
          expected: "An array of translations.",
          found: "No element.",
          path: [],
        ),
      ])
  }
}

/// The direction of writing in a given sentence.
///
pub type WritingDirection {
  /// The sentence is written from left to right.
  LeftToRight
  /// The sentence is written from right to left.
  RightToLeft
  /// The sentence is written in a direction inferred from the language used.
  Auto
}

/// Checks to see whether a `Dynamic` value is a writing direction, and returns
/// the writing direction if it is.
///
fn writing_direction(
  from data: Dynamic,
) -> Result(WritingDirection, List(dynamic.DecodeError)) {
  use direction <- result.try(data |> string())

  case direction {
    "ltr" -> Ok(LeftToRight)
    "rtl" -> Ok(RightToLeft)
    "auto" -> Ok(Auto)
    _ ->
      Error([
        dynamic.DecodeError(
          expected: "One of: \"ltr\", \"rtl\" or \"auto\"",
          found: direction,
          path: [],
        ),
      ])
  }
}

/// Represents a set of permissions the user has in regards to a given sentence.
///
pub type Permissions {
  Permissions(
    /// Indicates whether the current user can edit the sentence.
    can_edit: Bool,
    /// Indicates whether the current user can transcribe the sentence.
    /// 
    /// Transcription refers to rewriting the same sentence in a different script.
    can_transcribe: Bool,
    /// Indicates whether the current user can review the sentence.
    can_review: Bool,
    /// Indicates whether the current user can adopt the sentence.
    can_adopt: Bool,
    /// Indicates whether the current user can delete the sentence.
    can_delete: Bool,
    /// Indicates whether the current user can link the sentence.
    can_link: Bool,
  )
}

/// Checks to see whether a `Dynamic` value contains permissions, and returns the
/// permissions if it is.
///
fn permissions(
  from data: Dynamic,
) -> Result(Permissions, List(dynamic.DecodeError)) {
  use can_edit <- result.try(data |> field("canEdit", bool))
  use can_transcribe <- result.try(data |> field("canTranscribe", bool))
  use can_review <- result.try(data |> field("canReview", bool))
  use can_adopt <- result.try(data |> field("canAdopt", bool))
  use can_delete <- result.try(data |> field("canDelete", bool))
  use can_link <- result.try(data |> field("canLink", bool))

  Ok(Permissions(
    can_edit: can_edit,
    can_transcribe: can_transcribe,
    can_review: can_review,
    can_adopt: can_adopt,
    can_delete: can_delete,
    can_link: can_link,
  ))
}

/// Represents a sentence from the Tatoeba corpus.
/// 
/// Note: There is no very strong distinction between a 'sentence' and its
/// 'translation', and it should be noted that a `Sentence` value can be
/// an original sentence just as well as it can be a translation of another
/// sentence. 
///
pub type Sentence {
  Sentence(
    /// The ID of the sentence.
    id: Int,
    /// The contents of the sentence.
    text: String,
    /// The ISO-639-3 code of the language the sentence is written in.
    /// 
    /// This value is `None` in the case that a sentence is written in a language
    /// that Tatoeba has not yet added support for, or one that simply hasn't been
    /// marked with any language in particular.
    language: Option(String),
    /// The BCP 47 tag of the language the sentence is written in.
    language_tag: String,
    /// The full name of the language the sentence is written in.
    language_name: String,
    /// The script the sentence is written in.
    script: Option(String),
    /// The license the sentence is available under.
    license: String,
    /// The ID of the sentence the sentence is translated from.
    /// 
    /// A value of `None` represents an unknown status.
    /// 
    /// `Some(0)` indicates the sentence is original.
    based_on_id: Option(Int),
    // If viewing a translation, the sentence the translation was based on.
    // base: Option(Sentence),
    /// Represents how reliable the sentence is.
    /// 
    /// Note: This value is reported by Tatoeba as not currently being in use. 
    correctness: Int,
    /// A list of `Translation`s of the sentence.
    translations: List(Translation),
    // TODO(vxern): What does this value represent?
    /// Note: This value will always be `None` given that this API wrapper does not
    /// act as a user.
    user_sentences: Option(List(Unknown)),
    /// The IDs of the lists this sentence belongs to.
    /// 
    /// Note: This value will always be `None` given that this API wrapper does not
    /// act as a user.
    list_ids: Option(List(Int)),
    /// A list of `Transcription`s of the sentence.
    transcriptions: List(Transcription),
    /// A list of `Audio`s attached to the sentence.
    audios: List(Audio),
    /// The current owner of the sentence.
    /// 
    /// This value can be `None` in the case that a user is suspended or otherwise.
    owner: Option(User),
    /// The direction of writing in the sentence.
    writing_direction: WritingDirection,
    /// Indicates whether the sentence is favorited by the current user.
    /// 
    /// Note: This value will always be `None` given that this API wrapper does not
    /// act as a user.
    is_favorite: Option(Bool),
    /// Indicates whether the sentence is owned by the current user.
    /// 
    /// Note: This value will always be `False` given that this API wrapper does not
    /// act as a user.
    is_owned_by_current_user: Bool,
    /// Indicates what permissions a user has in the context of the sentence.
    /// 
    /// Note: This value will always be `None` given that this API wrapper does not
    /// act as a user.
    permissions: Option(Permissions),
    /// Indicates how many translations are shown by default on the sentence.
    /// 
    /// Note: This value is only relevant as a reflection of what is shown on the
    /// website.
    max_visible_translations: Int,
    /// The current user's review of the sentence.
    /// 
    /// Note: This value will always be `None` given that this API wrapped does not
    /// act as a user.
    current_user_review: Option(Unknown),
  )
}

/// Checks to see whether a `Dynamic` value is a user sentence, and returns the user
/// sentence if it is.
///
fn user_sentence(from _: Dynamic) -> Result(Unknown, List(dynamic.DecodeError)) {
  Ok(Unknown)
}

/// Checks to see whether a `Dynamic` value contains a sentence list ID, and returns
/// the sentence if it is.
///
fn list_id(from data: Dynamic) -> Result(Int, List(dynamic.DecodeError)) {
  use id <- result.try(data |> field("id", int))

  Ok(id)
}

/// Checks to see whether a `Dynamic` value is a sentence, and returns the sentence
/// if it is.
///
pub fn sentence(
  from data: Dynamic,
) -> Result(Sentence, List(dynamic.DecodeError)) {
  use id <- result.try(data |> field("id", int))
  use text <- result.try(data |> field("text", string))
  use language <- result.try(data |> field("lang", optional(string)))
  use language_tag <- result.try(data |> field("lang_tag", string))
  use language_name <- result.try(data |> field("lang_name", string))
  use script <- result.try(data |> field("script", optional(string)))
  use license <- result.try(data |> field("license", string))
  use based_on_id <- result.try(
    data |> optional_field("based_on_id", optional(int)),
  )
  // use base <- result.try(data |> field("base", optional(sentence)))
  use correctness <- result.try(data |> field("correctness", int))
  use translations <- result.try(data |> field("translations", translations))
  use user_sentences <- result.try(
    data |> optional_field("users_sentences", list(user_sentence)),
  )
  use list_ids <- result.try(
    data |> optional_field("sentences_lists", list(list_id)),
  )
  use transcriptions <- result.try(
    data |> field("transcriptions", list(transcription)),
  )
  use audios <- result.try(data |> field("audios", list(audio)))
  use owner <- result.try(data |> field("user", optional(user)))
  use writing_direction <- result.try(data |> field("dir", writing_direction))
  use is_favorite <- result.try(data |> field("is_favorite", optional(bool)))
  use is_owned_by_current_user <- result.try(
    data |> field("is_owned_by_current_user", bool),
  )
  use permissions <- result.try(
    data |> field("permissions", optional(permissions)),
  )
  use max_visible_translations <- result.try(
    data |> field("max_visible_translations", int),
  )
  use current_user_review <- result.try(
    data |> field("current_user_review", optional(fn(_) { Ok(Unknown) })),
  )

  Ok(Sentence(
    id: id,
    text: text,
    language: language,
    language_tag: language_tag,
    language_name: language_name,
    script: script,
    license: license,
    based_on_id: based_on_id |> option.flatten(),
    // base: base,
    correctness: correctness,
    translations: translations,
    user_sentences: user_sentences,
    list_ids: list_ids,
    transcriptions: transcriptions,
    audios: audios,
    owner: owner,
    writing_direction: writing_direction,
    is_favorite: is_favorite,
    is_owned_by_current_user: is_owned_by_current_user,
    permissions: permissions,
    max_visible_translations: max_visible_translations,
    current_user_review: current_user_review,
  ))
}

/// Represents the ID of a sentence in the Tatoeba corpus.
///
pub opaque type SentenceId {
  SentenceId(value: Int)
}

/// Represents an error resulting from an invalid value being used for
/// creating an ID.
///
pub type IdError {
  /// Received an invalid input.
  InvalidValueError(Int)
}

/// Creates a new ID to be used for querying the Tatoeba corpus.
///
pub fn new_id(id: Int) -> Result(SentenceId, IdError) {
  case id {
    negative if id < 0 || id == 0 -> Error(InvalidValueError(negative))
    _ -> Ok(SentenceId(id))
  }
}

/// Gets data of a single sentence in the Tatoeba corpus.
///
pub fn get(id id: SentenceId) -> Result(Option(Sentence), api.ApiError) {
  let request =
    api.new_request_to("/sentence/" <> int.to_string(id.value))
    |> request.set_method(http.Get)

  use response <- result.try(
    httpc.send(request)
    |> result.map_error(fn(error) { api.RequestError(error) }),
  )

  case response.body |> string.length() {
    0 -> Ok(None)
    _ -> response.body |> decode_payload() |> result.map(Some)
  }
}

/// Decodes the received sentence payload.
///
fn decode_payload(payload: String) -> Result(Sentence, api.ApiError) {
  use sentence <- result.try(
    json.decode(payload, sentence)
    |> result.map_error(fn(error) { api.DecodeError(error) }),
  )

  Ok(sentence)
}
