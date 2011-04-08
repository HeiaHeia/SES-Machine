namespace :ses_machine do
  namespace :db do

    desc 'Update daily statistics'
    task :update_daily_stats => :environment do
      response = SesMachine::DB.update_daily_stats
      puts "DAILY STATS (#{response['timeMillis']}ms) - #{response['ok'] ? 'Success' : 'Failure'}"
    end

    desc 'Create database indices'
    task :create_indices => :environment do
      t = SesMachine.database['mails']
      t.ensure_index([['message_id', Mongo::ASCENDING]])
      t.ensure_index([['bounce_type', Mongo::ASCENDING]])
      t.ensure_index([['_keywords', Mongo::ASCENDING]])
      t.ensure_index([['date', Mongo::DESCENDING]])
    end
  end
end
