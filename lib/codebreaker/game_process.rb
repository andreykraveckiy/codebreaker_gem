require "codebreaker/game"

module Codebreaker
  CODE_REGEXP = /^[1-6]{4}$/
  class GameProcess
    
    STAGES_CHANGE = {
      menu: {
        "new game" => :game,
        "scores" => :scores,
        "exit" => :exit
      }, 
      game: {
        "win" => :show_score,
        "lost" => :show_score,
        "new game" => :game
      },      
      complete_game: {
        "yes" => :repeate,
        "no" => :repeate
      },
      repeate: {
        "yes" => :game,
        "no" => :menu
      },
      scores: {
        "back" => :menu
      }
    }

    def initialize
      @game = Game.new
      @stage = :menu
    end 

    def menu(choise)
      case choise
      when 'new game'
        start_game
      when 'scores'
        'Socres were not implemented yet!'
      when exit
        'exit'
      else
        %{WARNING! Type only "new game" or "scores".
        The option <#{choise}> is not allowed!}
      end
    end

    def game(choise)
      case choise
      when 'hint'
        @game.hint
      when CODE_REGEXP
        guess_process(choise)
      when 'new game'
        start_game
      else
        %{WARNING! Type only "hint", your guess(4 numbers from 1 to 6) or "new game".
        The option <#{choise}> is not allowed!}
      end
    end

    def repeate(choise)
      case choise
      when 'yes'
        start_game
      when 'no'
        'menu'
      else
        %{WARNING! Type "yes" or "no".
        The option <#{choise}> is not allowed!}
      end
    end

    def remaining_guess
      @game.guesses_quantity
    end

    def remaining_hint
      @game.hints_quantity
    end

    def listens_and_shows(choise)
      @answer = send(@stage, choise)
      if @stage_changes
        @stage_changes = false
        @stage
      else
        nil
      end
    end

    def answers
      @answer
    end

    private

      def change_stage(option)
        unless STAGES_CHANGE[@stage][option].nil?
          @stage = STAGES_CHANGE[@stage][option]
          @stage_changes = true
        end
      end

      def start_game
        @game.start
        @answer = 'Game is started.'
      end

      def guess_process(guess)
        unswer = @game.submit_guess(guess)
        if @game.lose?
          unswer += "\nYOU LOSE !" 
          @stage = STATES[2]
        end
        if @game.win?
          unswer += "\nYOU WIN !"  
          @stage = STATES[2]
        end
        unswer
      end
  end
end