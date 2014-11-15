def calculate_total(cards)

  #...
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

  puts ace_count
  puts total_number
  
  ace_count.times {
    break if total_number<=21
    total_number=total_number-10
  }


  total_number
end