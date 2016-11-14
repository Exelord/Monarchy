class TreeGenerator
  def initialize(model_name, leaves = 2)
    @leaves = leaves
    @model_name = model_name
  end

  def generate(deep, params = {})
    root = new_model(params)
    generate_level([root], 2, deep, params)
    root
  end

  private

  def generate_level(models, level, deep, params)
    models = models.flatten.compact

    children = models.map do |model|
      model.children = new_memo_list(@leaves, params)
    end

    level += 1
    generate_level(children, level, deep, params) unless level == deep
  end

  def new_memo_list(count, params = {})
    FactoryGirl.create_list(@model_name, count, params)
  end

  def new_model(params = {})
    FactoryGirl.create(@model_name, params)
  end
end
