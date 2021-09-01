# Auto Unsubscribe from Emails in Rails

## Step 1: Build Mailers

```
rails g mailer marketing promotion
rails g mailer notification notify
```

```ruby
# test/mailers/previews/marketing_mailer_preview.rb
class MarketingMailerPreview < ActionMailer::Preview

  def promotion
    MarketingMailer.with(
      user: User.first,
      ...
    ).promotion
  end

end
```

```ruby
# test/mailers/previews/notification_mailer_preview.rb
class NotificationMailerPreview < ActionMailer::Preview

  def notify
    NotificationMailer.with(
      user: User.first
      ...
    ).notify
  end

end
```

## Step 2: Build Model to Save Email Preferences

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

  # A list of mailers a user will be able to subscribe/unsubscribe from
  # The class value must match the name of a Mailer class
  MAILERS = OpenStruct.new(
    items: [
      {
        class: "MarketingMailer",
        name: "Marketing Emails",
        description: "Updates on promotions and sales."
      },
      {
        class: "NotificationMailer",
        name: "Notification Emails",
        description: "Notifications from the website."
      }
    ]
  ).freeze

  validates :subscribed, inclusion: [true, false], allow_nil: true
  validates :mailer, presence: true

  # Constrain the mailer to only include certain values.
  validates :mailer, inclusion: MAILERS.items.map{ |item|  item[:class] }

  # This will prevent a user from having duplicate or conflicting preferences
  validates :user, uniqueness: { scope: :mailer }

  # @mailer_subscription.details
  # => [{:class => "MarketingMailer", :name => "Marketing Emails", :description => "Updates on promotions and sales."}]
  def details
    MailerSubscription::MAILERS.items.select {|item| item[:class] == mailer }
  end
  
  # @mailer_subscription.name
  # => "Marketing Emails"
  def name
    details[0][:name]
  end

  # @mailer_subscription.name
  # => "Updates on promotions and sales."
  def description
    details[0][:description]
  end

  # @mailer_subscription.name
  # => "Subscribe to"
  def action
    subscribed? ? "Unsubscribe from" : "Subscribe to"
  end

  # @mailer_subscription.name
  # => "Subscribe to Marketing Emails"
  def call_to_action
    "#{action} #{name}"
  end

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

## Step 3: Allow User to Automatically Unsubscribe from a Mailer

```
rails g controller mailer_subscription_unsubcribes
```

```ruby
# config/routes.rb
Rails.application.routes.draw do
  ...
  resources :mailer_subscription_unsubcribes, only: [:show, :update]
end
```

```ruby
# app/controllers/mailer_subscription_unsubcribes_controller.rb
class MailerSubscriptionUnsubcribesController < ApplicationController
  before_action :set_user, only: [:show, :update]
  before_action :set_mailer_subscription, only: [:show, :update]

  # Automatically unsubscribe a user from a mailer when they visit this route
  def show
    if @mailer_subscription.update(subscribed: false)
      @message = "You've successfully unsubscribed from this email."
    else
      @message = "There was an error"
    end
  end

  # Allow a user to resubscribe
  def update
    if @mailer_subscription.toggle!(:subscribed)
      redirect_to root_path, notice: "Subscription updated."
    else
      redirect_to root_path, notice: "There was an error."
    end
  end
  
  private

    # Find the user through their GlobalID in the URL
    # This makes the URLs difficult to discover 
    def set_user
      @user = GlobalID::Locator.locate_signed params[:id]
      @message =  "There was an error" if @user.nil?
    end

    # Either find an existing MailerSubscription record
    # or initialize a new one
    def set_mailer_subscription
      @mailer_subscription = MailerSubscription.find_or_initialize_by(
        user: @user,
        mailer: params[:mailer]
      )
    end

end
```

```html+erb
<%# app/views/mailer_subscription_unsubcribes/show.html.erb %>
<h1>Unsubscribe</h1>
<p><%= @message %></p>

<%= button_to @mailer_subscription.call_to_action, mailer_subscription_unsubcribe_path, method: :patch, params: { mailer: params[:mailer] } if @mailer_subscription.present? %>
```

## Step 4: Build Page for USer to Update Their Email Preferences

```
rails g controller mailer_subscriptions 
```

```ruby
# config/routes.rb
Rails.application.routes.draw do
  ...
  resources :mailer_subscription_unsubcribes, only: [:show, :update]
  resources :mailer_subscriptions, only: [:index, :create, :update]
end
```

