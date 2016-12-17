require 'spec_helper'

module Codebreaker
  RSpec.describe Game do
    subject { Game.new }

    describe '#start' do
      before do
        subject.start
      end

      context 'does with secret code:' do
        let(:secret_code) { subject.instance_variable_get(:@secret_code) }
        it 'generates' do        
          expect(secret_code).not_to be_empty
        end

        it 'saves 4 numbers' do
          expect(secret_code).to have(4).items
        end

        it 'saves with numbers from 1 to 6' do
          expect(secret_code).to match(/[1-6]{4}/)
        end

        it 'generate different from game to game' do
          expect { subject.start }.to change{ subject.instance_variable_get(:@secret_code) }
        end
      end

      context 'does with quantity of guesses:' do
        let(:guesses_quantity) { subject.instance_variable_get(:@guesses_quantity) }

        it 'generates' do        
          expect(guesses_quantity).not_to be_nil
        end

        it 'get value from constant' do
          expect(guesses_quantity).to eq(Codebreaker::QUANTITY_GUESSES)
        end
      end

      context 'does with quantity of hints:' do
        let(:hints_quantity) { subject.instance_variable_get(:@hints_quantity) }

        it 'generates' do        
          expect(hints_quantity).not_to be_nil
        end

        it 'get value from constant' do
          expect(hints_quantity).to eq(Codebreaker::QUANTITY_HINTS)
        end
      end
    end

    describe '#hint' do
      before do
        subject.start
      end

      it 'should get any digit from code' do
        expect(subject.instance_variable_get(:@secret_code)).to include(subject.hint)
      end

      it 'should change quantity of hints' do
        expect { subject.hint }.to change{ subject.instance_variable_get(:@hints_quantity) }.by(-1)
      end

      specify 'should return message if quantity of hints is ZERO' do
        subject.instance_variable_set(:@hints_quantity, 0)
        expect(subject.hint).to eq('You have used all hints!')
      end
    end

    describe '#submit_guess' do
      before do
        subject.start
      end

      it 'should change quantity of guesses' do
        expect { subject.submit_guess(1234) }.to change{ subject.instance_variable_get(:@guesses_quantity) }.by(-1)
      end

      it 'should return string equell or less than CODE_CAPACITY'
      context 'check answers' do

      end
    end
  end
end