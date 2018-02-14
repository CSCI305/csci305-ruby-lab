#!/usr/bin/ruby
###############################################################
#
# CSCI 305 - Ruby Programming Lab
#
# <firstname> <lastname>
# <email-address>
#
###############################################################

require 'rbconfig'

$bigrams = Hash.new # The Bigram data structure
$name = "<firstname> <lastname>"

# Updates the bigram counts for the words in the provided array
def update_bigram_counts(words)
	words.each_cons(2) do |pair|
		key1 = pair[0]
		key2 = pair[1]
		if $bigrams.has_key? key1
			counts = $bigrams[key1]
			if counts.has_key? key2
				counts[key2] += 1
			else
				counts[key2] = 1
			end
		else
			counts = {key2 => 1}
			$bigrams[key1] = counts
		end
	end
end

# Finds the word most commonly associated with the given word
def mcw(word)
	if $bigrams.has_key? word
		max = 0
		keys = []
		$bigrams[word].each do |key, count|
			if count > max
				keys = [key]
				max = count
			elsif count == max
				keys << key
			end
		end

		if keys.length > 1
			return keys[Random.rand(keys.length)]
		else
			return keys[0]
		end
	end
	return ""
end

# Constructs the new most probable song title given the start_word
def create_title(start_word)
	count = 1
	next_word = start_word
	title = ""
	#while not title.include? next_word
	while count <= 20
		title += next_word + " "
		next_word = mcw(next_word)
		count += 1
	end

	return title.chomp(" ")
end

# Removes stop words from the song title
def remove_stop_words(song)
	title = song
	title.gsub!(/\b(a|an|and|by|for|from|in|of|on|out|the|to|with)\b/, "")
	return title
end

# Clean up the line to remove invalid characters and any non-title elements
# Note may return nil
def cleanup_title(line)
	# trim everything after certain characters
	song = line.sub(/.+>/, "")

	song.sub!(/([\(\[\{\\\/_\-:"`\+=*]|feat\.).*/, "")

	# remove certain characters from titles (global)
	song.gsub!(/[?¿!¡.;&@%#|]/, "")

	return song
end

# Processes a line by first cleaning it, then if valid splits the title and processes it for bigrams
def process_line(line)
	song = cleanup_title(line)

	if not song.nil? and song =~ /^[\d\w\s']+$/
		song.downcase!
		song = remove_stop_words(song)
		words = song.split("\s");
		update_bigram_counts(words)
	end
end

# function to process each line of a file and extract the song titles
def process_file(file_name)
	puts "Processing File.... "

	begin
		host_os = RbConfig::CONFIG['host_os']
		if host_os =~ /mswin|msys|mingw|cygwin|bccwin|wince|emc/
			file = File.open(file_name)
			unless file.eof?
				file.each_line do |line|
					process_line(line)
				end
			end
			file.close
		else
			IO.foreach(file_name, encoding: "utf-8") do |line|
				process_line(line)
			end
		end

		puts "Finished. Bigram model built.\n"
	rescue
		STDERR.puts "Could not open file, #{$!}"
		exit 4
	end
end

# Executes the program
def main_loop()
	puts "CSCI 305 Ruby Lab submitted by #{$name}"

	if ARGV.length < 1
		puts "You must specify the file name as the argument."
		exit 4
	end

	# process the file
	process_file(ARGV[0])

	# Get user input
	word = ""
	until word.eql? "q" do
		puts ""
		print "Enter a word [Enter 'q' to quit]: "
		word = STDIN.gets().chomp
		puts ""

		puts "#{create_title(word)}" unless word == "q"
	end
end

if __FILE__==$0
	main_loop()
end
