class SesMachineController < ActionController::Base

  helper :ses_machine

  before_filter :assign_database

  layout 'ses_machine/application'

  def index
    t = @db['mails']
#    stats_period = (params[:stats_period] || Date.current).to_time.utc
#    stats_from = stats_period.beginning_of_month
#    stats_to = stats_period.end_of_month


    # Mail Totals
    totals_period = (params[:totals_period] || Date.current).to_time.utc
    totals_from = totals_period.beginning_of_month
    totals_to = totals_period.end_of_month

    @count_mails_sent = t.find('date' => {'$gte' => totals_from, '$lt' => totals_to}).count
    @count_mails_bounced = t.find('date' => {'$gte' => totals_from, '$lt' => totals_to}, 'bounce_type' => {'$ne' => SesMachine::Bounce::TYPES[:unknown]}).count
    # TODO: Fix query
    # @count_spam_complaints = t.find('date' => {'$gte' => totals_from, '$lt' => totals_to}, 'bounce_type' => 999).count
    @count_spam_complaints = 0
  end

  def activity
    t = @db['mails']
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
    @messages = t.find(conditions).sort('date', -1).skip((page-1) * per_page).limit(per_page).to_a
    messages_count = t.find(conditions).count
    @bounce_types = SesMachine::Bounce::TYPES.map{|k, v| [k.to_s.humanize, v]}
    @bounce_types.unshift(['All emails', ''])
    @pager = WillPaginate::Collection.new(page, per_page, messages_count)
  end

  def show_message
    t = @db['mails']
    begin
      @mail = t.find_one('_id' => BSON::ObjectId(params[:id]))
      @mail['body'] = Mail.read_from_string(@mail['raw_source']).body
    rescue
      flash[:error] = 'Mail not found'
      redirect_to ses_machine_path
    end
  end

  private
    def assign_database
      @db = SesMachine.database
    end
end
