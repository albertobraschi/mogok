require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BgTask do
  include SupportVariables

  before(:each) do
    reload_support_variables

    @bg_task = make_bg_task('my_task', 10)

    class BgTask
      @@executed = false

      def self.executed?
        @@executed
      end

      def self.my_task(params) # this is the method that should be called when task is executed
        @@executed = true
      end
    end
  end

  it 'should be created given a valid yml configuration entry' do
    config = open(File.join(TEST_DATA_DIR, 'bg_tasks.yml')) {|f| YAML.load(f) }
    
    config.each_pair do |task_name, task_properties|
      task_properties.symbolize_keys!

      t = BgTask.new
      t.name = task_name
      t.interval_minutes = task_properties[:interval_minutes]

      task_properties[:params].each_pair do |param_name, param_value|
        t.add_param param_name, param_value
      end
      t.save
    end
    
    t = BgTask.find_by_name('my_task_from_yml')
    t.name.should_not be_nil
    t.interval_minutes.should == 4
    t.params_hash[:param_integer].should == 1
    t.params_hash[:param_array].should == [1, 2]
  end

  it 'should be set to immediate execution when scheduling' do
    @bg_task.next_exec_at = 1.minute.ago
    @bg_task.save
    @bg_task.schedule

    @bg_task.exec_now?.should be_true
  end

  it 'should be scheduled to a future time if execution expired' do
    @bg_task.next_exec_at = 1.minute.ago
    @bg_task.save
    @bg_task.schedule

    @bg_task.next_exec_at.should > Time.now
  end

  it 'should be scheduled to a future time if next execution time is empty' do
    @bg_task.schedule

    @bg_task.next_exec_at.should_not be_nil
    @bg_task.next_exec_at.should > Time.now
  end

  it 'should call a class method with the same name as the task name when executed' do   
    @bg_task.next_exec_at = 1.minute.ago
    @bg_task.save
    @bg_task.exec

    BgTask.executed?.should be_true
  end

  it 'should be scheduled but not execute the class method if next execution time is empty' do
    @bg_task.exec

    @bg_task.next_exec_at.should_not be_nil
    @bg_task.next_exec_at.should > Time.now
    @bg_task.exec_now?.should be_false
    BgTask.executed?.should be_false
  end
end








