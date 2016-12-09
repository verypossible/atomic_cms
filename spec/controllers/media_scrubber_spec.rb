require 'rails_helper'

RSpec.describe MediaScrubber do
  let(:path) { File.expand_path('../../uploads', __FILE__) }
  let(:image) { File.open("#{path}/cat.jpg") }
  let(:video) { File.open("#{path}/small.mp4") }

  it 'takes a file as an argument' do
    something = double('some_document')
    MediaScrubber.new(file: something)
  end

  context '#infer_media_type' do
    it 'returns an Image if the file type is an image' do
      allow(image).to receive(:content_type).and_return('image/jpg')
      m = MediaScrubber.new(file: image)
      expect(m.infer_media_type.class).to be(AtomicCms::Image)
    end

    it 'returns a Video if the file type is a video' do
      allow(video).to receive(:content_type).and_return('video/mp4')
      m = MediaScrubber.new(file: video)
      expect(m.infer_media_type.class).to be(AtomicCms::Video)
    end

    it 'returns nil if not supported' do
      something_else = double('some_document', content_type: 'rando')
      m = MediaScrubber.new(file: something_else)
      expect(m.infer_media_type).to be_nil
    end
  end

  context '#valid?' do
    before(:each) do
      allow(image).to receive(:content_type).and_return('image/jpg')
    end

    it 'returns false if not filtered' do
      m = MediaScrubber.new(file: image)
      m.filtered = nil

      expect(m.valid?).to be(false)
    end

    it 'returns true if underlying Object is filtered' do
      m = MediaScrubber.new(file: image)
      m.filtered = spy('underlying_asset')
      allow(m.filtered).to receive(:valid?).and_return(true)

      expect(m.valid?).to be(true)

      expect(m.filtered).to have_received(:valid?)
    end

    it 'returns false if underlying Object is not filtered' do
      m = MediaScrubber.new(file: image)
      m.filtered = spy('underlying_asset')
      allow(m.filtered).to receive(:valid?).and_return(false)

      expect(m.valid?).to be(false)
    end
  end

  context '#save' do
    before(:each) do
      allow(image).to receive(:content_type).and_return('image/jpg')
    end

    it 'returns false if not valid' do
      m = MediaScrubber.new(file: image)
      m.filtered = nil
      expect(m.save).to be(false)
    end

    it 'passes the save call onto the underlying Object' do
      m = MediaScrubber.new(file: image)
      m.filtered = spy('underlying_asset')
      allow(m.filtered).to receive(:save)

      m.save

      expect(m.filtered).to have_received(:save)
    end
  end
end
