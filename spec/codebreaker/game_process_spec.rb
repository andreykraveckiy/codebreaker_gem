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
        [:game, "win",          :save_score, true],
        [:game, "lose",         :save_score, true],
        [:game, "hint",              :game, false],
        [:game, "1236",              :game, false],
        [:game, "restart",           :game, true],
        [:game, "undefined command", :game, false],      
        [:complete_game, "yes", :save_score, true],
        [:complete_game, "no",     :repeate, true],
        [:complete_game, "undefined command", :complete_game, false],
        [:save_score, "name",      :repeate, true],
        [:save_score, "name1",     :repeate, true],
        [:save_score, "Lorem Ipsum",     :repeate, true],
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

    describe '#listens_and_shows' do
      context 'test #menu' do        
        before { subject.instance_variable_set(:@stage, :menu) }

        specify { expect(subject.listens_and_shows("new game")).to eq(:game) }
        specify { expect(subject.listens_and_shows("exit")).to eq(:exit) } 

        context 'get command "new game"' do
          before { subject.listens_and_shows('new game') }

          it 'guesses quantity is maximum' do
            expect(subject.remaining_guess).to eq Codebreaker::QUANTITY_GUESSES
          end

          it 'hints quantity is maximum' do
            expect(subject.remaining_hint).to eq Codebreaker::QUANTITY_HINTS
          end
        end

        it 'get command "scores"' do
          expect(subject.listens_and_shows("scores")).to eq(:scores)
          expect(subject.answers).to be_a(Array)
        end

        it 'get any another option' do
          subject.listens_and_shows('bla-bla')
          expect(subject.answers).to match(/WARNING/)
        end

        describe 'remaining_guess and remaining_hint' do
          specify 'remaining_guess returns nil' do
            expect(subject.remaining_guess).to be_nil
          end

          specify 'remaining_hint returns nil' do
            expect(subject.remaining_hint).to be_nil
          end
        end
      end

      context 'test #game' do
        before do
          subject.instance_variable_set(:@stage, :menu)
          subject.listens_and_shows("new game")
        end

        it 'emulate lose' do
          subject.instance_variable_set(:@stage, :menu)
          expect(subject.listens_and_shows("new game")).to eq :game
          expect(subject.listens_and_shows("1324")).to be_nil
          expect(subject.listens_and_shows("1325")).to be_nil
          expect(subject.listens_and_shows("1326")).to be_nil
          expect(subject.listens_and_shows("1324")).to be_nil
          expect(subject.listens_and_shows("1325")).to be_nil
          expect(subject.listens_and_shows("1326")).to be_nil
          expect(subject.listens_and_shows("1324")).to eq :save_score
        end

        describe 'remaining_guess and remaining_hint' do
          specify 'remaining_guess returns 7' do
            expect(subject.remaining_guess).to eq Codebreaker::QUANTITY_GUESSES
          end

          specify 'remaining_hint returns 2' do
            expect(subject.remaining_hint).to eq Codebreaker::QUANTITY_HINTS
          end
        end

        describe 'option: hint' do
          before { subject.listens_and_shows("hint") }
          specify { expect(%w(1 2 3 4 5 6)).to include(subject.answers) }

          it "should reduce hints quantity by 1" do
            expect { subject.listens_and_shows("hint") }.to change(subject, :remaining_hint).by(-1)
          end

          it "should not reduce guesses quantity" do
            expect { subject.listens_and_shows("hint") }.not_to change(subject, :remaining_guess)
          end

          it "should return a warning message" do
            3.times { subject.listens_and_shows("hint") }
            expect(subject.answers).to match(/You have used all hints!/)
          end
        end

        context 'get right code /[1-6]{4}/' do
          specify 'result should be a string' do
            subject.listens_and_shows("1234")
            expect(subject.answers).to be_a(String)
          end

          it 'should reduce guesses quantity' do
            expect { subject.listens_and_shows("1234") }.to change(subject, :remaining_guess).by(-1)
          end

          it 'should not reduce hints quantity' do
            expect { subject.listens_and_shows("1234") }.not_to change(subject, :remaining_hint)
          end
        end

        describe 'option: new game' do
          before { subject.listens_and_shows('new game') }

          it 'guesses quantity is maximum' do
            expect(subject.remaining_guess).to eq Codebreaker::QUANTITY_GUESSES
          end

          it 'hints quantity is maximum' do
            expect(subject.remaining_hint).to eq Codebreaker::QUANTITY_HINTS
          end
        end

        describe 'option: undefault options' do
          it 'get 5-digit number' do
            subject.listens_and_shows('12345')
            expect(subject.answers).to match(/WARNING/)
          end

          it 'get number with 0 or 7,8,9' do
            subject.listens_and_shows('1023')
            expect(subject.answers).to match(/<1023>/)
          end

          it 'get string with extra space' do
            subject.listens_and_shows('hint ')
            expect(subject.answers).to match(/<hint >/)
          end

          specify 'not change hints quantity' do
            expect { subject.listens_and_shows("hint ") }.not_to change(subject, :remaining_hint)
          end

          specify 'not change guesses quantity' do
            expect { subject.listens_and_shows("12345") }.not_to change(subject, :remaining_guess)
          end
        end
      end

      describe 'test #repeate' do
        before { subject.instance_variable_set(:@stage, :repeate) }

        it 'should start a new game' do
          expect(subject.listens_and_shows('yes')).to eq(:game)
        end

        it 'should return to menu' do
          expect(subject.listens_and_shows('no')).to eq(:menu)
        end

        it 'should unswer about error command' do
          expect(subject.listens_and_shows('lorem ipsum')).to be_nil
          expect(subject.answers).to match(/WARNING/)
        end
      end

      describe 'test #complete_game' do
        before { subject.instance_variable_set(:@stage, :complete_game) }

        it 'should get input save_score scene' do
          expect(subject.listens_and_shows('yes')).to eq :save_score
        end

        it 'should get input repeate scene' do
          expect(subject.listens_and_shows('no')).to eq :repeate
        end

        it 'should get warning message' do
          subject.listens_and_shows('bla-bla')
          expect(subject.answers).to match(/WARNING/)
        end

        describe 'remaining_guess and remaining_hint' do
          specify 'remaining_guess returns nil' do
            expect(subject.remaining_guess).to be_nil
          end

          specify 'remaining_hint returns nil' do
            expect(subject.remaining_hint).to be_nil
          end
        end
      end

      describe 'test #save_score' do
        let(:score_to_save) { {
            secret: '1234',
            attempts: 6,
            hints: 2
            } }
        before do
          subject.instance_variable_set(:@stage, :save_score)
          subject.instance_variable_set(:@score, score_to_save)
        end

        it 'should get input repeate scene' do
          expect(subject.listens_and_shows('New name')).to eq :repeate
        end

        it 'should get saved hash from file' do
          hash = subject.send(:scores_from_db).last
          expect(hash[:secret]).to eq score_to_save[:secret]
          expect(hash[:attempts]).to eq score_to_save[:attempts]
          expect(hash[:attempts]).to eq score_to_save[:attempts]
        end
      end

      describe 'test #scores' do
        before do
          subject.instance_variable_set(:@stage, :menu)
          subject.listens_and_shows('scores')
        end

        it 'should have answer as array' do
          expect(subject.answers).to be_a(Array)
        end

        it 'should get menu' do
          expect(subject.listens_and_shows('back')).to eq :menu
        end

        it 'should show warning' do
          subject.listens_and_shows('not back')
          expect(subject.answers).to match(/WARNING/)
        end
      end
    end
  end
end