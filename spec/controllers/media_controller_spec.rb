require 'rails_helper'

RSpec.describe AtomicCms::MediaController, type: :controller do
  it 'accepts a post request and fails with bad data' do
    scrubber = double('scrubber')
    allow(MediaScrubber).to receive(:new).and_return(scrubber)
    allow(scrubber).to receive(:save).and_return(false)

    post :create, use_route: :atomic_cms, file: double('file')

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'accepts a post with an image' do
    scrubber = double('scrubber', save: true, url: 'http://www.google.com')
    expect(MediaScrubber).to receive(:new).and_return(scrubber)

    post :create, use_route: :atomic_cms, file: double('file')

    expect(response).to have_http_status(:created)
    expect(response.body).to include('http://www.google.com')
  end
end
