class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    redirect = false

    if params[:ratings]
      session[:ratings] = params[:ratings]
    else
      params[:ratings] = session[:ratings]
      redirect = true if session[:ratings]
    end

    if params[:sort]
      session[:sort] = params[:sort]
    else
      params[:sort] = session[:sort]
      redirect = true if session[:sort]
    end

    if redirect
      flash.keep
      redirect_to movies_path(params)
    end

    @all_ratings = Movie.uniq.pluck(:rating)

    if params[:ratings].nil?
       selected_movies = @all_ratings
    else
       selected_movies = params[:ratings].keys
    end

    if params[:sort] == "title"
        @movies = Movie.where('rating in (?)', selected_movies).order(:title) 
        @title_color = "hilite"
        @release_date_color = ""
    elsif params[:sort] == "release_date"
        @movies = Movie.where('rating in (?)', selected_movies).order(:release_date)
        @release_date_color = "hilite"
        @title_color = ""
    else
        @movies = Movie.where('rating in (?)',  selected_movies) 
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
end
