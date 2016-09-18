#!/usr/bin/env ruby

# http://downloads.khinsider.com/game-soundtracks/album/the-wind-rises
# The site doesn't give all the soundtracks in a single archive
# The are asking for a fucking donations. But I don't care, I can't care less.
# So this program is for mass downloading albums from this website.
# Fuckin' fucks.
#

require 'open-uri'

baseurl = "http://downloads.khinsider.com/game-soundtracks/album/the-wind-rises"
fname = "basefile.html"
tracklist = Array.new

puts "Fetching the basepage..."
# Read everything into a file basepage.html
File.open(fname, 'w'){ |file|
	file.write(open(baseurl).read)
}

puts "Buiding tracklist to download..."
# Open file and read its contents line by line
# File inherits from IO, so the use of foreach is okay
# More about:
# IO: https://ru.wikibooks.org/wiki/Ruby/%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA/IO#IO::foreach
# foreach: https://stackoverflow.com/questions/5545068/what-are-all-the-common-ways-to-read-a-file-in-ruby

regex1 = Regexp.union(/^<td>/, /<\/td>$/)
regex_url = /http.*?mp3/

File.foreach(fname){ |line|
	line.delete!("\r")

	if line[regex1] && line[regex_url]
		tracklist.push(line.match(regex_url).to_s)
	end
}

# Remove any duplicates in the array of links
tracklist = tracklist.uniq

# Construct an array of download links
trackfile = "track.html"
links = Array.new

regex2 = /^<audio/
regex_url2 = regex_url

# Set track counter
counter = 1

tracklist.each{ |track|
	File.open(trackfile, 'w') { |file|
		file.write(open(track).read)
	}

	File.foreach(trackfile) { |line|
		line.delete!("\r")

		if line[regex2] && line[regex_url2]
			links.push(line.match(regex_url2).to_s)
			puts "Got track link ##{counter}"
			counter += 1
		end
	}

}

# Form a new array of ready-to-download links
tracklist = links

# Write all the links to the file
resfile = "result.txt"

File.open(resfile, 'w'){ |file|
	tracklist.each{ |track| file.write("#{track}\n") }
}

puts "\nThe resulting tracklist:"
puts "------------------------"
tracklist.each do |track|
	puts track
end
puts "------------------------"

puts "Download? [y/N]"
# TODO: understand the calling of functions better
ans = gets.chomp

if ans == "y"
	%x(wget -i #{resfile})
	puts "\nAll done!"
else
	puts "Aborting!"
end

# And finally delete temp files
File.delete(fname)
File.delete(resfile)
File.delete(trackfile)
