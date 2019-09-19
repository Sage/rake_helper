# All the helper methods provided by this gem
module RakeHelper

  # @param message [String]
  def start(message, *params)
    put_and_log(message: "START: #{obtain_message(message, *params)}", type: :info)
  end

  # @param message [String]
  def finish(message, *params)
    put_and_log(message: "FINISH: #{obtain_message(message, *params)}", type: :info)
  end

  # @param message [String]
  def failure(message, *params)
    put_and_log(message: "FAILURE: #{obtain_message(message, *params)}", type: :error)
  end

  # @param sql [String] valid SQL, can include several statements separated by semicolons
  # @param action [Symbol] any valid ActiveRecord::ConnectionAdapters::DatabaseStatements method name
  # @return [Array] the query results
  def run_sql(sql, action: :execute)
    results = []
    sql.strip.split(';').each do |s|
      results << ActiveRecord::Base.connection.public_send(action, s)
    end
    results
  end

  private
  def obtain_message(message, *params)
    params.empty? ? message : params_to_message(params)
  end

  def put_and_log(message:, type:)
    puts "#{Time.now} #{message}"
    Rails.logger.public_send(type, message)
  end

  def params_to_message(params)
    message_from_hash(params.last)
  end

  def message_from_hash(sql_hash)
    sql_hash.is_a?(Hash) && sql_hash[:sql] ? sql_hash[:sql] : 'Unidentified Call'
  end

  def method_missing(method, *args)
    super unless Logger::Severity.constants.include?(method.upcase)
    put_and_log(message: args.first, type: method)
  end

end
