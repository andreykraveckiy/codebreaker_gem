$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'codebreaker'

def fire
  puts %{
    Welcome to the codebreaker!
    This amazing game proposes 
    you to guess 4 digit number. 
    You have #{Codebreaker::QUANTITY_GUESSES} attempts
    and #{Codebreaker::QUANTITY_HINTS} hints. Use last wisely!!!
    Good luck!
  }

  game = Codebreaker::GameProcess.new
  puts "Please type 'new game' for begining."
  while true
    command = $stdin.gets.chomp.downcase
    exit if command == 'q'
    respond = game.bottleneck(command)
    exit if respond == 'exit'
    if respond.match(/YOU/)
      puts 'Would you like to play again?[yes/no]'
    end
    puts respond
    if command.match(/^[1-6]{4}$/) && !respond.match(/YOU/)
      puts "You have only #{game.current_guess} attempts. Type your next command:" 
    end
    puts "You have only #{game.current_hint} hints." if command == 'hint'
  end
end

fire