require 'ruby2d'

# Set up window
set fps_cap: 20 #the speed of the snake 
set title: 'Snake Game'
# The window size
set width: 640
set height: 480
set background: 'black'

GRID_SIZE = 20
GRID_WIDTH = Window.width / GRID_SIZE
GRID_HEIGHT = Window.height / GRID_SIZE

# Snake class
class Snake
  attr_writer :direction
# The start position of the snake 
  def initialize
    @positions = [[2, 0], [1, 0], [0, 0]]
    @direction = 'right' #which way will the snake move when start the game 
    @growing = false
  end
  # Draw the snake
  def draw
    @positions.each do |position|
      Square.new(x: position[0] * GRID_SIZE, y: position[1] * GRID_SIZE, size: GRID_SIZE - 1, color: 'blue')
    end
  end

  def move
    @positions.pop unless @growing

    case @direction
    when 'up'
      @positions.unshift([head[0], head[1] - 1])
    when 'down'
      @positions.unshift([head[0], head[1] + 1])
    when 'left'
      @positions.unshift([head[0] - 1, head[1]])
    when 'right'
      @positions.unshift([head[0] + 1, head[1]])
    end

    @growing = false
  end

  def grow
    @growing = true
  end
  
  def hit_itself?
    @positions.uniq.length != @positions.length
  end

  def hit_edge?
    head[0] < 0 || head[0] >= GRID_WIDTH || head[1] < 0 || head[1] >= GRID_HEIGHT
  end

  def head
    @positions.first
  end
  # Make sure that the snake won't go back and hits itself 
  def change_direction_to?(new_direction)
    case @direction
    when 'up' then new_direction != 'down'
    when 'down' then new_direction != 'up'
    when 'left' then new_direction != 'right'
    when 'right' then new_direction != 'left'
    end
end

end

# Fruit class
class Fruit
  def initialize
    @position = [rand(GRID_WIDTH), rand(GRID_HEIGHT)]
  end
  # Creating the fruit 
  def draw
    Square.new(x: @position[0] * GRID_SIZE, y: @position[1] * GRID_SIZE, size: GRID_SIZE, color: 'red')
  end
  # Regenerate the fruit in ramdom position 
  def regenerate
    @position = [rand(GRID_WIDTH), rand(GRID_HEIGHT)]
  end

  def position
    @position
  end
end

# BigFruit class
class BigFruit
  def initialize
  end

  def spawn(x, y)
    @position = [x, y]
    @visible = true
  end

  def visible
    @visible 
  end

  def position
    @position
  end

  def eaten
    @visible = false
  end
end

# Starting a new game 
snake = Snake.new
fruit = Fruit.new
big_fruit = BigFruit.new
score = 0
game_over = false

# Update loop
update do
  unless game_over
    snake.move
    #Make the snake grow and add a point to the player and reposition the fruit
    if snake.head == fruit.position
      fruit.regenerate
      snake.grow
      score += 10
    end

    # Check for collisions with the big fruit
    if big_fruit.visible && snake.head == big_fruit.position
      big_fruit.eaten
      score += 20
    end
    # Show the big fruit every time the snake eats 5 normal fruits
    if score > 0 && score % 50 == 0
      x, y = fruit.position
      big_fruit.spawn(x, y)
    end

    # End the game if the snake hits itself or the boder 
    if snake.hit_itself? || snake.hit_edge?
      game_over = true
    end
  end
  clear
  # if the game is not finished then display the score that the player currently have
  unless game_over
    snake.draw
    fruit.draw
    Text.new("Score: #{score}", x: 10, y: 10, size: 20, color: 'white')
  else # If the game end then display the player finnal score 
    Text.new("Game Over", x: 250, y: 200, size: 30, color: 'white')
    Text.new("Final Score: #{score}", x: 250, y: 240, size: 20, color: 'white')
    Text.new("Press 'R' to restart", x: 230, y: 280, size: 20, color: 'white')
  end
end

# Input handling
on :key_down do |button_down|
    case button_down.key
    when 'up'
      snake.direction = 'up' if snake.change_direction_to?('up') 
    when 'down'
      snake.direction = 'down' if snake.change_direction_to?('down') 
    when 'left'
      snake.direction = 'left' if snake.change_direction_to?('left') 
    when 'right'
      snake.direction = 'right' if snake.change_direction_to?('right') 
    #Reseting the game 
    when 'r', 'R'
      snake = Snake.new
      fruit = Fruit.new
      big_fruit = BigFruit.new
      score = 0
      game_over = false
    end
  end

# Run the game
show