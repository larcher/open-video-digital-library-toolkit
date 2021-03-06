class FavoritesController < ApplicationController

  def create
    if current_user.nil?
      flash[:error] = "You must be logged in to save a search"
    else
      if v = Video.find_by_id( params[:video_id] ) and
         check_video_viz( v ) and
         ( current_user.favorites.all_videos << v ) and
         current_user.favorites.save and
         current_user.save
        flash[:notice] = "Favorite saved"
      else
        flash[:error] = "Error saving favorite"
      end
    end
    redirect_to :back
  end

  def destroy
    if !current_user
      render_missing
      return
    end

    if params[:id].blank? or params[:id] == "0"
      render_missing
      return
    end

    if v = Video.find( params[:id] )
      current_user.favorites.all_videos.delete v
      flash[:notice] = "Favorite removed"
    end

    redirect_to :back
  end

end
