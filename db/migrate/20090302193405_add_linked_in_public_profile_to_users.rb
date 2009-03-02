class AddLinkedInPublicProfileToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :linked_in_public_profile, :string
  end

  def self.down
    remove_column :users, :linked_in_public_profile
  end
end
