class AddSkillSource < ActiveRecord::Migration
  def self.up
    add_column :skills, :source, :string
  end

  def self.down
    remove_column :skills, :source
  end
end
