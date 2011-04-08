# encoding: utf-8

Array.class_eval do
  def paginate(page=1, per_page=25, total_entries=25)
    WillPaginate::Collection.new(page, per_page, total_entries)
  end
end
