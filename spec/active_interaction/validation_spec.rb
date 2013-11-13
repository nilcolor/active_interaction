require 'spec_helper'

describe ActiveInteraction::Validation do
  describe '.validate(filters, inputs)' do
    let(:inputs) { {} }
    let(:filter) { ActiveInteraction::Input.new(:name, {}) }
    let(:filters) { ActiveInteraction::Filters.new.add(filter) }
    let(:result) { described_class.validate(filters, inputs) }

    context 'no filters are given' do
      let(:filters) { ActiveInteraction::Filters.new }

      it 'returns no errors' do
        expect(result).to eq []
      end
    end

    context 'filter.cast returns a value' do
      let(:inputs) { {name: 1} }

      before do
        filter.stub(:cast).and_return(1)
      end

      it 'returns no errors' do
        expect(result).to eq []
      end
    end

    context 'filter throws' do
      before do
        filter.stub(:cast).and_raise(exception)
      end

      context 'InvalidValue' do
        let(:exception) { ActiveInteraction::InvalidValue }
        let(:filter) { ActiveInteraction::FloatInput.new(:name, {}) }

        it 'returns an :invalid_nested error' do
          type = I18n.translate("#{ActiveInteraction::Base.i18n_scope}.types.#{filter.class.slug.to_s}")

          expect(result).to eq [[filter.name, :invalid, nil, type: type]]
        end
      end

      context 'MissingValue' do
        let(:exception) { ActiveInteraction::MissingValue }

        it 'returns an :invalid_nested error' do
          expect(result).to eq [[filter.name, :missing]]
        end
      end
    end
  end
end