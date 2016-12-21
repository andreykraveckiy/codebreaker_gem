$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'codebreaker'

module Codebreaker
  class Console
    def self.run
      puts %{
        Welcome to the codebreaker!
        This amazing game proposes 
        you to guess 4 digit number. 
        You have #{Codebreaker::QUANTITY_GUESSES} attempts
        and #{Codebreaker::QUANTITY_HINTS} hints. Use last wisely!!!
        Good luck!
      }

      game = Codebreaker::GameProcess.new
      puts generate_template(:menu)
      while true
        command = $stdin.gets.chomp.downcase
        respond = game.listens_and_shows(command)
        if respond.is_a?(Symbol)
          puts generate_template(respond)
          game.answers.each { |score| puts score } if respond == :scores
        else
          puts game.answers
        end
      end
    end

    def self.generate_template(template)
      case template
      when :menu
        %{
          Type: 'new game' for begining;
                'scores' to see achieemnts;
                'exit' for exit.
        }
      when :game
        %{
          Type: 'hint' to see hint;         
                your guess - 4 with numbers from 1 to 6;
                'restart' for restart.
        }
      when :scores
        %{
          There are achievments of Codebreaker.
          Type 'back' to back in main menu.
        }
      when :complete_game
        %{
          Wold you like to save your score?(yes/no)
        }
      when :save_score
        %{
          Input your name for saving.
        }
      when :repete
        %{
          Would you like to play again?(yes/no)
        }
      when :exit
        exit
      end
    end
  end
end