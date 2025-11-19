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
