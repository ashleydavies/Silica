require 'opal'
require 'opal-jquery'

desc 'Build application'
task :build do
  Opal.append_path './silica'
  Opal.append_path './app'
  File.binwrite 'silica.js', Opal::Builder.build('silica').to_s
  File.binwrite 'app.js',    Opal::Builder.build('app'   ).to_s
end
