import gleam/httpc
import gleam/list
import gleam/option.{None, Some}
import gleeunit/should
import tatoeba/sentence

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
  let result = sentence.get(id, using: httpc.send)

  result |> should.be_ok()

  let assert Ok(sentence) = result

  sentence |> should.be_some()
}

pub fn failed_request_test() {
  todo
}

pub fn failed_decoding_test() {
  todo
}

pub fn sentence_removed_test() {
  let assert Ok(id) = sentence.new_id(4_802_955)
  let result = sentence.get(id, using: httpc.send)

  result |> should.be_ok()

  let assert Ok(sentence) = result

  should.be_none(sentence)
}

pub fn sentence_get_test() {
  let assert Ok(id) = sentence.new_id(1)
  let assert Ok(Some(sentence)) = sentence.get(id, using: httpc.send)

  sentence.id |> should.equal(1)
  sentence.text |> should.equal("我們試試看！")
  sentence.language |> should.equal(Some("cmn"))
  sentence.language_tag |> should.equal("zh-Hant")
  sentence.language_name |> should.equal("Mandarin Chinese")
  sentence.script |> should.equal(Some("Hant"))
  sentence.license |> should.equal("CC BY 2.0 FR")
  sentence.based_on_id |> should.equal(None)
  sentence.correctness |> should.equal(0)
  sentence.translations
  |> list.take(5)
  |> should.equal([
    sentence.Translation(
      id: 433_979,
      text: "لنحاول !",
      language: Some("ara"),
      language_tag: "ar",
      language_name: "Arabic",
      is_direct: Some(True),
      writing_direction: sentence.RightToLeft,
      correctness: 0,
      script: None,
      transcriptions: [],
      audios: [],
    ),
    sentence.Translation(
      id: 2_608_341,
      text: "আমরা একবার চেষ্টা করেই দেখি!",
      language: Some("ben"),
      language_tag: "bn",
      language_name: "Bengali",
      is_direct: Some(True),
      writing_direction: sentence.LeftToRight,
      correctness: 0,
      script: None,
      transcriptions: [],
      audios: [],
    ),
    sentence.Translation(
      id: 2_604_674,
      text: "Ad neɛreḍ!",
      language: Some("ber"),
      language_tag: "ber",
      language_name: "Berber",
      is_direct: Some(True),
      writing_direction: sentence.LeftToRight,
      correctness: 0,
      script: None,
      transcriptions: [],
      audios: [],
    ),
    sentence.Translation(
      id: 760_627,
      text: "Да пробваме!",
      language: Some("bul"),
      language_tag: "bg",
      language_name: "Bulgarian",
      is_direct: Some(True),
      writing_direction: sentence.LeftToRight,
      correctness: 0,
      script: None,
      transcriptions: [],
      audios: [],
    ),
    sentence.Translation(
      id: 826_600,
      text: "Versuchen wir's!",
      language: Some("deu"),
      language_tag: "de",
      language_name: "German",
      is_direct: Some(True),
      writing_direction: sentence.LeftToRight,
      correctness: 0,
      script: None,
      transcriptions: [],
      audios: [
        sentence.Audio(
          id: 497_098,
          is_external: None,
          author: Some("quicksanddiver"),
          attribution_url: Some("/en/user/profile/quicksanddiver"),
          license: Some(""),
        ),
      ],
    ),
  ])
  sentence.user_sentences |> should.equal(None)
  sentence.list_ids |> should.equal(None)
  sentence.transcriptions
  |> should.equal([
    sentence.Transcription(
      id: 1_991_078,
      text: "我们试试看！",
      sentence_id: 1,
      script: Some("Hans"),
      transcription_type: sentence.AlternativeScript,
      last_modified: "2020-05-13T15:11:29+00:00",
      owner_id: None,
      owner: None,
      html: "我们试试看！",
      markup: None,
      info_message: "This alternative script was generated automatically.",
      is_readonly: True,
      needs_review: False,
    ),
    sentence.Transcription(
      id: 1_554_809,
      text: "Wo3men5 shi4shi5 kan4!",
      sentence_id: 1,
      script: Some("Latn"),
      transcription_type: sentence.ForeignTranscription,
      last_modified: "2019-10-18T19:16:22+00:00",
      owner_id: Some(81_071),
      owner: Some(sentence.User(claimed_native: None, username: "Yorwba")),
      html: "Wǒmen sh&igrave;shi k&agrave;n!",
      markup: None,
      info_message: "Last edited by Yorwba on October 18, 2019 at 7:16:22 PM UTC",
      is_readonly: False,
      needs_review: False,
    ),
  ])
  sentence.audios |> should.equal([])
  sentence.owner
  |> should.equal(Some(sentence.User(claimed_native: None, username: "sysko")))
  sentence.writing_direction |> should.equal(sentence.LeftToRight)
  sentence.is_favorite |> should.equal(None)
  sentence.is_owned_by_current_user |> should.equal(False)
  sentence.permissions |> should.equal(None)
  sentence.max_visible_translations |> should.equal(5)
  sentence.current_user_review |> should.equal(None)
}
