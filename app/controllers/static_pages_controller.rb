class StaticPagesController < ApplicationController
  def home
      @times = Krawler.new
  end

  def help
      @times = Krawler.new
  end
  
  def about
  end
end
