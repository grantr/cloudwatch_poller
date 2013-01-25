require "rubygems"
require "bundler"
Bundler.setup(:presentation)

require 'deck/rack_app'
run Deck::RackApp.build('Presentation.md')
