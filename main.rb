class Board
  def initialize(code, colors)
    @code = code
    @colors = colors
  end

  def display_input(turn, max_turns)
    input = ""
    until(valid_input = input_check(input))
      print "Turn ##{turn} of #{max_turns}: Input code, REF, or HELP: "
      input = gets.chomp
    end
    return valid_input
  end
  
  def display_help
    puts "\n========================================================================="
    puts "\nThe aim of Mastermind is to correctly guess four colors in the correct order."
    puts "Codes can be input in color, letter, or number format for convenience." 
    puts "Ex: ('Blue, Yellow, red, green', 'ABCD', '1234') are all valid code entries"
    puts "\n========================================================================="
  end
  
  def display_ref
    puts "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "\nColors: Blue = 1, Yellow = 2, Red = 3, Green = 4, Purple = 5, Orange = 6"
    puts "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  end

  def regex_helper(colors_hash)
    string = ""
    colors = colors_hash.keys
    (colors.length - 1).times do |index|
      string << colors[index] + "|"
    end
    string << colors[-1]
  end
  
  def input_check(input)
    if(input == "HELP")
      display_help
      return false
    elsif(input == "REF")
      display_ref
      return false
    elsif(input == "")
      return false
    elsif (input.length == 4)
      code = []
      pre_code = input.downcase.split(//)
      pre_code.each do |digit|
        code << letters_to_numbers(digit)
      end
      return code
    else
      if (valid = input_validation(input))
        code = colors_to_numbers(valid)
        return code
      else 
        puts "Invalid code, please try again."
        return false
      end
    end
  end

  def input_validation(input)
    my_input = input.downcase
    colors_found = my_input.scan (/#{regex_helper(@colors)}/)
    if colors_found.length == 4
      return colors_found
    end
    return false
  end

  def colors_to_numbers(colors_code)
    letter_code = []
    colors_code.each do |color|
      letter_code << @colors[color]
    end
    letter_code
  end

  def letters_to_numbers(input)
    if (input != "0" && input.to_i == 0)
      if (input.ord >= 97 && input.ord <= 122)
        return input.ord - 96
      else
        return (-1)
      end
    else
      return input.to_i
    end
  end

  def numbers_to_colors(code)
    color_code = []
    code.each do |number|
      color_code << @colors.key(number)
    end
    return color_code
  end

  def display_board(code, hints = [0, 0], turn)
    puts "\n##{turn}: Code: #{numbers_to_colors(code)}"
    puts "--------------"
    puts "#{hints[0]} Color(s) are in the correct position"
    puts "#{hints[1]} Color(s) are correct in the wrong position"
    puts "--------------------------------------------"
  end
end

class Secret
  RANDOMGEN = 9999999999999999999

  def initialize(colors)
    #List of possible colors
    @colors = colors
    @secret_code = []
  end

  #Takes in a seed number and returns an array
  def generate_code_with_seed(seed)
    code = [0, 0, 0, 0]
    index_found = false
    seed_invalid = 0
    until index_found || seed_invalid > 10000
      seed_invalid += 1
      code = array_increment(code)
      code_index = code.join.to_i
      if seed == Random.new(code_index).rand(RANDOMGEN)
        index_found = true
      end
    end
    if (seed_invalid > 10000)
      puts "Invalid seed"
      code = [0, 0, 0, 0]
    end
    return code
  end

  #Takes in a 4 digit number and returns a seed number
  def generate_seed_with_code(code)
    seed = Random.new(code.join.to_i).rand(RANDOMGEN)
  end

  def array_increment(array)
    i = 0
    while i < array.length
      array[i] += 1
      if array[i] <= @colors.length
        i = array.length
      else
        array[i] = 0
        i += 1
      end
    end
    array
  end

  def letter_to_number(input)
    if (input != "0" && input.to_i == 0)
      if (input.ord >= 97 && input.ord <= 122)
        puts input.ord - 96
      else
        puts (-1)
      end
    else
      puts input
    end
  end
end

class Game
  def initialize(colors, turn_limit, answer)
    @answer = answer
    @colors = colors
    @turn_limit = turn_limit
    @turns = 0
    @board = Board.new(answer, colors)
  end

  def play_game
    @board.display_help
    @board.display_ref
    win = false
    until(win || @turns > @turn_limit-1)
      @turns += 1
      input = @board.display_input(@turns, @turn_limit)
      hints = evaluate_answer(input, @answer)
      unless hints[0] == 4
        @board.display_board(input, hints, @turns)
      else
        win = true
        puts "Congratulations! You found my code: #{@answer}" 
      end
    end
    if @turns > @turn_limit-1 && !win
      puts "You lose. the answer was #{@board.numbers_to_colors(@answer)}(#{@answer})\n\n\n"
    end
  end

  def get_input
    return input
  end

  def evaluate_answer(input, answer)
    hints = [0, 0]
    leftover_input = []
    leftover_answer = []
    input.each_index do |i|
      if (input[i] == answer[i])
        hints[0] += 1
      else
        leftover_input << input[i]
        leftover_answer << answer[i]
      end
    end
    leftover_input.each do |color|
      if (leftover_answer.include?(color))
        hints[1] += 1 
        leftover_answer.delete_at(leftover_answer.index(color))
      end
    end
    return hints
  end
end

class Menu
  def initialize
    @colors = {
      "blue" => 1, 
      "yellow" => 2, 
      "red" => 3, 
      "green" => 4, 
      "purple" => 5, 
      "orange" => 6
    }

    @game_secret = Secret.new(@colors)
  end

  def options
    puts "Choose 1, 2, or 3 to make your selection"
    puts "1: New Game with random seed"
    puts "2: New Game with custom seed"
    puts "3: Create seed for other player"

    input = gets.chomp

    case input
    when "1"
      game = Game.new(@colors, 10, generate_code_randomly)
      game.play_game
    when "2"
      game = Game.new(@colors, 10, code_creation)
      game.play_game
    when "3"
      p seed_creation

    else
      puts "TODO: fix this crash"
    end
  end

  def new_game(turns = 1, answer = [0, 0, 0, 0])
    puts "\n\n\n\nWelcome to Mastermind"
    @game = Game.new(@colors, turns, answer)
    @game.play_game
  end

  #Menu for turning a code into a seed or vice versa

  private
  #Gets input (expected 4 digit code number) and returns a seed
  def seed_creation
    puts "Input code"
    code_string = gets.chomp
    code_array = code_string.split(//)
    code_array = code_array.each_index {|i| code_array[i] = code_array[i].to_i}
    puts "GENERATED SEED: #{@game_secret.generate_seed_with_code(code_array)}"
  end

  #Gets input (expected seed number) and returns an array of 4 single digit numbers
  def code_creation
    puts "input seed"
    input = gets.chomp.to_i
    return @game_secret.generate_code_with_seed(input)
  end

  def generate_code_randomly
    code = []
    4.times do
      digit = Random.new.rand(@colors.length)
      code << digit+1
    end
    code
  end
end

menu = Menu.new
menu.options