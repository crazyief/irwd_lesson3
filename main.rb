require 'rubygems'
require 'sinatra'
set :sessions, true

helpers do

  def calculate_total(cards)
    arr=cards.map{|element| element[1]}
    total_number=0

    arr.each do |number|
      if number=="ace"
        number=11
      else
          number=10 if number.to_i==0 # if jack king queen
      end
      number=number.to_i
      total_number=total_number+number
    end # end of each do 

    new_arr=arr.select{|element| element=="ace"}
    ace_count=new_arr.size
    
    ace_count.times {
      break if total_number<=21
      total_number=total_number-10
    }
    total_number
  end

  def card_image(card)  # e.g. card = ["Spade","Jack"]    ["Hearts","5"]
    "<img src='/images/cards/#{card[0]}_#{card[1]}.jpg' class='card_image'>"
  end

  def win!(msg)
    @show_hit_or_stay_btn=false
    @show_play_again=true
    @success="Player win #{msg}"
  end

  def lose!(msg)
    @show_hit_or_stay_btn=false
    @show_play_again=true
    @error="Player lose #{msg}"
  end

  def tie!(msg)
    @show_hit_or_stay_btn=false
    @show_play_again=true
    @success="Player tie #{msg}"
  end

end

before do
  @show_hit_or_stay_btn=true
end

#===========

get "/"  do
  if session[:player_name]
    redirect "/game"
  else
    redirect "/new_player"
  end
end

get '/game' do
  session[:turn]=session[:player_name]

  color=%w(spades clubs hearts diamonds)
  rank=%w(ace 2 3 4 5 6 7 8 9 10 jack queen king)
  session[:deck]=color.product(rank).shuffle!

  session[:dealer_card]=[]
  session[:player_card]=[]

  session[:dealer_card]<<session[:deck].pop
  session[:player_card]<<session[:deck].pop
  session[:dealer_card]<<session[:deck].pop
  session[:player_card]<<session[:deck].pop

  erb :game
end

get "/new_player" do
  erb :new_player
end

post "/new_player" do
  if params[:player_name].empty?
    @error="Name is require"
    halt erb(:new_player)
  end

  session[:player_name]=params[:player_name]
  session[:money]=params[:money]
  redirect "/game"
end


post "/game/player/hit" do
  session[:player_card]<<session[:deck].pop

  player_point=calculate_total(session[:player_card])
  if player_point>21
    lose!(" busted with over 21")
  elsif player_point==21 
    win!(" with a black jack")
  end

  erb :game
end

post "/game/player/stay" do
  @success="You chose to stay"
  @show_hit_or_stay_btn=false
  redirect "/game/dealer"
end

get "/game/dealer" do
  session[:turn]="dealer"
  @show_hit_or_stay_btn=false
  dealer_point=calculate_total(session[:dealer_card])

  if dealer_point==21
    lose!("Dealer get blackjack")
  elsif dealer_point>21
    win!( "Dealer busted ")
  elsif dealer_point>=17
    #compare point
    redirect "/game/compare"
  else #dealer_point <17
    #dealer hit
    @show_dealer_hit_button=true
  end

  erb :game
end

post "/game/dealer/hit" do
  session[:dealer_card] << session[:deck].pop
  redirect "/game/dealer"
end

get "/game/compare" do
  dealer_point=calculate_total(session[:dealer_card])
  player_point=calculate_total(session[:player_card])

  if dealer_point>player_point
    lose!(" with a point of #{player_point}")
  elsif dealer_point==player_point
    tie!( " with a point of #{player_point}")
  else
    win!("with a point of #{player_point}")
  end

  erb :game

end

get "/game_over" do 
  erb :game_over
end

