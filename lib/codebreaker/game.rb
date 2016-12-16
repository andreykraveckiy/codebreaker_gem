module Codebreaker
  QUANTITY_GUESSES = 7
  QUANTITY_HINTS = 3
  class Game
    def initialize
      @secret_code = ''
      @guesses_quantity = nil
      @hints_quantity = nil
    end

    def start
      @secret_code = generate_secret
      @guesses_quantity = QUANTITY_GUESSES
      @hints_quantity = QUANTITY_HINTS
    end

    private

      def generate_secret(capacity = 4)
        result = []
        capacity.times { result << rand(1..6) }
        result.join
      end
  end
end