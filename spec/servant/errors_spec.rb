require 'spec_helper'

RSpec.describe Servant::Errors do
  subject do
    described_class.new(Servant::Context.new({})).tap do |e|
      e.add(:field, 'Some field error')
      e.add(:base, 'Some base error')
      e.add(:base, 'Some another base error')
    end
  end

  describe '#freeze' do
    before { subject.freeze }

    it 'is locked for changes' do
      expect { subject.add(:field, 'Some another field error') }.to raise_error(FrozenError)
      expect { subject.add(:unknown_field, 'Some another field error') }.to raise_error(NoMethodError)
    end

    it 'is opened for reading' do
      expect(subject[:base]).to eq(['Some base error', 'Some another base error'])
      expect(subject[:field]).to eq(['Some field error'])
      expect(subject[:unknown_field]).to be nil
    end
  end
end
