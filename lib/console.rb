$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'codebreaker'

module Codebreaker
  class Console
    MESSAGES_FILE = './lib/codebreaker/messages.yaml'
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
          puts game.answers if respond == :complete_game
        else
          puts game.answers
        end
      end
    end

    def self.generate_template(template)
      case template
      when :menu
        load_messages[:menu]
      when :game
        load_messages[:game]
      when :scores
        load_messages[:scores]
      when :complete_game
        load_messages[:complete_game]
      when :save_score
        load_messages[:save_score]
      when :repeate
        load_messages[:repeate]
      when :exit
        exit
      end
    end

    def self.load_messages
      YAML.load_file(MESSAGES_FILE)
    end
  end
end