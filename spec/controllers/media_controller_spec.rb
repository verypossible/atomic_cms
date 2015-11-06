require "rails_helper"

RSpec.describe AtomicCms::MediaController, type: :controller do
  # Previously the engines guide contained an incorrect example that
  # recommended using the `use_route` option to test an engine's controllers
  # within the dummy application. That recommendation was incorrect and has
  # since been corrected. Instead, you should override the `@routes` variable
  # in the test case with `Foo::Engine.routes`.
  before { @routes = AtomicCms::Engine.routes }

  it "accepts a post request and fails with bad data" do
    scrubber = double("scrubber")
    allow(MediaScrubber).to receive(:new).and_return(scrubber)
    allow(scrubber).to receive(:save).and_return(false)

    post :create, file: double("file")

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "accepts a post with an image" do
    scrubber = double("scrubber", save: true, url: "http://www.google.com")
    expect(MediaScrubber).to receive(:new).and_return(scrubber)

    post :create, file: double("file")

    expect(response).to have_http_status(:created)
    expect(response.body).to include("http://www.google.com")
  end
end
