class MediaScrubber
  attr_accessor :original, :filtered

  def initialize(args)
    @original = args.fetch(:file, nil)
    @filtered = infer_media_type
  end

  def infer_media_type
    return nil unless original.respond_to?(:content_type)
    AtomicCms::Image.new(file: original) if original.content_type.match(/image/)
  end

  def valid?
    return false unless filtered
    filtered.valid?
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
