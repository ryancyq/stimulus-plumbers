# frozen_string_literal: true

require "open3"
require "tempfile"
require "fileutils"

module Capybara
  module Screenshot
    module Diff
      module Drivers
        class RodiffDriver
          PNG_EXTENSION = ".png"
          Image = Struct.new(:width, :height)

          def from_file(path)
            width, height = png_dimensions(path)
            Image.new(width, height)
          end

          def dimension(image)
            [image.width, image.height]
          end

          def width_for(image)
            image.width
          end

          def height_for(image)
            image.height
          end

          def image_area_size(image)
            image.width * image.height
          end

          def same_dimension?(comparison)
            dimension(comparison.new_image) == dimension(comparison.base_image)
          end

          def same_pixels?(comparison)
            Tempfile.create(["rodiff", PNG_EXTENSION]) do |tmp|
              _out, _err, status = run_odiff(
                comparison.base_image_path,
                comparison.new_image_path,
                tmp.path
              )
              status.exitstatus.zero?
            end
          end

          def find_difference_region(comparison)
            diff_path = prepare_diff_path(comparison)
            _out, _err, status = run_odiff(
              comparison.base_image_path,
              comparison.new_image_path,
              diff_path
            )
            return [nil, {}] if status.exitstatus.zero?

            img = comparison.new_image
            region = [0, 0, img.width - 1, img.height - 1]
            [region, { diff_image_path: diff_path }]
          end

          def supports?(feature)
            respond_to?(feature)
          end

          private

          def run_odiff(base_path, new_path, diff_path)
            exe = ::Rodiff::Executable.resolve
            Open3.capture3(exe, base_path, new_path, diff_path)
          end

          def prepare_diff_path(comparison)
            dir = "tmp/screenshots/diffs"
            FileUtils.mkdir_p(dir)
            base_name = File.basename(comparison.base_image_path, PNG_EXTENSION)
            "#{dir}/#{base_name}_diff#{PNG_EXTENSION}"
          end

          def png_dimensions(path)
            File.open(path, "rb") do |f|
              f.seek(16) # skip PNG sig (8) + IHDR length (4) + "IHDR" (4)
              f.read(8).unpack("NN")
            end
          end
        end
      end

      # Register :rodiff as a known driver symbol in capybara-screenshot-diff
      module Utils
        class << self
          prepend(
            Module.new do
              def find_driver_class_for(driver)
                return Drivers::RodiffDriver if driver == :rodiff

                super
              end
            end
          )
        end
      end
    end
  end
end
