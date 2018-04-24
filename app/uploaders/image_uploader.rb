require "image_processing/mini_magick"

class ImageUploader < Shrine
    plugin :processing
    plugin :versions, names: [:original, :thumb, :medium]   # enable Shrine to handle a hash of files
    plugin :delete_raw # delete processed files after uploading

    process(:store) do |io, context|
        original = io.download
        pipeline = ImageProcessing::MiniMagick.source(original)
        size_80 = pipeline.resize_to_limit!(80, 80)
        size_300 = pipeline.resize_to_limit!(300, 300)

        original.close! # clears the original out of RAM memory once processed.
        
        { original: io, medium: size_300, thumb: size_80 }
    end
end