require 'spec_helper'

RSpec.describe Servant::ContextBuilder do
  subject(:builder) { described_class.new }

  let(:name) { 'Jon Snow' }

  describe '#argument' do
    subject { builder.build.new(name: name) }

    context 'required argument' do
      before do
        builder.argument(:name, presence: true)
      end

      context 'with value' do
        its(:name) { is_expected.to eq(name) }
        its(:errors) { is_expected.to be_empty }
      end

      context 'without value' do
        let(:name) { nil }

        it { expect(subject.errors[:name]).to eq(["can't be blank"]) }
      end
    end

    context 'typed argument' do
      before do
        builder.argument(:name, type: String)
      end

      context 'with string value' do
        its(:name) { is_expected.to eq(name) }
        its(:errors) { is_expected.to be_empty }
      end

      context 'with integer value' do
        let(:name) { 100 }

        it { expect(subject.errors[:name]).to eq(['must be any of these types: String']) }
      end

      context 'without value' do
        let(:name) { nil }

        its(:name) { is_expected.to be nil }
        its(:errors) { is_expected.to be_empty }
      end

      context 'when defined a few types' do
        subject { builder.build.new(attr: attr) }

        before do
          builder.argument(:attr, type: [String, Integer])
        end

        context 'with one valid type' do
          let(:attr) { 'string' }

          its(:attr) { is_expected.to eq(attr) }
          its(:errors) { is_expected.to be_empty }
        end

        context 'with second valid type' do
          let(:attr) { 1 }

          its(:attr) { is_expected.to eq(attr) }
          its(:errors) { is_expected.to be_empty }
        end

        context 'with invalid type' do
          let(:attr) { {} }

          it { expect(subject.errors[:attr]).to eq(['must be any of these types: String, Integer']) }
        end
      end
    end

    context 'coerced argument' do
      subject { builder.build.new(attr: value) }

      let(:value) { 'Some Value' }

      before do
        builder.argument(:attr, type: String, coerce: -> (v) { v.to_s })
      end

      context 'with value' do
        its(:attr) { is_expected.to eq(value) }
        its(:errors) { is_expected.to be_empty }
      end

      context 'with coerced value' do
        let(:value) { 10000 }

        its(:attr) { is_expected.to eq('10000') }
        its(:errors) { is_expected.to be_empty }
      end

      context 'without value' do
        let(:value) { nil }

        its(:attr) { is_expected.to be nil }
        its(:errors) { is_expected.to be_empty }
      end
    end

    context 'default value in argument' do
      before do
        builder.argument(:name, type: String, default: 'default', presence: true)
      end

      context 'with value' do
        its(:name) { is_expected.to eq(name) }
        its(:errors) { is_expected.to be_empty }
      end

      context 'without value' do
        let(:name) { nil }

        its(:name) { is_expected.to eq('default') }
        its(:errors) { is_expected.to be_empty }
      end

      context 'when default value is a proc' do
        before do
          builder.argument(:attr, type: String, default: -> { 'calculated default' })
        end

        context 'with value' do
          its(:attr) { is_expected.to eq('calculated default') }
          its(:errors) { is_expected.to be_empty }
        end
      end
    end
  end
end
