class MediaScrubber
  attr_accessor :original, :filtered, :errors

  def initialize(args)
    @original = args.fetch(:file, nil)
    @filtered = infer_media_type
  end

  def infer_media_type
    return nil unless original.respond_to?(:content_type)
    params = { file: original }
    return AtomicCms::Image.new(params) if original.content_type =~ /image/
    AtomicCms::Video.new(params) if original.content_type =~ /video/
  end

  def valid?
    return false unless filtered
    return true if filtered.valid?
    @errors = filtered.errors
    false
  end

  def save
    return false unless valid?
    filtered.save
  end

  def url
    return nil unless filtered
    filtered.file.url
  end
end
