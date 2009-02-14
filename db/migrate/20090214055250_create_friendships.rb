class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.integer :user_id, :friend_id
      t.boolean :approved, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :friendships
  end
end
