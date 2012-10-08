class ListsController < ApplicationController
  def index
    @lists = List.all
  end

  def new
    @list = List.new
  end

  def create
    @list = List.new(params[:list])
    if @live.save
      flash[:success] = 'Your list was created successfully'

      redirect_to lists
    else
      render :new
    end
  end
end
