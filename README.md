# anki-cloze

`anki-cloze` is a command-line tool that helps you generate cloze deletions for Anki flashcards from plain text. It takes a series of words and outputs them in a format suitable for Anki, with different chunk sizes clozed.

## Usage

You can run `anki-cloze` from your terminal, passing the words you want to cloze as arguments.

```bash
./anki-cloze hello world from ruby
```

This will produce output similar to:

```
{{c1::hello}} {{c2::world}} {{c3::from}} {{c4::ruby}}
{{c1::hello world}} {{c2::from ruby}}
hello {{c1::world from}} ruby
```

## Options

*   `-m`, `--minimum-chunk-size N`: Specifies the minimum chunk size to emit. By default, it starts from 1. If you set this to `2`, for example, `anki-cloze` will only generate clozes for chunks of 2 words or more. (Default: `1`)
*   `-s`, `--split`: Split mode. Instead of splitting input by words, it splits a single input word by character and generates clozes for those characters without spaces.
*   `-h`, `--help`: Displays the usage information for `anki-cloze` and exits.

### Split Mode Example

```bash
./anki-cloze -s test
```

This will produce:

```
{{c1::t}}{{c2::e}}{{c3::s}}{{c4::t}}
{{c1::te}}{{c2::st}}
t{{c1::es}}t
```

By default `anki-cloze` will generate cloze deletions for all chunk sizes starting 
from 1 up to half the total number of words provided. You can adjust the minimum chunk 
size using the `-m` option.  Specifying chunk sizes larger than half the total number of words
will result in no output, as there are no valid cloze deletions for those sizes. 

## Installation

Since `anki-cloze` is a Ruby script, you can use it by cloning this repository:

```bash
git clone https://github.com/your-username/anki-cloze.git
cd anki-cloze
```

Ensure you have Ruby installed. You may also need to install the `slop` gem:

```bash
gem install slop
# or...
bundle install
```

Then you can run the script directly:

```bash
./anki-cloze your words here
```
