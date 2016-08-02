require 'spec_helper'

describe RakeHelper do
  class DummyRake
    include RakeHelper
  end

  subject { DummyRake.new }

  before { allow($stdout).to receive(:write) }

  describe '#success' do
    it 'logs as info with the SUCCESS keyword' do
      expect(Rails.logger).to receive(:info).with(a_string_including('SUCCESS'))
      subject.success('message')
    end
  end

  describe '#failure' do
    it 'logs as error with the FAILURE keyword' do
      expect(Rails.logger).to receive(:error).with(a_string_including('FAILURE'))
      subject.failure('message')
    end
  end

  describe '#run_sql' do
    let(:sql1) { 'SELECT * FROM users;' }
    let(:sql2) { 'SELECT * FROM businesses;' }
    let(:connection) { double('Connection') }

    before { allow(ActiveRecord::Base).to receive(:connection) { connection } }

    it 'executes a single statement' do
      expect(connection).to receive(:execute).once
      subject.run_sql(sql: sql1)
    end

    it 'executes multiple statements' do
      expect(connection).to receive(:execute).twice
      subject.run_sql(sql: sql1 + sql2)
    end

    it 'returns results' do
      sql = "UPDATE users SET name = 'Bob' WHERE id = 4"
      count = 5
      allow(connection).to receive(:update) { count }
      expect(subject.run_sql(sql: sql, action: :update)).to eq([count])
    end
  end

  describe '#method_missing' do
    it 'calls put_and_log for valid severities' do
      Logger::Severity.constants.each do |s|
        severity = s.downcase
        expect{subject.public_send(severity, 'message')}.not_to raise_error
      end
    end

    it 'calls super for invalid severities' do
      expect{subject.invalid('message')}.to raise_error(NoMethodError)
    end
  end
end
