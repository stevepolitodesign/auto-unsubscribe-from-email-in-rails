class CreateMailerSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :mailer_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :subscribed
      t.string :mailer

      t.timestamps
    end
  end
end
