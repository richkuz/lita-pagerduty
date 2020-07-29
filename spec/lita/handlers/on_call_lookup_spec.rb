require 'spec_helper'

describe Lita::Handlers::Pagerduty, lita_handler: true do
  context 'oncall abc' do
    it do
      is_expected.to route_command('pager oncall abc').to(:on_call_lookup)
    end

    it 'works with extra whitespace' do
      is_expected.to route_command('pager   oncall    abc').to(:on_call_lookup)
    end

    it 'schedule not found' do
      expect_any_instance_of(Pagerduty).to receive(:get_schedules).and_raise(Exceptions::SchedulesEmptyList)
      send_command('pager oncall abc')
      expect(replies.last).to eq('No matching schedules found for \'abc\'')
    end

    it 'no one on call' do
      expect_any_instance_of(Pagerduty).to receive(:get_schedules).and_return([{ id: 'abc123' }])
      expect_any_instance_of(Pagerduty).to receive(:get_oncall_user).and_raise(Exceptions::NoOncallUser)
      send_command('pager oncall abc')
      expect(replies.last).to eq('No one is currently on call for abc')
    end

    it 'somebody on call' do
      expect_any_instance_of(Pagerduty).to receive(:get_schedules).and_return([{ id: 'abc123', name: 'abc' }])
      expect_any_instance_of(Pagerduty).to receive(:get_oncall_user).and_return({summary: 'foo', email: 'foo@pagerduty.com'})
      send_command('pager oncall abc')
      expect(replies.last).to eq('foo (foo@pagerduty.com) is currently on call for abc')
    end
  end
end
