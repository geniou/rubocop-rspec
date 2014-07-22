# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::RSpec::ExampleWording do
  subject(:cop) { described_class.new }

  it 'finds description with `should` at the beginning' do
    inspect_source(cop, ["it 'should do something' do", 'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.messages)
      .to eq(['Do not use should when describing your tests.'])
    expect(cop.highlights).to eq(['should do something'])
  end

  it 'skips descriptions without `should` at the beginning' do
    inspect_source(cop, ["it 'finds no should ' \\",
                         "   'here' do",
                         'end'])
    expect(cop.offenses).to be_empty
  end

  {
    'should return something' => 'returns something',
    'should not return something' => 'does not return something',
    'should do nothing' => 'does nothing',
    'should be green' => 'is green',
    'should have sweets' => 'has sweets',
    'should worry about the future' => 'worries about the future',
    'should pay for pizza' => 'pays for pizza',
    'should miss me' => 'misses me'
  }.each do |old, new|
    it 'autocorrects an offenses' do
      new_source = autocorrect_source(cop, ["it '#{old}' do", 'end'])
      expect(new_source).to eq("it '#{new}' do\nend")
    end
  end
end
