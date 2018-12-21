# Ruby script to test out parsing the CIL json data and dump to csv
#
# For now, we're concatenating the property hierarchy with colons
# So CIL: { "Image Files" [ "Mime_type": "application/zip" will be CIL:Image Files:Mime_type "application/zip"
require 'open-uri'
require 'json'
require 'byebug'
require 'csv'

# Hackety hacks, don't talk back
class CilCSV
  attr_reader :cil_data, :data_path, :processed_path, :harvest_dir

  def initialize(harvest_dir)
    @cil_data = {}
    @data_path = "#{harvest_dir}/metadata_source"
    @processed_path = "#{harvest_dir}/metadata_processed"
  end

  def start
    load_data
    CSV.open("#{processed_path}/cil.csv", 'wb', headers: true, write_headers: true, col_sep: '|') do |csv|
      csv << ['Identifier'] + cil_header_row
      cil_value_rows.each { |row| csv << row }
    end
  end

  def load_data
    json_files.each do |file|
      cil_data[file] = parse(file)
    end
  end

  def cil_header_row
    @cil_header_row ||= cil_data.values.map(&:keys).reduce(&:+).uniq
  end

  def cil_value_rows
    values = []
    cil_data.each_pair do |k, v|
      values << [k] + cil_header_row.map { |h| v.fetch(h, '') }
    end
    values
  end

  def json_files
    # list all source json files
    Dir.entries(data_path) - [".", ".."]
  end

  def parse(cil_file)
    file = File.read(data_path + '/' + cil_file)
    metadata = JSON.parse(file)
    flatten_hash(metadata)
  end

  def flatten_hash(hash)
    hash.each_with_object({}) do |(k, v), h|
      if v.is_a? Hash
        flatten_hash(v).map do |h_k, h_v|
          h["#{k}.#{h_k}".to_sym] = h_v
        end
      else
        h[k] = String(v)
      end
    end
  end
end

CilCSV.new(ARGV[1]).start
