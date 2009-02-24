class Skill < ActiveRecord::Base

  belongs_to :user

  def self.from_linked_in_profile(url)
    # validate as LinkedIn URL
    uri = URI.parse(url)
    unless
        !uri.scheme.nil? and 
        !uri.host.nil? and 
        uri.scheme.match /http/ and 
        uri.host.match /\.?linkedin\.com/
      raise ArgumentError, "Invalid LinkedIn URL"
    end
    
    # fetch the public profile data
    doc = open(url) { |f| Hpricot(f) }
    summary_skills = (doc/'#summary .skills')
    interest_skills = (doc/'#additional-information .interests')
    
    return [] if summary_skills.first.nil? and interest_skills.first.nil?
    
    # parse and compile the skills
    all_skills = []
    [summary_skills, interest_skills].each do |items|
      all_skills |= self.parse_skills items.inner_html
    end
    all_skills
  end
  
  def self.parse_skills(html)
    # break up HTML into logical array items
    skills = html.gsub(/\n/, '').split(/<br>|<br \/>/)
    
    # split up skills which might be a list
    skills.each do |skill|
      multiple = skill.split(/,|\+/)
      if (multiple.size > 1)
        skills.delete(skill)
        multiple.each { |single| skills << single }
      end
    end
    
    # parse out individual skills
    skills.map! do |skill|
      skill.sub(/^\*|--|-|>>|>|&gt;&gt;|&gt;/, '').strip.sub(/[:|\.]$/, '').strip
    end
    skills.delete_if { |skill| skill.empty? }
    
    # replace HTML character entities with their character equivalents
    html_ents = {
      '&quot;' => '"',
      '&apos;' => '\'',
      '&amp;' => '&',
      '&lt;' => '<',
      '&gt;' => '>',
    }
    entities = Regexp.new "(" + html_ents.keys.join('|') + ")"
    skills.map! do |skill|
      skill.match(entities) ? skill.gsub($1, html_ents[$1]) : skill
    end

    # TODO:
    # parse based on sentences? 
    #   http://www.linkedin.com/in/brianascher
  end

end