module AtomicCms
  class MediaController < ApplicationController
    def create
      asset = MediaScrubber.new(file: media_params)
      if asset.save
        render json: { url: asset.url }.to_json, status: :created
      else
        render json: {}.to_json, status: :unprocessable_entity
      end
    end

    private

    def media_params
      params.require(:file)
    end
  end
end
