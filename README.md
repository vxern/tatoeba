# tatoeba

## A complete, documented API wrapper for the Tatoeba corpus, built in Gleam.

[![Package Version](https://img.shields.io/hexpm/v/tatoeba)](https://hex.pm/packages/tatoeba)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/tatoeba/)

```sh
gleam add tatoeba
```

To get a sentence, use `sentence.get(id: <sentence id>)`, passing a sentence ID obtained from `sentence.new_id(id: <id>)`:

```gleam
import gleam/io
import tatoeba/sentence

pub fn main() {
  let assert Ok(id) = sentence.new_id(12_212_258)
  let assert Ok(Some(sentence)) = sentence.get(id)

  io.println(sentence.text) // "This work is free of charge."
}
```

Further documentation can be found at <https://hexdocs.pm/tatoeba>.
