require 'spec_helper'

describe RakeHelper do
  class DummyRake
    include RakeHelper
  end

  subject { DummyRake.new }

  let(:message) { 'message' }
  let(:params) do
    ['1234', { sql: query }]
  end
  let(:incorrect_params) { [:foo, :bar] }
  let(:query) { 'SELECT something FROM table' }

  before { allow($stdout).to receive(:write) }

  describe '#start' do
    it 'logs as info with the START keyword' do
      expect(Rails).to receive_message_chain(:logger, :info).with(a_string_including('START'))
      subject.start(message)
    end

    it 'allows for the Hash message format' do
      expect(Rails).to receive_message_chain(:logger, :info).with(a_string_including("START: #{query}"))
      subject.start(message, *params)
    end

    it 'with incorrect params logs, but marks the call as unidentified' do
      expect(Rails).to receive_message_chain(:logger, :info).with(a_string_including("START: Unidentified Call"))
      subject.start(message, *incorrect_params)
    end
  end

  describe '#finish' do
    it 'logs as info with the FINISH keyword' do
      expect(Rails).to receive_message_chain(:logger, :info).with(a_string_including('FINISH'))
      subject.finish(message)
    end

    it 'allows for the Hash message format' do
      expect(Rails).to receive_message_chain(:logger, :info).with(a_string_including("FINISH: #{query}"))
      subject.finish(message, *params)
    end

    it 'with incorrect params logs, but marks the call as unidentified' do
      expect(Rails).to receive_message_chain(:logger, :info).with(a_string_including("START: Unidentified Call"))
      subject.start(message, *incorrect_params)
    end
  end

  describe '#failure' do
    it 'logs as error with the FAILURE keyword' do
      expect(Rails).to receive_message_chain(:logger, :error).with(a_string_including('FAILURE'))
      subject.failure(message)
    end

    it 'allows for the Hash message format' do
      expect(Rails).to receive_message_chain(:logger, :error).with(a_string_including("FAILURE: #{query}"))
      subject.failure(message, *params)
    end

    it 'with incorrect params logs, but marks the call as unidentified' do
      expect(Rails).to receive_message_chain(:logger, :error).with(a_string_including("FAILURE: Unidentified Call"))
      subject.failure(message, *incorrect_params)
    end
  end

  describe '#run_sql' do
    let(:sql1) { 'SELECT * FROM users;' }
    let(:sql2) { 'SELECT * FROM businesses;' }
    let(:connection) { double('Connection') }

    before { allow(ActiveRecord::Base).to receive(:connection) { connection } }

    it 'executes a single statement' do
      expect(connection).to receive(:execute).once
      subject.run_sql(sql1)
    end

    it 'executes multiple statements' do
      expect(connection).to receive(:execute).twice
      subject.run_sql(sql1 + sql2)
    end

    it 'returns results' do
      sql = "UPDATE users SET name = 'Bob' WHERE id = 4"
      count = 5
      allow(connection).to receive(:update) { count }
      expect(subject.run_sql(sql, action: :update)).to eq([count])
    end
  end

  describe '#method_missing' do
    it 'calls put_and_log for valid severities' do
      Logger::Severity.constants.each do |s|
        severity = s.downcase
        expect(subject).to receive(:put_and_log).with(message: message, type: severity)
        subject.public_send(severity, message)
      end
    end

    it 'calls super for invalid severities' do
      expect{subject.invalid(message)}.to raise_error(NoMethodError)
    end
  end
end
