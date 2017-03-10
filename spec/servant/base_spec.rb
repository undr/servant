require 'spec_helper'

RSpec.describe Servant::Base do
  describe '.perform' do
    let(:arguments) { {} }
    let(:service) { TestService }
    let(:result) { service.perform(arguments) }

    subject { result }

    context 'servant style' do
      context 'empty arguments' do
        its(:errors) { is_expected.to have(1).errors }
        its(:value) { is_expected.to be_nil }

        it { expect(subject.errors[:attr1]).to eq(["can't be blank"]) }
      end

      context 'wrong type arguments' do
        let(:arguments) { { attr1: 123, attr2: 'xxx', attr3: [] } }

        its(:errors) { is_expected.to have(3).errors }
        its(:value) { is_expected.to be_nil }

        it { expect(subject.errors[:attr1]).to eq(['must be a type of String']) }
        it { expect(subject.errors[:attr2]).to eq(['must be a type of Integer']) }
        it { expect(subject.errors[:attr3]).to eq(['must be a type of Hash']) }
      end

      context 'with custom errors' do
        let(:arguments) { { attr1: 'error' } }

        its(:errors) { is_expected.to have(1).errors }
        its(:value) { is_expected.to eq('Value') }

        it { expect(subject.errors[:base]).to eq(['Some not critical error']) }
      end

      context 'with critical errors' do
        let(:arguments) { { attr1: 'critical' } }

        its(:errors) { is_expected.to have(1).errors }
        its(:value) { is_expected.to be_nil }

        it { expect(subject.errors[:base]).to eq(['Critical error']) }
      end

      context 'without any errors' do
        let(:arguments) { { attr1: 'some value' } }

        its(:errors) { is_expected.to have(0).errors }
        its(:value) { is_expected.to eq('Value') }
      end
    end
  end
end
