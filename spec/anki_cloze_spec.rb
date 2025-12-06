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

describe 'emit_clozes' do
  before do
    load File.expand_path('../anki-cloze', __dir__)
  end

  it 'groups words into chunks of 2 and prints expected clozes' do
    original_stdout = $stdout
    out = StringIO.new
    $stdout = out
    begin
      emit_clozes(2, %w[one two three four])
    ensure
      $stdout = original_stdout
    end

    expected = "{{c1::one two}} {{c2::three four}}\none {{c2::two three}} four"
    expect(out.string.strip).to eq(expected)
  end
end
