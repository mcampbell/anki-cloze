# frozen_string_literal: true

require 'open3'

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
    expect(result).to eq('{{c1::hello}} {{c2::world}} {{c3::from}} {{c4::ruby}}')
  end
end

describe 'cloze method' do
  before do
    load File.expand_path('../anki-cloze', __dir__)
  end

  it 'returns empty string when word is nil' do
    expect(cloze(nil, 1)).to eq('')
  end

  it 'returns empty string when n is nil' do
    expect(cloze('hello', nil)).to eq('')
  end

  it 'returns empty string when n is negative or zero' do
    expect(cloze('hello', -1)).to eq('')
    expect(cloze('hello', 0)).to eq('')
  end

  it 'returns a cloze when inputs are valid' do
    expect(cloze('hello', 2)).to eq('{{c2::hello}}')
  end
end

describe 'cli chunking behavior' do
  it 'outputs multiple lines for --chunks 2 with expected clozes' do
    result = run_anki_cloze('--chunks', '2', 'hello', 'world', 'from', 'ruby')
    # executable prints multiple lines; compare the full output
    expected = "{{c1::hello world}} {{c2::from ruby}}\n{{c1::hello}} {{c2::world from}} {{c3::ruby}}"
    expect(result).to eq(expected)
  end

  it 'outputs correct grouping when final chunk smaller than chunk size' do
    result = run_anki_cloze('--chunks', '3', 'one', 'two', 'three', 'four')
    expected = "{{c1::one two three}} {{c2::four}}\n{{c1::one}} {{c2::two three}} {{c3::four}}"
    expect(result).to eq(expected)
  end
end
