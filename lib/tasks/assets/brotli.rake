require "brotli"

namespace :assets do
  desc "Create .br versions of assets"
  task brotli: :environment do
    brotli_types = /\.(?:css|html|js|otf|svg|txt|xml)$/.freeze

    public_assets = File.join(
      Rails.root,
      "public",
      Rails.application.config.assets.prefix)

    Dir["#{public_assets}/**/*"].each do |f|
      next unless f.match? brotli_types

      mtime = File.mtime(f)
      br_file = "#{f}.br"
      next if File.exist?(br_file) && File.mtime(br_file) >= mtime

      File.write(br_file, Brotli.deflate(File.read(f)), mode: "wb")

      File.utime(mtime, mtime, br_file)
    end
  end

  # Hook into existing assets:precompile task
  Rake::Task["assets:precompile"].enhance do
    Rake::Task["assets:brotli"].invoke
  end
end
