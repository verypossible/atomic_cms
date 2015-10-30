require 'json'

class <%= @scaffold.controller_name %>Controller < ApplicationController
  def show
    # Standard find by ID
    <%= "@#{@scaffold.model_file_name}" %> = <%= @scaffold.model_name %>.find(params[:id])
    # Find by path
    <%= "@#{@scaffold.model_file_name}" %> = <%= @scaffold.model_name %>.find_by_path(request.path)
    if <%= "@#{@scaffold.model_file_name}" %>
      render :show
    else
      render file: "#{Rails.root}/public/404.html", status: :not_found
      Rails.logger.error "404 - Page #{request.path} cannot be found."
    end
  end
end
