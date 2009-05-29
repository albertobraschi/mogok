
Factory.define :torrent do |t|
  t.info_hash CryptUtils.sha1_digest(rand.to_s)
  t.raw_info RawInfo.new(:data => CryptUtils.hexencode(rand.to_s))
  t.piece_length 12345
  t.dir_name 'dummy_dir'
  t.mapped_files [ MappedFile.new(:name => 'dummy_file', :length => 123456) ]
  t.size 123456
  t.files_count 1
end
