require 'spec_helper'

RSpec.describe Servant::Base do
  let(:service_class) do
    Class.new(Servant::Base) do
      context do
        argument :x, type: Integer, presence: true
        argument :y, type: Integer, presence: true
      end

      def perform
        halt!('Cannot divide lower value by higher') if context.y > context.x
        halt_with!(another_errors) if context.y == context.x

        context.x / context.y
      end

      private

      def another_errors
        Servant::Errors.new(self).tap do |e|
          e.add(:x, 'Some error')
          e.add(:x, 'Some another error')
          e.add(:y, 'Yet another error')
        end
      end
    end
  end

  describe '.perform' do
    subject { service_class.perform(x: 20, y: 10) }

    it { is_expected.to be_instance_of(Servant::Result) }
    its(:value) { is_expected.to eq(2) }
    its(:success?) { is_expected.to be true }

    context 'with validation error' do
      subject { service_class.perform(x: 20, y: '10') }

      it { is_expected.to be_instance_of(Servant::Result) }
      its(:value) { is_expected.to be nil }
      its(:success?) { is_expected.to be false }
      its(:errors) { is_expected.to have(1).error }
      it { expect(subject.errors[:y]).to eq(['must be any of these types: Integer'])  }
    end

    context 'with halt error' do
      subject { service_class.perform(x: 20, y: 200) }

      it { is_expected.to be_instance_of(Servant::Result) }
      its(:value) { is_expected.to be nil }
      its(:success?) { is_expected.to be false }
      its(:errors) { is_expected.to have(1).error }
      it { expect(subject.errors[:base]).to eq(['Cannot divide lower value by higher'])  }
    end

    context 'with halt errors' do
      subject { service_class.perform(x: 20, y: 20) }

      it { is_expected.to be_instance_of(Servant::Result) }
      its(:value) { is_expected.to be nil }
      its(:success?) { is_expected.to be false }
      its(:errors) { is_expected.to have(3).error }
      it { expect(subject.errors[:x]).to eq(['Some error', 'Some another error']) }
      it { expect(subject.errors[:y]).to eq(['Yet another error']) }
    end

    context 'with an exception error' do
      subject { service_class.perform(x: 20, y: 0) }

      it { expect { subject }.to raise_error(ZeroDivisionError, 'divided by 0') }
    end
  end

  describe '.perform!' do
    subject { service_class.perform!(x: 20, y: 10) }

    it { is_expected.to be_instance_of(Servant::Result) }
    its(:value) { is_expected.to eq(2) }
    its(:success?) { is_expected.to be true }

    context 'with validation error' do
      subject { service_class.perform!(x: 20, y: '10') }

      it { expect { subject }.to raise_error(Servant::Exceptions::ExecutionFailed, 'Got errors: Y must be any of these types: Integer') }
      it 'raises an exception that contains errors object' do
        begin
          subject
        rescue => ex
          expect(ex).to be_instance_of(Servant::Exceptions::ExecutionFailed)
          expect(ex.errors.to_a).to eq(['Y must be any of these types: Integer'])
        end
      end
    end

    context 'with halt error' do
      subject { service_class.perform!(x: 20, y: 200) }

      it { expect { subject }.to raise_error(Servant::Exceptions::ExecutionFailed, 'Got errors: Cannot divide lower value by higher') }
      it 'raises an exception that contains errors object' do
        begin
          subject
        rescue => ex
          expect(ex).to be_instance_of(Servant::Exceptions::ExecutionFailed)
          expect(ex.errors.to_a).to eq(['Cannot divide lower value by higher'])
        end
      end
    end

    context 'with halt errors' do
      subject { service_class.perform!(x: 20, y: 20) }

      it { expect { subject }.to raise_error(Servant::Exceptions::ExecutionFailed, 'Got errors: X Some error, X Some another error, Y Yet another error') }
      it 'raises an exception that contains errors object' do
        begin
          subject
        rescue => ex
          expect(ex).to be_instance_of(Servant::Exceptions::ExecutionFailed)
          expect(ex.errors.to_a).to eq(['X Some error', 'X Some another error', 'Y Yet another error'])
        end
      end
    end

    context 'with an exception error' do
      subject { service_class.perform!(x: 20, y: 0) }

      it { expect { subject }.to raise_error(ZeroDivisionError, 'divided by 0') }
    end
  end

  describe '.call' do
    subject { service_class.call(x: 20, y: 10) }

    it { is_expected.to eq(2) }

    context 'with validation error' do
      subject { service_class.call(x: 20, y: '10') }

      it { expect { subject }.to raise_error(Servant::Exceptions::ExecutionFailed, 'Got errors: Y must be any of these types: Integer') }
      it 'raises an exception that contains errors object' do
        begin
          subject
        rescue => ex
          expect(ex).to be_instance_of(Servant::Exceptions::ExecutionFailed)
          expect(ex.errors.to_a).to eq(['Y must be any of these types: Integer'])
        end
      end
    end

    context 'with halt error' do
      subject { service_class.call(x: 20, y: 200) }

      it { expect { subject }.to raise_error(Servant::Exceptions::ExecutionFailed, 'Got errors: Cannot divide lower value by higher') }
      it 'raises an exception that contains errors object' do
        begin
          subject
        rescue => ex
          expect(ex).to be_instance_of(Servant::Exceptions::ExecutionFailed)
          expect(ex.errors.to_a).to eq(['Cannot divide lower value by higher'])
        end
      end
    end

    context 'with halt errors' do
      subject { service_class.call(x: 20, y: 20) }

      it { expect { subject }.to raise_error(Servant::Exceptions::ExecutionFailed, 'Got errors: X Some error, X Some another error, Y Yet another error') }
      it 'raises an exception that contains errors object' do
        begin
          subject
        rescue => ex
          expect(ex).to be_instance_of(Servant::Exceptions::ExecutionFailed)
          expect(ex.errors.to_a).to eq(['X Some error', 'X Some another error', 'Y Yet another error'])
        end
      end
    end

    context 'with an exception error' do
      subject { service_class.call(x: 20, y: 0) }

      it { expect { subject }.to raise_error(ZeroDivisionError, 'divided by 0') }
    end
  end
end
