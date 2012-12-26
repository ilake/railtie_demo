namespace "railtie_demo" do
  desc "an railtie_demo task"
  task "railtie_demo_task" => :environment do
    p RailtieDemo::Railtie.config.railtie_demo.railtie_demo_config
  end
end
