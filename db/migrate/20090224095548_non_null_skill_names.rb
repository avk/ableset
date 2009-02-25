class NonNullSkillNames < ActiveRecord::Migration
  def self.up
    change_column :skills, :name, :string, :null => false
  end

  def self.down
    change_column :skills, :name, :string
  end
end
