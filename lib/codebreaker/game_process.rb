require "codebreaker/game"
require "yaml"

module Codebreaker
  CODE_REGEXP = /^[1-6]{4}$/
  DB_FILE = "scores.yaml"
  class GameProcess
    
    STAGES_CHANGE = {
      menu: {
        "new game" => :game,
        "scores" => :scores,
        "exit" => :exit
      }, 
      game: {
        "win" => :complete_game,
        "lose" => :complete_game,
        "restart" => :game
      },      
      complete_game: {
        "yes" => :save_score,
        "no" => :repeate
      },
      save_score: Hash.new(:repeate),
      repeate: {
        "yes" => :game,
        "no" => :menu
      },
      scores: {
        "back" => :menu
      }
    }

    attr_reader :stage

    def initialize
      @game = Game.new
      @stage = :menu
      @stage_changes = false
    end     

    def remaining_guess
      @game.guesses_quantity if @stage == :game
    end

    def remaining_hint
      @game.hints_quantity if @stage == :game
    end

    def listens_and_shows(choise)
      @answer = send(@stage, choise)
      change_stage(choise) unless @stage_changes
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

      def menu(choise)
        case choise
        when 'new game'
          start_game
        when 'scores'
          scores_from_db
        when 'exit'
          'exit'
        else
          %{WARNING! Type only "new game", "scores" or "exit".
          The option <#{choise}> is not allowed!}
        end
      end

      def game(choise)
        case choise
        when 'hint'
          @game.hint
        when CODE_REGEXP
          guess_process(choise)
        when 'restart'
          start_game
        else
          %{WARNING! Type only "hint", your guess(4 numbers from 1 to 6) or "new game".
          The option <#{choise}> is not allowed!}
        end
      end

      def complete_game(choise)
        unless choise == 'yes' || choise == 'no'
          %{WARNING! Type "yes" or "no".
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

      def scores(option)
        unless option == 'back'
          %{WARNING! Type only "back".}
        end
      end

      def save_score(name)
        @score[:name] = name
        @score[:time] = Time.now
        array_to_save = scores_from_db
        array_to_save << @score
        File.new(DB_FILE, "w+").close unless File.exist?(DB_FILE)

        File.open(DB_FILE, "w") do |f|
          f.write(array_to_save.to_yaml)
        end
        'Score saved'
      end

      def start_game
        @game.start
        ''
      end

      def scores_from_db
        YAML.load_file(DB_FILE) || []
      end

      def guess_process(guess)
        unswer = @game.submit_guess(guess)
        if @game.lose?
          @score = @game.score
          @score[:result] = "LOSE"
          unswer = @score
          change_stage("lose")
        end
        if @game.win?
          @score = @game.score
          @score[:result] = "WIN" 
          unswer = @score 
          change_stage("win")
        end 
        unswer
      end
  end
end