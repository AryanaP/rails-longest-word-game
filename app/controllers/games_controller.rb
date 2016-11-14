require 'open-uri'
require 'json'
require 'date'

class GamesController < ApplicationController

  def game
    @start_time = Time.now
    grid_size = params[:grid_size].to_i
    @grid = (1..grid_size).map { ("A".."Z").to_a[rand(26)] }

    if grid_size < 1
      @grid_answer = "Sorry, please enter another integer"
    else
      @grid_answer = @grid.join(", ")
    end

  end


  def score
    # RUN THE GAME
    @end_time = Time.now
    @attempt = params[:attempt]
    if session[:number_games] != nil
      session[:number_games] += 1
    else
      session[:number_games] = 1
    end
    @duration = (@end_time - params[:start].to_time).round(2)
    @translation = translate(@attempt)
     if !in_grid?(@attempt, params[:grid].split(","))
       @score = 0
       @message = "not in the grid"
     elsif @translation == @attempt
       @score = 0
       @message = "not an english word"
       @translation = nil
     else
       @score = (@attempt.length*10*100 / @duration)/100
       @message = "well done"
     end

     return {
       time: @duration,
       translation: @translation,
       score: @score,
       message:@message
     }

  end

  def translate(word)
    url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=4bede680-701f-4ac6-b14d-8b7fc14a2c1b&input=#{word}"
    word_serialized = open(url).read
    word = JSON.parse(word_serialized)
    return word["outputs"][0]["output"]
  end

  def in_grid?(attempt, grid)
    result = true
    tmp_grid = grid
    attempt.upcase.chars.each do |letter|
      if tmp_grid.include?(letter)
        tmp_grid = tmp_grid.join.sub(letter, "").split("")
      else
        result = false
      end
    end
      return result
    end
end
