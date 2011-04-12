class SesMachineController < ApplicationController
  unloadable

  unless ENV['RAILS_ENV'].eql?('test')
    include SesMachineAuthHooks
    before_filter :ses_machine_authorize!
  end

  helper :ses_machine
  before_filter :assign_database
  layout 'ses_machine/application'

  def index
    @date = (params[:date] || Date.current).to_date.beginning_of_month
    monthly_stats = @db['monthly_stats'].find().sort([['_id.year', Mongo::DESCENDING], ['_id.month', Mongo::DESCENDING]]).to_a
    @monthly_stats = monthly_stats.map do |e|
      date = Date.new(e['_id']['year'], e['_id']['month'])
      [date.strftime("%B %Y"), date.to_s]
    end
    @stats = @db['monthly_stats'].find_one('_id.year' => @date.year, '_id.month' => @date.month)
    @count_mails_sent = @stats.blank? ? 0 : @stats['value']['total'].to_i
    @count_mails_bounced = @stats.blank? ? 0 : (@count_mails_sent - @stats['value'][SesMachine::Bounce::TYPES[:email_sent].to_s]).to_i
  end

  def activity
    page = params[:page].to_i
    page = 1 if page < 1
    per_page = 25
    @bounce_type = ''
    @q = ''
    conditions = {}
    unless params[:type].blank?
      @bounce_type = params[:type].to_i
      conditions.merge!('bounce_type' => @bounce_type)
    end
    unless params[:q].blank?
      @q = SesMachine::DB.get_keywords(params[:q].to_s.split)
      conditions.merge!('_keywords' =>  {'$all' => @q}) unless @q.blank?
    end
    @messages = @mails.find(conditions).sort('date', -1).skip((page-1) * per_page).limit(per_page).to_a
    messages_count = @mails.find(conditions).count
    @bounce_types = SesMachine::Bounce::TYPES.map{|k, v| [k.to_s.humanize, v]}
    @bounce_types.unshift(['All emails', ''])
    @pager = WillPaginate::Collection.new(page, per_page, messages_count)
  end

  def show_message
    begin
      @mail = @mails.find_one('_id' => BSON::ObjectId(params[:id]))
      @mail['body'] = Mail.read_from_string(@mail['raw_source']).body
    rescue
      flash[:error] = 'Mail not found'
      redirect_to ses_machine_path
    end
  end

  private
    def assign_database
      @db = SesMachine.database
      @mails = @db['mails']
    end
end
