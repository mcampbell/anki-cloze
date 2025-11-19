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

  it 'groups words into chunks when --chunks is provided' do
    result = run_anki_cloze('--chunks', '2', 'hello', 'world', 'from', 'ruby')
    expect(result).to eq('{{c1::hello world}} {{c2::from ruby}}')
  end

  it 'leaves a final smaller chunk as-is' do
    result = run_anki_cloze('--chunks', '3', 'one', 'two', 'three', 'four')
    expect(result).to eq('{{c1::one two three}} {{c2::four}}')
  end
end
