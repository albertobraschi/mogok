
Torrent.blueprint do
  info_hash CryptUtils.sha1_digest(rand.to_s)
  raw_info RawInfo.new(:data => CryptUtils.hexencode(rand.to_s))
  piece_length 12345
  dir_name 'dummy_dir'
  mapped_files [ MappedFile.new(:name => 'dummy_file', :size => 123456) ]
  size 123456
  files_count 1
end
