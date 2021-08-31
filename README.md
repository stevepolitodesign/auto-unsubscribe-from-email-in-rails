# Auto Unsubscribe from Emails in Rails

## Step 1: Build MailerSubscription Model

```
rails g model mailer_subscription user:references subscribed:boolean mailer:string
```

```ruby
class CreateMailerSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :mailer_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :subscribed
      # Prevent null values
      t.string :mailer, null: false

      t.timestamps
    end

    # Add a unique index to prevent duplicate values
    add_index(:mailer_subscriptions, [:user_id, :mailer], unique: true)
  end
end
```

```
rails db:migrate
```

```ruby
# app/models/mailer_subscription.rb
class MailerSubscription < ApplicationRecord
  belongs_to :user

  # This will prevent a user from having duplicate or conflicting preferences
  validates :user, uniqueness: { scope: :mailer }
  validates :subscribed, inclusion: [true, false], allow_nil: true
end 
```

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_many :mailer_subscriptions, dependent: :destroy

  # @user.subscribed_to_mailer? "MarketingMailer"
  # => true
  def subscribed_to_mailer?(mailer)
    MailerSubscription.find_by(
      user: self,
      mailer: mailer,
      subscribed: true
    ).present?
  end
end
```