module Codebreaker
  QUANTITY_GUESSES = 7
  QUANTITY_HINTS = 2
  CODE_CAPACITY = 4
  MESSAGE_HINTS_ARE_USED = 'You have used all hints!'
  BEST_GUESS_MARK = '++++'
  SCORE_TEMPLATE = 'secret is _s | attemts is _a | hints are used _h'
  class Game
    # I didn't use initialize. If I'd used it as start it should have made stack overflow.
    # The satrt method is more careful for my application than initialize.

    attr_reader :guesses_quantity, :hints_quantity

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
      @guesses_quantity -= 1 
      check_guess(guess.chars)
    end

    def win?(pluses_minuses)
      pluses_minuses == BEST_GUESS_MARK
    end

    def lose?(pluses_minuses)
      pluses_minuses != BEST_GUESS_MARK && @guesses_quantity == 0
    end

    def score
      SCORE_TEMPLATE.sub(/_s/, "#{@secret_code}")
                    .sub(/_a/, "#{QUANTITY_GUESSES - @guesses_quantity}")
                    .sub(/_h/, "#{QUANTITY_HINTS - @hints_quantity}")
    end

    private

      def generate_secret        
        Array.new(CODE_CAPACITY).map { rand(1..6) }.join
      end

      def check_guess(guess)  
        answer = delete_false_minuses(delete_false_pluses(guess))
        answer.compact.sort.join
      end

      def delete_false_pluses(guess)
        answer = Array.new(CODE_CAPACITY,'+')
        answer.each_index do |index|
          if guess[index] != @secret_code[index]
            answer[index] = '-' 
          else
            guess[index] = nil
          end
        end
        [answer, guess]
      end

      def delete_false_minuses(answer_and_guess)
        answer, guess = answer_and_guess
        answer.each_index do |index|
          if answer[index] == '-'
            in_guess_index = guess.index(@secret_code[index])
            if in_guess_index
              guess[in_guess_index] = nil
            else
              answer[index] = nil
            end
          end
        end
        answer
      end
  end
end