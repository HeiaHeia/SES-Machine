# -*- encoding : utf-8 -*-


Rails.application.routes.draw do
  match "ses_machine" => "ses_machine#index", :as => :ses_machine
  match "ses_machine/activity" => "ses_machine#activity", :as => :ses_machine_activity
  match "ses_machine/message/:id" => "ses_machine#show_message", :as => :ses_machine_message
end
