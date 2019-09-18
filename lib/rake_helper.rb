# All the helper methods provided by this gem
module RakeHelper

  # @param message [String]
  def start(message, *params)
    message = params.empty? ? "START: #{message}" : params_to_message(params, prepend: 'START')
    put_and_log(message: message, type: :info)
  end

  # @param message [String]
  def finish(message, *params)
    message = params.empty? ? "FINISH: #{message}" : params_to_message(params, prepend: 'FINISH')
    put_and_log(message: message, type: :info)
  end

  # @param message [String]
  def failure(message, *params)
    message = params.empty? ? "FAILURE: #{message}" : params_to_message(params, prepend: 'FAILURE')
    put_and_log(message: message, type: :error)
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

  def put_and_log(message:, type:)
    puts "#{Time.now} #{message}"
    Rails.logger.public_send(type, message)
  end

  def params_to_message(params, prepend:)
    sql_hash = params.last
    msg = sql_hash.is_a?(Hash) && sql_hash.key?(:sql) ? sql_hash[:sql] : 'Unidentified Call'
    "#{prepend}: #{msg}"
  end

  def method_missing(method, *args)
    super unless Logger::Severity.constants.include?(method.upcase)
    put_and_log(message: args.first, type: method)
  end

end
