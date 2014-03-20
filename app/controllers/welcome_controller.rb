class WelcomeController < ApplicationController
  
  def index
      @times = Krawler.new
  end
end
