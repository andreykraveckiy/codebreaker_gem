module Codebreaker
  QUANTITY_GUESSES = 7
  QUANTITY_HINTS = 3
  CODE_CAPACITY = 4
  MESSAGE_HINTS_ARE_USED = 'You have used all hints!'
  class Game
    def initialize
    end

    def start
      @secret_code = generate_secret
      @guesses_quantity = QUANTITY_GUESSES
      @hints_quantity = QUANTITY_HINTS
    end

    def hint
      if @hints_quantity > 0
        @hints_quantity -= 1
        @secret_code[rand(0...CODE_CAPACITY)].to_s
      else
        MESSAGE_HINTS_ARE_USED
      end
    end

    def submit_guess(guess)

    end

    private

      def generate_secret(capacity = CODE_CAPACITY)        
        Array.new(capacity).map { rand(1..6) }.join
      end
  end
end