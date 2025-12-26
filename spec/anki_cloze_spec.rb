# frozen_string_literal: true

require 'open3'
load File.expand_path('../anki-cloze', __dir__)

def run_anki_cloze(*args)
  command = [File.expand_path('../anki-cloze', __dir__), *args]
  stdout, _stderr, _status = Open3.capture3(*command)
  stdout.strip
end

describe 'anki-cloze' do
  it 'handles multiple arguments' do
    result = run_anki_cloze('hello', 'world')
    expect(result).to eq('{{c1::hello}} {{c2::world}}')
  end

  it 'handles no arguments' do
    result = run_anki_cloze
    expect(result).to eq('')
  end

  it 'handles arguments with multiple spaces' do
    result = run_anki_cloze('hello   world', '  from   ruby')
    expected = "{{c1::hello}} {{c2::world}} {{c3::from}} {{c4::ruby}}\n{{c1::hello world}} {{c2::from ruby}}\nhello {{c1::world from}} ruby"
    expect(result).to eq(expected)
  end

  it 'emits the expected number of lines for 5 words' do
    result = run_anki_cloze('one', 'two', 'three', 'four', 'five')
    # For 5 words, n = ceil(5/2) = 3, total lines printed = 1 + 2 + 3 = 6
    expect(result.split("\n").length).to eq(6)
  end

  it 'handles split mode correctly' do
    result = run_anki_cloze('-s', 'test')
    # "test" -> ['t', 'e', 's', 't']
    # 4 chars. max_chunk = 4/2 = 2.
    # Chunk 1: {{c1::t}}{{c2::e}}{{c3::s}}{{c4::t}}
    # Chunk 2 (pass 1): {{c1::te}}{{c2::st}}
    # Chunk 2 (pass 2): t{{c1::es}}t
    
    expected = "{{c1::t}}{{c2::e}}{{c3::s}}{{c4::t}}\n{{c1::te}}{{c2::st}}\nt{{c1::es}}t"
    expect(result).to eq(expected)
  end

  it 'errors when multiple arguments are provided in split mode' do
    command = [File.expand_path('../anki-cloze', __dir__), '-s', 'test', 'extra']
    _stdout, stderr, status = Open3.capture3(*command)
    expect(status.exitstatus).to eq(1)
    expect(stderr).to include('Error: Split mode (-s) accepts only one argument')
  end
end

describe AnkiClozeGenerator do
  let(:generator) { AnkiClozeGenerator.new(%w[one two three four]) }

  describe '#cloze' do
    it 'returns empty string when word is nil' do
      expect(generator.send(:cloze, nil, 1)).to eq('')
    end

    it 'returns empty string when n is nil' do
      expect(generator.send(:cloze, 'hello', nil)).to eq('')
    end

    it 'returns empty string when n is negative or zero' do
      expect(generator.send(:cloze, 'hello', -1)).to eq('')
      expect(generator.send(:cloze, 'hello', 0)).to eq('')
    end

    it 'returns a cloze when inputs are valid' do
      expect(generator.send(:cloze, 'hello', 2)).to eq('{{c2::hello}}')
    end
  end

  describe '#emit_clozes_for_chunk_size' do
    it 'groups words into chunks of 2 and prints expected clozes' do
      original_stdout = $stdout
      out = StringIO.new
      $stdout = out
      lines = generator.send(:emit_clozes_for_chunk_size, 2)
      expected = "{{c1::one two}} {{c2::three four}}\none {{c1::two three}} four"
      expect(lines.join("\n")).to eq(expected)
    end
  end
end