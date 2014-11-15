require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
  def calculate_total(cards)
    arr=cards.map{|element| element[1]}
    total_number=0

    arr.each do |number|
      if number=="Ace"
        number=11
      else
          number=10 if number.to_i==0
      end
      number=number.to_i
      total_number=total_number+number
    end # end of each do 

    new_arr=arr.select{|element| element=="Ace"}
    ace_count=new_arr.size
    
    ace_count.times {
      break if total_number<=21
      total_number=total_number-10
    }
    total_number
  end
end

before do
  @show_hit_or_stay_btn=true
end

get "/"  do
  if session[:player_name]
    redirect "/game"
  else
    redirect "/new_player"
  end
end

get "/new_player" do
  erb :new_player
end

post "/new_player" do
  session[:player_name]= params[:player_name]
  session[:money]= params[:money]
  redirect "/game"
end


get '/game' do
  color=%w(Spade Club Heart Square)
  rank=%w(Ace 2 3 4 5 6 7 8 9 10 Jack Queen King)
  session[:deck]=color.product(rank).shuffle!

  session[:dealer_card]=[]
  session[:player_card]=[]

  session[:dealer_card]<<session[:deck].pop
  session[:player_card]<<session[:deck].pop
  session[:dealer_card]<<session[:deck].pop
  session[:player_card]<<session[:deck].pop

  erb :game
end


post "/game/player/hit" do
  session[:player_card]<<session[:deck].pop

  if calculate_total(session[:player_card])>21
    @error="Busted !!  >21 "
    @show_hit_or_stay_btn=false
  end
  erb :game
end

post "/game/player/stay" do
  @success="You chose to stay"
  @show_hit_or_stay_btn=false
  erb :game
end




