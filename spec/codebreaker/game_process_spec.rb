require 'spec_helper'

module Codebreaker
  RSpec.describe GameProcess do
    subject { GameProcess.new }

    specify { expect(subject).not_to be_nil }
    specify { expect(subject.instance_variable_get(:@game)).not_to be_nil }
    it { should_not respond_to(:menu) }
    it { should_not respond_to(:game) }
    it { should respond_to(:remaining_guess) }
    it { should respond_to(:remaining_hint) }
    it { should respond_to(:listens_and_shows) }
    it { should respond_to(:answers) }

    describe "test stages of game" do       
      specify { expect(GameProcess::STAGES_CHANGE).to be_a(Hash) }
      #allow(subject).to receive(:change_stage)
      [
        [:menu, "new game",           :game, true],
        [:menu, "scores",           :scores, true],
        [:menu, "exit",               :exit, true],
        [:menu, "undefined command", :menu, false],
        [:game, "win",          :show_score, true],
        [:game, "lost",         :show_score, true],
        [:game, "hint",              :game, false],
        [:game, "1236",              :game, false],
        [:game, "new game",           :game, true],
        [:game, "undefined command", :game, false],      
        [:complete_game, "yes",    :repeate, true],
        [:complete_game, "no",     :repeate, true],
        [:complete_game, "undefined command", :complete_game, false],
        [:repeate, "yes",             :game, true],
        [:repeate, "no",               :menu,true],
        [:repeate, "undefined command", :repeate, false],
        [:scores, "back",             :menu, true],
        [:scores, "undefined command", :scores, false],
      ].each do |transition|
        it "<#{transition[0].to_s}> & '#{transition[1]}' #{transition[-1] ? "draw" : "no redraw"} scene <#{transition[2].to_s}>" do
          subject.instance_variable_set(:@stage, transition[0])
          subject.instance_variable_set(:@stage_changes, false)
          subject.send(:change_stage, transition[1])
          # allow(subject).to receive(:change_stage)
          expect(subject.instance_variable_get(:@stage)).to eq transition[-2]
          expect(subject.instance_variable_get(:@stage_changes)).to eq(transition[-1])
        end
      end
    end
=begin
    describe '#menu' do
      context 'get command "new game"' do
        before { subject.menu('new game') }

        it 'should get message about started game' do
          expect(subject.menu('new game')).to match(/Game is started/)
        end

        it 'guesses quantity is maximum' do
          expect(subject.remaining_guess).to eq Codebreaker::QUANTITY_GUESSES
        end

        it 'hints quantity is maximum' do
          expect(subject.remaining_hint).to eq Codebreaker::QUANTITY_HINTS
        end
      end

      it 'get command "scores"'

      it 'get any another option' do
        expect(subject.menu('bla-bla')).to match(/Codebreaker can't work with command: bla-bla/)
      end
    end

    describe '#game' do
      before { subject.menu('new game') }

      context 'get command "hint"' do
        it "should return a value from 1 to 6" do
          expect(%w(1 2 3 4 5 6)).to include(subject.game("hint"))
        end

        it "should reduce hints quantity by 1" do
          expect { subject.game("hint") }.to change(subject, :remaining_hint).by(-1)
        end

        it "should not reduce guesses quantity" do
          expect { subject.game("hint") }.not_to change(subject, :remaining_guess)
        end

        it "should return a warning message" do
          3.times { subject.game("hint") }
          expect(subject.game("hint")).to match(/You have used all hints!/)
        end
      end

      context 'get right code /[1-6]{4}/' do
        specify 'result should be a string' do
          expect(subject.game("1234")).to be_a(String)
        end

        it 'should reduce guesses quantity' do
          expect { subject.game("1234") }.to change(subject, :current_guess).by(-1)
        end

        it 'should not reduce hints quantity' do
          expect { subject.game("1234") }.not_to change(subject, :current_hint)
        end
      end

      context 'get command "new game"' do
        before { subject.game('new game') }

        it 'should get message about started game' do
          expect(subject.game('new game')).to match(/Game is started/)
        end

        it 'guesses quantity is maximum' do
          expect(subject.current_guess).to eq Codebreaker::QUANTITY_GUESSES
        end

        it 'hints quantity is maximum' do
          expect(subject.current_hint).to eq Codebreaker::QUANTITY_HINTS
        end
      end

      context 'get invalid value' do
        it 'get 5-digit number' do
          expect(subject.game('12345')).to match(/Codebreaker can't work with command: 12345/)
        end

        it 'get number with 0 or 7,8,9' do
          expect(subject.game('1023')).to match(/Codebreaker can't work with command: 1023/)
          expect(subject.game('7856')).to match(/Codebreaker can't work with command: 7856/)
          expect(subject.game('9654')).to match(/Codebreaker can't work with command: 9654/)
        end

        it 'get string with extra space' do
          expect(subject.game('hint ')).to match(/Codebreaker can't work with command: hint /)
        end

        specify 'not change hints quantity' do
          expect { subject.game("hint ") }.not_to change(subject, :current_hint)
        end

        specify 'not change guesses quantity' do
          expect { subject.game("12345") }.not_to change(subject, :current_guess)
        end
      end
    end

    describe '#final_question' do
      it 'should create a new game' do
        expect(subject.final_question('yes')).to match(/Game is started/)
      end

      it 'should get exit' do
        expect(subject.final_question('no')).to eq('exit')
      end

      it 'should unswer about error command' do
        expect(subject.final_question('lorem ipsum')).to match(/Type "yes" or "no"/)
      end
    end
=end
    describe '#listens_and_shows' do
      it 'should call #menu with option "new game"' do
        subject.instance_variable_set(:@state, :menu)
        expect(subject.listens_and_shows("new game")).to match(/Game is started/)
      end

      it 'should call #game with option "hint"' do
        subject.listens_and_shows("new game")
        expect(%w(1 2 3 4 5 6)).to include(subject.listens_and_shows("hint"))
      end

      it 'should call #final_question wuth option "no"' do
        subject.instance_variable_set(:@state, :final_question)
        expect(subject.listens_and_shows("no")).to eq("exit")
      end
    end
  end
end