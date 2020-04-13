require 'spec_helper'

RSpec.describe Servant::Context do
  subject(:context_class) do
    Servant::ContextBuilder.new do
      argument :attr1, type: String
      argument :attr2, type: String, presence: true
      argument :attr3, type: String, default: 'default'
    end.build
  end

  describe '#initialize' do
    context 'when it is valid' do
      subject { context_class.new(attr1: 'attr1', attr2: 'attr2') }

      its(:errors) { is_expected.to be_empty }
      its(:attr1) { is_expected.to eq('attr1') }
      its(:attr2) { is_expected.to eq('attr2') }
      its(:attr3) { is_expected.to eq('default') }
    end

    context 'when it is invalid' do
      subject { context_class.new(attr1: 'attr1') }

      its(:errors) { is_expected.to_not be_empty }
      its(:attr1) { is_expected.to eq('attr1') }
      its(:attr2) { is_expected.to be nil }
      its(:attr3) { is_expected.to eq('default') }
    end
  end

  describe '#to_hash' do
    context 'when it is valid' do
      subject { context_class.new(attr1: 'attr1', attr2: 'attr2') }

      its(:to_hash) { is_expected.to eq(attr1: 'attr1', attr2: 'attr2', attr3: 'default') }
    end

    context 'when it is invalid' do
      subject { context_class.new(attr1: 'attr1') }

      its(:to_hash) { is_expected.to eq(attr1: 'attr1', attr2: nil, attr3: 'default') }
    end
  end
end
