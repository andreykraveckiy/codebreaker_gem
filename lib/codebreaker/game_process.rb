require "codebreaker/game"

module Codebreaker
  class GameProcess
    MENU_CHOISES = [
      'new game',
      'scores'      
    ]
    MESSAGE_FOR_UNDEFINED_OPTION = %{
      Codebreaker can't work with command: _option_!
      Please type one from the next: _commands_!
    }
    GAME_CHOISES = [
      'hint',
      /^[1-6]{4}$/,
      'new game'
    ]
    STATES = [:menu, :game, :final_question]

    def initialize
      @game = Game.new
      @state = STATES[0]
    end 

    def menu(choise)
      case choise
      when MENU_CHOISES[0]
        start_game
      #when MENU_CHOISES[1]
      # show scores
      else
        MESSAGE_FOR_UNDEFINED_OPTION.sub(/_option_/, choise)
                                    .sub(/_commands_/, MENU_CHOISES.to_s)
      end
    end

    def game(choise)
      case choise
      when GAME_CHOISES[0]
        @game.hint
      when GAME_CHOISES[1]
        guess_process(choise)
      when GAME_CHOISES[2]
        start_game
      else
        MESSAGE_FOR_UNDEFINED_OPTION.sub(/_option_/, choise)
                                    .sub(/_commands_/, GAME_CHOISES.to_s)
      end
    end

    def final_question(choise)
      case choise
      when 'yes'
        start_game
      when 'no'
        'exit'
      else
        'Type "yes" or "no", please'
      end
    end

    def current_guess
      @game.guesses_quantity
    end

    def current_hint
      @game.hints_quantity
    end

    def bottleneck(choise)
      send(@state, choise)
    end

    private

      def start_game
        @game.start
        @state = STATES[1]
        'Game is started. Use commands "hint", "new game" or write your code.'
      end

      def guess_process(guess)
        unswer = @game.submit_guess(guess)
        if @game.lose?(unswer)
          unswer += "\nYOU LOSE !" 
          @state = STATES[2]
        end
        if @game.win?(unswer)
          unswer += "\nYOU WIN !"  
          @state = STATES[2]
        end
        unswer
      end
  end
end