class ComponentsController < ApplicationController
  def edit
    render text: component(params[:id]).edit_array(!!params[:inline])
  end
end
