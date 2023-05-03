require "open-uri"
require "json"

class GamesController < ApplicationController
  def new
    @grid = generate_grid(10).join(" ")
    @start_time = Time.now
  end

  def score
    # get data from form
    grid = params[:grid].split("")
    @guess = params[:guess]
    start_time = Time.parse(params[:start_time])
    end_time = Time.now

    # Final Result Score

    @result = run_game(@guess, grid, start_time, end_time)

  end

  private

  # Random Grid Of Letters
  def generate_grid(grid_size)
    Array.new(grid_size) { ("A".."Z").to_a.sample }
  end

  # Check if char from grid are only used once in guess
  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  # Score based on time taken and guess length

  def compute_score(guess, time_taken)
    time_taken > 60.0 ? 0 : (guess.length * (1.0 - (time_taken / 60.0)))
  end

  # Score and Messages

  def score_and_message(guess, grid, time)
    if included?(guess.upcase, grid)
      if english_word?(guess)
        score = compute_score(guess, time)
        [score, "Well Done!"]
      else
        [0, "Not An English Word"]
      end
    else
      [0, "Not In The Grid"]
    end
  end

  # running game

  def run_game(guess, grid, start_time, end_time)
  result = { time: end_time - start_time }

  score_and_message = score_and_message(guess, grid, result[:time])
  result[:score] = score_and_message.first
  result[:message] = score_and_message.last

  result

  end

  # check if word is a valid english word API
  def english_word?(word)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json["found"]
  end
end
