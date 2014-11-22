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
          number=10 if number.to_i==0
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

  def card_image(card)
    #{}"img src='/images/cards/#{card[0].to_s}_#{card[1].to_s}.jpg'"
    "<img src='/images/cards/#{card[0]}_#{card[1]}.jpg' class='card_image'>"
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

  player_score=calculate_total(session[:player_card])
  if player_score>21
    @error="Busted !!  >21 "
    @show_hit_or_stay_btn=false
  elsif player_score==21 
    @success="You get 21 ! Well done "
    @show_hit_or_stay_btn=false
  end

  erb :game
end

post "/game/player/stay" do
  @success="You chose to stay"
  @show_hit_or_stay_btn=false
  erb :game
end
