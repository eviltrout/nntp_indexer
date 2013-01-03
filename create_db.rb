require 'bundler'
Bundler.require(:default)

require 'jdbc_adapter'

@config = YAML.load(File.open('config.yml'))
#@db = Sequel.postgres(@config['database'])
@db = Sequel.connect('jdbc:postgresql://localhost/database?user=username')

@db.drop_table? :categories
@db.create_table :categories do
  primary_key :id
  String :name
end

@tv = @db[:categories].insert(name: 'TV')
@movies = @db[:categories].insert(name: 'Movies')
@audio = @db[:categories].insert(name: 'Audio')
@books = @db[:categories].insert(name: 'Books')


@db.drop_table? :groups
@db.create_table :groups do
  primary_key :id
  String :name, unique: true, null: false
  Bignum :count
  Bignum :low
  Bignum :high
  Bignum :highest_crawled
  DateTime :crawled_at
  DateTime :locked_at
end

@db.drop_table? :group_categories
@db.create_table :group_categories do
  Integer :group_id, null: false
  Integer :category_id, null: false
  index [:group_id, :category_id], unique: true
end


def create_group(name, *categories)
  group_id = @db[:groups].insert(name: name)
  return if categories.nil?
  categories.each do |c|
    @db[:group_categories].insert(group_id: group_id, category_id: c)
  end
end

create_group('alt.binaries.dvdr', @movies)
create_group('alt.binaries.boneless', @movies)
create_group('alt.binaries.multimedia', @tv, @movies, @audio)
create_group('alt.binaries.movies.divx', @movies)
create_group('alt.binaries.hdtv.x264', @movies, @tv)
create_group('alt.binaries.x264', @movies, @tv)
create_group('alt.binaries.moovee', @movies)
create_group('alt.binaries.teevee', @tv)
create_group('alt.binaries.sounds.mp3.complete_cd', @audio)
create_group('alt.binaries.mp3', @audio)
create_group('alt.binaries.mma', @tv)
create_group('alt.binaries.sounds.mp3.classical', @audio)
create_group('alt.binaries.e-book', @books)
create_group('alt.binaries.tvseries', @tv)
create_group('alt.binaries.ftn', @tv, @audio)
create_group('alt.binaries.cores', @tv, @movies, @audio)
create_group('alt.binaries.country.mp3', @audio)
create_group('alt.binaries.sounds.mp3.1990s', @audio)
create_group('alt.binaries.scary.exe.files', @movies)
create_group('alt.binaries.e-book.technical', @books)
create_group('alt.binaries.x', @movies, @tv, @audio)
create_group('alt.binaries.pro-wrestling', @tv)
create_group('alt.binaries.sounds.lossless', @audio)
create_group('alt.binaries.sounds.mp3.bluegrass', @audio)
create_group('alt.binaries.sounds.radio.bbc', @audio)
create_group('alt.binaries.e-book.flood', @books)
create_group('alt.binaries.multimedia.documentaries', @tv, @movies)
create_group('alt.binaries.sounds.mp3.jazz', @audio)
create_group('alt.binaries.sounds.1960s.mp3', @audio)
create_group('alt.binaries.sounds.1970s.mp3', @audio)
create_group('alt.binaries.sounds.mp3.comedy', @audio)
create_group('alt.binaries.sounds.mp3.2000s', @audio)
create_group('alt.binaries.sounds.mp3.1950s', @audio)
create_group('alt.binaries.sounds.mp3.1970s', @audio)
create_group('alt.binaries.sounds.mp3.1980s', @audio)
create_group('alt.binaries.mp3.bootlegs', @audio)
create_group('alt.binaries.sounds.mp3', @audio)
create_group('alt.binaries.mp3.audiobooks', @audio, @books)
create_group('alt.binaries.sounds.mp3.rap-hiphop.full-albums', @audio)
create_group('alt.binaries.sounds.mp3.full_albums', @audio)
create_group('alt.binaries.multimedia.teen-idols', @audio)
create_group('alt.binaries.sounds.mp3.dance', @audio)
create_group('alt.binaries.warez.uk.mp3', @audio)
create_group('alt.binaries.sounds.mp3.heavy-metal', @audio)
create_group('alt.binaries.multimedia.cartoons', @tv, @movies)
create_group('alt.binaries.multimedia.sports', @tv, @movies)
create_group('alt.binaries.multimedia.anime', @tv, @movies)
create_group('alt.binaries.sounds.lossless.classical', @audio)
create_group('alt.binaries.sounds.mp3.nospam', @audio)
create_group('alt.binaries.multimedia.sitcoms', @tv)
create_group('alt.binaries.sounds.radio.british', @audio)
create_group('alt.binaries.multimedia.comedy.british', @tv, @movies)
create_group('alt.binaries.etc', @tv, @movies, @audio)
create_group('alt.binaries.misc', @tv, @movies, @audio)
create_group('alt.binaries.sounds.mp3.rock', @audio)
create_group('alt.binaries.dc', @movies, @tv)
create_group('alt.binaries.documentaries', @movies, @tv)
create_group('alt.binaries.cd.lossless', @audio)
create_group('alt.binaries.sounds.audiobooks.repost', @audio, @books)
create_group('alt.binaries.highspeed', @movies)
create_group('alt.binaries.bloaf', @tv, @movies, @audio)
create_group('alt.binaries.big', @movies)
create_group('alt.binaries.sounds.mp3.musicals', @audio)
create_group('alt.binaries.sound.mp3', @audio)
create_group('alt.binaries.sounds.mp3.jazz.vocals', @audio)
create_group('alt.binaries.dvd.movies', @movies)
create_group('alt.binaries.ebook', @books)
create_group('alt.binaries.sounds.mp3.disco', @audio)
create_group('alt.binaries.mp3.full_albums', @audio)
create_group('alt.binaries.tv', @tv)
create_group('alt.binaries.sounds.lossless.country', @audio)
create_group('alt.binaries.mom', @tv, @movies, @audio)
create_group('alt.binaries.sounds.lossless.1960s', @audio)
create_group('alt.binaries.sounds.mp3.emo', @audio)
create_group('alt.binaries.classic.tv.shows', @tv)
create_group('alt.binaries.dgma', @movies)
create_group('alt.binaries.sounds.mp3.opera', @audio)
create_group('alt.binaries.music.opera', @audio)
create_group('alt.binaries.sounds.flac.jazz', @audio)
create_group('alt.binaries.multimedia.tv', @tv)
create_group('alt.binaries.sounds.whitburn.pop', @audio)
create_group('alt.binaries.sound.audiobooks', @audio, @books)
create_group('alt.binaries.sounds.mp3.acoustic', @audio)
create_group('alt.binaries.u-4all', @tv, @movies)
create_group('alt.binaries.sounds.mp3.progressive-country', @audio)
create_group('alt.binaries.multimedia.classic-films', @tv, @movies)
create_group('alt.binaries.music.flac', @audio)
create_group('alt.binaries.ghosts', @tv, @movies)
create_group('alt.binaries.town', @tv, @movies)


@db.drop_table? :binaries
@db.create_table :binaries do
  primary_key :id
  String :binary_md5, size: 32, fixed: true, unique: true
  String :name, null: false
  String :poster, null: false
  Integer :total_parts, null: false
  Integer :group_id, null: false
  DateTime :date, null: false
end

@db.drop_table? :binary_parts
@db.create_table :binary_parts do
  Integer :binary_id, null: false
  Integer :part_number, null: false
  String :message_id, null: false
  Bignum :article_id, null: false
  Bignum :size, null: false
  index [:binary_id, :part_number], unique: true
end
