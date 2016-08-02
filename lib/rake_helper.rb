# All the helper methods provided by this gem
module RakeHelper

  # @param message [String]
  def success(message)
    put_and_log(message: "SUCCESS: #{message}", type: :info)
  end

  # @param message [String]
  def failure(message)
    put_and_log(message: "FAILURE: #{message}", type: :error)
  end

  # @param sql [String] valid sql, can include several statements separated by semicolons
  # @param action [Symbol] any valid ActiveRecord::ConnectionAdapters::DatabaseStatements method name
  # @return [Array] the query results
  def run_sql(sql:, action: :execute)
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

  def method_missing(method, *args)
    super unless Logger::Severity.constants.include?(method.upcase)
    put_and_log(message: args.first, type: method)
  end

end
