# frozen_string_literal: true
require 'yaml'
require 'action_view'
require 'action_view/helpers'

class TitleParser
  attr_reader :raw_title

  DELINEATORS = %w[, - – to of].freeze

  class << self
    %i[roles levels specialities acronyms].each do |sym|
      define_method sym do
        config[sym.to_s]
      end
    end

    private

    def config
      @config ||= YAML.load_file(config_path)
    end

    def config_path
      File.expand_path './titles.yml', __dir__
    end
  end

  PEOPLE_MANAGER_ROLES = [
    'Manager',
    'Director',
    'Vice President'
  ]

  def initialize(raw_title)
    raise ArgumentError unless raw_title

    @raw_title = raw_title
  end

  def to_s
    return raw_title unless role

    string = role.dup

    if department
      if role == 'Officer'
        string.prepend("#{department} ")
      else
        string << ", #{department}"
      end
    end

    string.prepend("#{level} ") if level
    string << " - #{speciality}" if speciality

    string
  end

  def to_h
    %i[
      level role department speciality raw_title to_s title_normalized people_manager?
    ].map { |m| [m, public_send(m)] }.to_h
  end

  def people_manager?
    PEOPLE_MANAGER_ROLES.include?(role)
  end

  def level
    return if role == 'Chief of Staff'
    return role if TitleParser.levels.include?(role)


    match = title_normalized.match(/\A(#{Regexp.union(TitleParser.levels)})|(#{Regexp.union(TitleParser.levels)}) #{Regexp.union(TitleParser.roles)}\z|([i\d]+)\z/i)
    return unless match

    level = (match[1] || match[2] || match[3]).titleize 
    #level = level + " #{role}" if people_manager?
    level
  end

  def department
    match = title_normalized.match(/\A#{level} ?(.+?) #{role}|\A#{level} ?#{role}, (.+)|(.+?) #{level} ?#{role}( [i\d]})?\z/i)
    (match[1] || match[2] || match[3]).titleize if match
  end

  def role
    return 'Chief of Staff' if /\Achief of staff/i.match?(raw_title)

    roles = Regexp.union(TitleParser.roles)
    match = title_normalized.match(/\A(?:#{Regexp.union(TitleParser.levels)} )?(#{roles})|(#{roles})(?:, #{speciality})?\z/)
    (match[1] || match[2]).titleize if match
  end

  def speciality
    match = @raw_title.match(/(#{Regexp.union(TitleParser.specialities)})\z|- (.+)\z|\((.+?)\)\z/)
    (match[1] || match[2] || match[3]).titleize if match
  end

  def inspect
    "#<DHubberDiff::TitleParser title=\"#{self}\">"
  end

  def eql?(other)
    other.is_a?(self.class) && to_s == other.to_s
  end
  alias == eql?

  def hash
    to_s.hash
  end

  def self.all
    @all ||= User.all.map(&:title_parsed).uniq.sort_by(&:to_s)
  end

  def title_normalized
    @title = @raw_title.gsub(/(?=\b|\s)(#{Regexp.union(TitleParser.acronyms.keys)})(?=\b|\s|\z)/, TitleParser.acronyms)
    @title = @title.gsub(Regexp.union(DELINEATORS.map { |d| /(\b|\s)#{d}(\b|\s)/ }), ', ')
    @title = @title.gsub(/ \((.+?)\)\z/, ', \\1')
    @title = @title.gsub(/Chief,  Staff/i, 'Chief of Staff')
    @title = @title.gsub(/,? ?\b#{Regexp.union(TitleParser.specialities)}\z/i, '')
    @title.squeeze(' ').downcase
  end
end