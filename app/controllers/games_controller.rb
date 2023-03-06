require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = []
    letter_selector = ('A'..'Z').to_a
    counter = 0
    while counter < 10
      @letters[counter] = letter_selector.sample
      counter += 1
    end
    @start_time = Time.now
  end

  def score
    @answer = params[:answer]
    @start_time = params[:start_time].to_datetime
    @letters = params[:letters]
    # raise
    letters_array = @letters.split(' ')
    @result = run_game(@answer, letters_array, @start_time, Time.now)
  end

  def api_test(attempt)
    user_attempt = URI.open("https://wagon-dictionary.herokuapp.com/#{attempt}").read

    JSON.parse(user_attempt)
  end

  private

  def run_game(attempt, grid, start_time, end_time)
    api_pass = 0
    user = api_test(attempt)
    api_pass += 1 if user['found'] == true
    attempt_array = attempt.upcase.chars
    grid_combinations = (1..grid.length).flat_map { |num_per| grid.permutation(num_per).to_a }
    grid_pass = 0
    grid_pass += 1 if grid_combinations.include?(attempt_array)
    time_elasped = (end_time - start_time).round(4)
    length_multiplier = multiplier(attempt_array, grid)

    scoring(api_pass, grid_pass, time_elasped, length_multiplier)
  end

  def multiplier(attempt_array, grid)
    arr_len = attempt_array.length.to_f
    grid_len = grid.length.to_f

    (arr_len / grid_len)
  end

  def scoring(api_pass, grid_pass, time_elasped, length_multiplier)
    if api_pass.zero?
      api_failure(time_elasped)
    elsif grid_pass.zero?
      grid_failure(time_elasped)
    else
      successful_answer(time_elasped, length_multiplier)
    end
  end

  def api_failure(time_elasped)
    score = 0
    message = 'Not an english word.'

    { score:, time: time_elasped, message: }
  end

  def grid_failure(time_elasped)
    score = 0
    message = 'Not in the grid.'

    { score:, time: time_elasped, message: }
  end

  def successful_answer(time_elasped, length_multiplier)
    score = ((180 - time_elasped) * length_multiplier).round(1)
    message = 'Well done!'

    { score:, time: time_elasped, message: }
  end
end
