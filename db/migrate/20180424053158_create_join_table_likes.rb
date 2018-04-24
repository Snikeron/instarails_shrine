class CreateJoinTableLikes < ActiveRecord::Migration[5.1]
  def change
    create_join_table :users, :photos, table_name: :likes do |t| # table_name is to specify the tablename otherwise Rails default would be 'UserstoPhotos'
      t.index [:user_id, :photo_id]
      t.index [:photo_id, :user_id]
    end
  end
end
