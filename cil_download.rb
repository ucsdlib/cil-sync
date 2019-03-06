# Ruby script to test out parsing the CIL json data
#
require 'open-uri'
require 'json'
require 'fileutils'

data_path = "#{ARGV[1]}/metadata_source"
content_file_path = "#{ARGV[1]}/content_files"
default_file_types = ['jpg', 'zip']
content_url_base = 'https://cildata.crbs.ucsd.edu'
video_base_url = "#{content_url_base}/media/videos/"
image_base_url = "#{content_url_base}/media/images/"

# Read lines into array
results = IO.readlines(ARGV[2])

results.each do |json_record|
  json_record = json_record.strip
  identifier = json_record.split('/').last.split('.')[0]

  FileUtils.copy_file(json_record, "#{data_path}/#{identifier}.json")
  file = File.read(json_record)
  metadata = JSON.parse(file)

  video_format = metadata['CIL_CCDB']['Data_type']['Video']
  content_files = metadata['CIL_CCDB']['CIL']['Image_files']
  if content_files
    content_files.each do |file|
      file_path = file['File_path']
      content_base_url = video_format ? video_base_url : image_base_url
      `curl -s -o #{content_file_path}/#{file_path} #{content_base_url}/#{identifier}/#{file_path}`
    end
  end

  alt_images = metadata['CIL_CCDB']['CIL']['Alternative_image_files']
  if alt_images
    alt_images.each do |file|
        fileName = file['URL_postfix'].split('/').last
        `curl -s -o #{content_file_path}/#{fileName} #{content_url_base}/#{file['URL_postfix']}`
    end
  end
end