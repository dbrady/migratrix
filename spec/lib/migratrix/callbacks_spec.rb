class TestCallbackMigration < Migratrix::Migration
  set_extraction :test, :no_op
  set_transform :test, :no_op
  set_load :test, :no_op
end

class MethodCallbackMigration < TestCallbackMigration
  extend_extraction :test, {}
  extend_transform :test, {}
  extend_load :test, {}

  attr_reader :before_migrate_called, :after_migrate_called, :around_migrate_called
  attr_reader :before_extract_called, :after_extract_called, :around_extract_called
  attr_reader :before_transform_called, :after_transform_called, :around_transform_called
  attr_reader :before_load_called, :after_load_called, :around_load_called

  before_migrate :before_migrate_method
  after_migrate :after_migrate_method
  around_migrate :around_migrate_method

  def before_migrate_method
    @before_migrate_called = true
  end

  def after_migrate_method
    @after_migrate_called = true
  end

  def around_migrate_method
    yield
    @around_migrate_called = true
  end

  before_extract :before_extract_method
  after_extract :after_extract_method
  around_extract :around_extract_method

  def before_extract_method
    @before_extract_called = true
  end

  def after_extract_method
    @after_extract_called = true
  end

  def around_extract_method
    yield
    @around_extract_called = true
  end

  before_transform :before_transform_method
  after_transform :after_transform_method
  around_transform :around_transform_method

  def before_transform_method
    @before_transform_called = true
  end

  def after_transform_method
    @after_transform_called = true
  end

  def around_transform_method
    yield
    @around_transform_called = true
  end

  before_load :before_load_method
  after_load :after_load_method
  around_load :around_load_method

  def before_load_method
    @before_load_called = true
  end

  def after_load_method
    @after_load_called = true
  end

  def around_load_method
    yield
    @around_load_called = true
  end
end

class BlockCallbackMigration < TestCallbackMigration
  attr_reader :before_migrate_called, :after_migrate_called
  attr_reader :before_extract_called, :after_extract_called
  attr_reader :before_transform_called, :after_transform_called
  attr_reader :before_load_called, :after_load_called

  before_migrate do
    @before_migrate_called = true
  end

  after_migrate do
    @after_migrate_called = true
  end

  before_extract do
    @before_extract_called = true
  end

  after_extract do
    @after_extract_called = true
  end

  before_transform do
    @before_transform_called = true
  end

  after_transform do
    @after_transform_called = true
  end

  before_load do
    @before_load_called = true
  end

  after_load do
    @after_load_called = true
  end
end

describe "callbacks" do
  describe "sanity check cat" do
    it "is sanity checked" do
      TestCallbackMigration.should_not be_nil
      MethodCallbackMigration.should_not be_nil
    end
  end

  describe "with named callback methods" do
    let(:migration) { MethodCallbackMigration.new }
    before do
      migration.migrate
    end

    it "calls migrate callbacks" do
      migration.before_migrate_called.should be_true
      migration.after_migrate_called.should be_true
      migration.around_migrate_called.should be_true
    end

    it "calls extract callbacks" do
      migration.before_extract_called.should be_true
      migration.after_extract_called.should be_true
      migration.around_extract_called.should be_true
    end

    it "calls transform callbacks" do
      migration.before_transform_called.should be_true
      migration.after_transform_called.should be_true
      migration.around_transform_called.should be_true
    end

    it "calls load callbacks" do
      migration.before_load_called.should be_true
      migration.after_load_called.should be_true
      migration.around_load_called.should be_true
    end
  end

  describe "with block callbacks" do
    let(:migration) { BlockCallbackMigration.new }
    before do
      migration.migrate
    end

    it "calls migrate callbacks" do
      migration.before_migrate_called.should be_true
      migration.after_migrate_called.should be_true
    end

    it "calls extract callbacks" do
      migration.before_extract_called.should be_true
      migration.after_extract_called.should be_true
    end

    it "calls transform callbacks" do
      migration.before_transform_called.should be_true
      migration.after_transform_called.should be_true
    end

    it "calls load callbacks" do
      migration.before_load_called.should be_true
      migration.after_load_called.should be_true
    end
  end
end


