require 'boot'

require 'open-uri'
require 'hpricot'

require 'set'

class GosuGamersExtractor

  attr_reader :replays_pool

  def initialize
    @replays_pool = []
  end

  def fetch_new
    @last_replay_ids ||= [].to_set
    page_replay_ids = [].to_set

    @replays_pool = []

    open('http://www.gosugamers.net/starcraft2/replays/') do |gg|
      doc = Hpricot(gg)
      (doc/'tr.wide_middle').reverse.each do |replay_node|
        id = extract_id(replay_node)

        page_replay_ids << id
        next if @last_replay_ids.include? id  # to avoid duplicates from previous fetch

        p1_name, p1_race = extract_player(replay_node/'td:nth(1)')
        p2_name, p2_race = extract_player(replay_node/'td:nth(2)')

        map = extract_map(replay_node)

        replay = GosuGamersReplay.new(id, p1_name, p1_race, p2_name, p2_race, map)

        @replays_pool << replay
      end
    end

    @last_replay_ids = page_replay_ids
    @replays_pool
  end

  private

  def extract_id(node)
    dirty_id, = /\/(\d+)$/.match(node[:id]).captures
    dirty_id.to_i
  end

  def extract_player(node)
    name = (node/'a').first.inner_text.strip
    race = (node/'img').first[:title].strip
    [name, race_sign(race)]
  end

  def race_sign(race)
    case "#{race}".downcase
    when "terran", "t"
      'T'
    when "protoss", "p"
      'P'
    when "zerg", "z"
      'Z'
    end
  end

  def extract_map(node)
    (node/'td:nth(3)').first.inner_text.strip
  end

end

class GosuGamersReplay

  attr_reader :id

  def initialize(id, p1_name, p1_race, p2_name, p2_race, map)
    @id = id
    @p1_name, @p1_race = p1_name, p1_race
    @p2_name, @p2_race = p2_name, p2_race
    @map = map
  end

  def to_tweet
    "#{@p1_name} (#{@p1_race}) vs. #{@p2_name} (#{@p2_race}) @ #{@map} #{permalink}"
  end

  private

  def permalink
    "http://www.gosugamers.net/starcraft2/replays/#{@id}"
  end

end

# extractor = GosuGamersExtractor.new
# extractor.fetch_new
# extractor.replays_pool.each do |r|
#   puts r.to_tweet
# end

