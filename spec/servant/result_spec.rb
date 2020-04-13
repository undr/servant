require 'spec_helper'

RSpec.describe Servant::Result do
  subject { described_class.new(errors, value) }

  let(:errors) { Servant::Errors.new(nil) }
  let(:value) { nil }

  context 'successful' do
    let(:value) { 'value' }

    its(:success?) { is_expected.to be true }
    its(:failed?) { is_expected.to be false }
  end

  context 'failed' do
    before do
      errors.add(:base, 'Some error')
    end

    its(:success?) { is_expected.to be false }
    its(:failed?) { is_expected.to be true }
  end

  context 'without result' do
    subject { described_class.new(errors) }

    its(:value) { is_expected.to be nil }
  end
end
