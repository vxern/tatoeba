# tatoeba

## A complete, documented API wrapper for the Tatoeba corpus, built in Gleam.

[![Package Version](https://img.shields.io/hexpm/v/tatoeba)](https://hex.pm/packages/tatoeba)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/tatoeba/)

```sh
gleam add tatoeba
```

To get a sentence, use `sentence.get(id: <id>)`:

```gleam
import gleam/io
import tatoeba/sentence

pub fn main() {
  let sentence = sentence.get(id: 12212258)

  io.println(sentence.text) // "This work is free of charge."
}
```

Further documentation can be found at <https://hexdocs.pm/tatoeba>.
