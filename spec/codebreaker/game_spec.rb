require 'spec_helper'

module Codebreaker
  RSpec.describe Game do
    subject { Game.new }

    before do
      subject.start
    end

    it { should respond_to(:start) }
    it { should respond_to(:hint) }
    it { should respond_to(:submit_guess) }
    it { should respond_to(:win?) }
    it { should respond_to(:lose?) }
    it { should respond_to(:score) }
    it { should respond_to(:guesses_quantity) }
    it { should respond_to(:hints_quantity) }

    describe '#start' do
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
        let(:guesses_quantity) { subject.guesses_quantity }

        it 'generates' do        
          expect(guesses_quantity).not_to be_nil
        end

        it 'get value from constant' do
          expect(guesses_quantity).to eq(Codebreaker::QUANTITY_GUESSES)
        end
      end

      context 'does with quantity of hints:' do
        let(:hints_quantity) { subject.hints_quantity }

        it 'generates' do        
          expect(hints_quantity).not_to be_nil
        end

        it 'get value from constant' do
          expect(hints_quantity).to eq(Codebreaker::QUANTITY_HINTS)
        end
      end

      context 'does with guesst\'s mark' do
        it { expect(subject.instance_variable_get(:@mark_guess)).to be_nil }
      end
    end

    describe '#hint' do
      it 'should get any digit from code' do
        expect(subject.instance_variable_get(:@secret_code)).to include(subject.hint)
      end

      it 'should change quantity of hints' do
        expect { subject.hint }.to change(subject, :hints_quantity).by(-1)
      end

      specify 'should return message if quantity of hints is ZERO' do
        subject.instance_variable_set(:@hints_quantity, 0)
        expect(subject.hint).to eq('You have used all hints!')
      end
    end

    describe '#submit_guess' do
      it 'should change quantity of guesses' do
        expect { subject.submit_guess('1234') }.to change(subject, :guesses_quantity).by(-1)
      end

      context 'check answers' do
        [
          ['1111', '1111', '++++'],
          ['1111', '1112', '+++'],
          ['1111', '1211', '+++'],
          ['1121', '1211', '++--'],
          ['1121', '3211', '+--'],
          ['1112', '1234', '+-'],
          ['1121', '1234', '+-'],
          ['1122', '1324', '++'],
          ['1122', '2211', '----'],
          ['1212', '1234', '++'],
          ['1212', '1221', '++--'],
          ['1211', '3456', ''],
          ['1234', '4321', '----'],
          ['1222', '2111', '--'],
          ['1222', '2121', '+--'],
          ['2363', '2366', '+++'],
          ['1234', '2345', '---'],
          ['3635', '3333', '++'],
          ['1234', '5513', '--'],
          ['1234', '5535', '+'],
          ['1234', '5525', '-'],
          ['1234', '4213', '+---'],
          ['1234', '2134', '++--'],
          ['1234', '5134', '++-'],
          ['1234', '5213', '+--'],
          ['1234', '1546', '+-'],
          ['1234', '5555', ''],
          ['1221','2332','--'],
          ['1222','2431','--'],
          ['1222','2435','-'],
          ['2222','2222','++++'],  
        ].each do |line|
          it "get secret is <#{line.first}>, guess is <#{line[1]}>, should get <#{line.last}>" do
            subject.instance_variable_set(:@secret_code, line.first)
            expect(subject.submit_guess(line[1])).to eq(line.last)
          end
        end
      end
    end

    describe '#win?' do
      it 'should return true if previous guess was success' do
        subject.instance_variable_set(:@mark_guess, '++++')
        expect(subject.win?).to be_truthy
      end

      describe 'should be false if previous guess was not success' do
        specify do 
          subject.instance_variable_set(:@mark_guess, '+++-')
          expect(subject.win?).to be_falsey
        end

        specify do
          subject.instance_variable_set(:@mark_guess, '----')
          expect(subject.win?).to be_falsey
        end

        specify do
          subject.instance_variable_set(:@mark_guess, nil)
          expect(subject.win?).to be_falsey
        end
      end
    end

    describe '#lose?' do
      it 'should return true if guess quantity is 0 and guess mark is not "++++"' do
        subject.instance_variable_set(:@guesses_quantity, 0)
        subject.instance_variable_set(:@mark_guess, '+++-')
        expect(subject.lose?).to be_truthy
      end

      context 'should return false' do
        specify 'guesses quantity is 0 and answer is "++++"' do
          subject.instance_variable_set(:@guesses_quantity, 0)
          subject.instance_variable_set(:@mark_guess, '++++')
          expect(subject.lose?).to be_falsey
        end

        specify 'guesses quantity grate than 0 and answer is "++++"' do
          subject.instance_variable_set(:@guesses_quantity, 4)
          subject.instance_variable_set(:@mark_guess, '++++')
          expect(subject.lose?).to be_falsey
        end

        specify 'guesses quantity grate than 0 and answer is "++-"' do
          subject.instance_variable_set(:@guesses_quantity, 4)
          subject.instance_variable_set(:@mark_guess, '++-')
          expect(subject.lose?).to be_falsey
        end
      end
    end

    describe '#score' do
      context 'should return hash with info if game is won' do
        let(:won_hash) do 
          { secret: subject.instance_variable_get(:@secret_code),
            attempts: Codebreaker::QUANTITY_GUESSES - 4,
            hints: Codebreaker::QUANTITY_HINTS - 1 }  
        end
        before do
          subject.instance_variable_set(:@guesses_quantity, 4)
          subject.instance_variable_set(:@hints_quantity, 1)
          subject.instance_variable_set(:@mark_guess, '++++')
        end
        specify { expect(subject.score).to be_a(Hash) }
        specify { expect(subject.score).to eq won_hash }
      end

      context 'should return hash with info if game is lost' do
        let(:lose_hash) do 
          { secret: subject.instance_variable_get(:@secret_code),
            attempts: Codebreaker::QUANTITY_GUESSES - 0,
            hints: Codebreaker::QUANTITY_HINTS - 1 }  
        end
        before do
          subject.instance_variable_set(:@guesses_quantity, 0)
          subject.instance_variable_set(:@hints_quantity, 1)
          subject.instance_variable_set(:@mark_guess, '')
        end
        specify { expect(subject.score).to be_a(Hash) }
        specify { expect(subject.score).to eq lose_hash }
      end

      it 'should return warning message if game is not won or lost' do
        subject.instance_variable_set(:@guesses_quantity, 1)
        subject.instance_variable_set(:@hints_quantity, 1)
        expect(subject.score).to match(/^COMPLETE.+before/)
      end
    end
  end
end