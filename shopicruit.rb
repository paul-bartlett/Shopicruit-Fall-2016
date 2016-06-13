require 'json'
require 'httparty'

class Shopicruit

	# initialize variables
	def init(url)
		@page_num = 1
		@url = url
		@parsed_temp = HTTParty.get("#{@url}#{@page_num}").parsed_response
	end

	# returns hash of shopping list of all variants of products with key = id, value = [price, grams]
	def shopping_list(product, url)
		init(url)
		@product = product
		shopping_list = Hash.new # initialize hash for merge
		# Loop to parse data on all pages
		while !@parsed_temp["products"].empty?
			# gets all variants of a product and puts in a list of hashes with unique id as key and price and weight as value
			shopping_list.merge!((@parsed_temp["products"].select{ |product| product["tags"].include? @product }.map{ |product| product["variants"]}.flatten.map{ |variant| [variant["id"], [variant["price"], variant["grams"]]] }).to_h)
			@page_num += 1
			@parsed_temp = HTTParty.get("#{@url}#{@page_num}").parsed_response
		end
		return shopping_list
	end
	
	# takes multiple lists and prints total weight of an equal number of "items" from each list sorted by lowest price
	def total_weight(items, list, *rest)
		total_weight = 0
		# sorts the lists by price and takes the first "items" elements and sums weight and price
		list.sort_by{ |key, value| value[0].to_f }[0..items].each{ |key, value| total_weight += value[1].to_i }
		rest.each{|list| list.sort_by{ |key, value| value[0].to_f }[0..items].each{ |key, value| total_weight += value[1].to_i }} 
		puts "Total Weight:\t#{total_weight}g"
	end
end

shop = Shopicruit.new
keyboard_list = shop.shopping_list("Keyboard", "http://shopicruit.myshopify.com/products.json?page=")
computer_list = shop.shopping_list("Computer", "http://shopicruit.myshopify.com/products.json?page=")
item_num = (([keyboard_list.size, computer_list.size].min) - 1) # max number of items to take of each
shop.total_weight(item_num, keyboard_list, computer_list)