```ruby
# app/controllers/mailer_subscriptions_controller.rb
class MailerSubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mailer_subscription, only: :update
  before_action :handle_unauthorized, only: :update

  # We can't call @user.mailer_subscriptions because they may not have any 
  # Instead we load all possible MailerSubscription combinations
  def index
    @mailer_subscriptions = MailerSubscription::MAILERS.items.map do |item|
      MailerSubscription.find_or_initialize_by(mailer: item[:class], user: current_user)
    end
  end

  def create
    @mailer_subscription = current_user.mailer_subscriptions.build(mailer_subscription_params)
    @mailer_subscription.subscribed = true
    if @mailer_subscription.save
      redirect_to mailer_subscriptions_path, notice: "Preferences updated."
    else
      redirect_to mailer_subscriptions_path, alter: "#{@mailer_subscription.errors.full_messages.to_sentence}"
    end
  end

  def update
    handle_unauthorized
    if @mailer_subscription.toggle!(:subscribed)
      redirect_to mailer_subscriptions_path, notice: "Preferences updated."
    else
      redirect_to mailer_subscriptions_path, alter: "#{@mailer_subscription.errors.full_messages.to_sentence}"
    end
  end

  private

    def mailer_subscription_params
      params.require(:mailer_subscription).permit(:mailer)
    end

    def set_mailer_subscription
      @mailer_subscription = MailerSubscription.find(params[:id])
    end

    # This prevents a user from subscribing/unsubscribing another user from mailers 
    def handle_unauthorized
      redirect_to root_path, status: :unauthorized, notice: "Unauthorized." and return if current_user != @mailer_subscription.user
    end
end
```

```html+erb
<%# app/views/mailer_subscriptions/index.html.erb %>
<ul style="list-style:none;">
  <%= render @mailer_subscriptions %>
</ul>
```

```html+erb
<%# app/views/mailer_subscriptions/_mailer_subscription.html.erb %>
<% if mailer_subscription.new_record? %>
  <li style="margin-bottom: 16px;">
    <p><%= mailer_subscription.description %></p>
    <%= button_to mailer_subscriptions_path, params: { mailer_subscription:  mailer_subscription.attributes } do %>
      <%= mailer_subscription.call_to_action %>
    <% end %>
    <hr/>
  </li>
<% else %>
  <li style="margin-bottom: 16px;">
    <p><%= mailer_subscription.description %></p>
    <%= button_to mailer_subscription_path(mailer_subscription), method: :put do %>
      <%= mailer_subscription.call_to_action %>
    <% end %>
    <hr/>
  </li>
<% end %>
```

## Step 5: Add Unsubscribe Link to Mailer and Prevent Delivery if User has Unsubscribed

```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  before_action :set_user
  before_action :set_unsubscribe_url, if: :should_unsubscribe?
  before_action :set_mailer_subscriptions_url, if: :should_unsubscribe?

  # Conditionally prevent the mailer from being sent
  # If the user is not subscribed to that mailer
  after_action :prevent_delivery_if_recipient_opted_out, if: :should_unsubscribe?

  default from: 'from@example.com'
  layout 'mailer'

  private
  
  # Will set mail.perform_deliveries to true or false
  def prevent_delivery_if_recipient_opted_out
    mail.perform_deliveries = @user.subscribed_to_mailer? self.class.to_s
  end

  def set_user
    @user = params[:user]
  end
  
  # We call to_sgid.to_s to ensure the the URL is unique and does not contain the user's id
  # Otherwise a bad actor could unsubscribe any user from a mailer

  # Calling self.class will return the name of the mailer
  def set_unsubscribe_url
    @unsubscribe_url = mailer_subscription_unsubcribe_url(@user.to_sgid.to_s, mailer: self.class)
  end  

  def set_mailer_subscriptions_url
    @mailer_subscriptions_url = mailer_subscriptions_url
  end

  # This ensures we've passed a user to the mailer
  def should_unsubscribe?
    @user.present? && @user.respond_to?(:subscribed_to_mailer?)
  end
end
```

```html+erb
<%# app/views/layouts/mailer.html.erb %>
<!DOCTYPE html>
<html>
  ...
  <body>
    <%= yield %>
    <%= render "shared/mailers/unsubscribe_links" if @unsubscribe_url.present? %>
  </body>
</html>
```

```txt+erb
<%# app/views/layouts/mailer.txt.erb %>
<%= yield %>
<%= render "shared/mailers/unsubscribe_links" if @unsubscribe_url.present? %>
```
