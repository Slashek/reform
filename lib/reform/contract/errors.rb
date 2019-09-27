class Reform::Contract::Errors
  def initialize(*)
    @errors = {}
  end

module Merge
    def merge!(errors, prefix)
      errors.messages.each do |field, msgs|
        unless field.to_sym == :base
          field = (prefix+[field]).join(".").to_sym # TODO: why is that a symbol in Rails?
        end

        msgs.each do |msg|
          next if messages[field] and messages[field].include?(msg)
          add(field, msg)
        end # Forms now contains a plain errors hash. the errors for each item are still available in item.errors.
      end.tap do
        transformed_details = errors.details.transform_keys do |k|
            unless k.to_sym == :base
              k = (prefix+[k]).join(".").to_sym # TODO: why is that a symbol in Rails?
            end
        end
        # liqud expects string to work properly
        transformed_details.each do |k, v|
          v.map! do |h|
            h.each do |err_name, err_val|
              h[err_name] = err_val.to_s if err_val.is_a?(Symbol)
            end
            h
          end
          details[k] = v
        end
      end
    end

    def to_s
      messages.inspect
    end
  end
  include Merge

  def add(field, message)
    @errors[field] ||= []
    @errors[field] << message
  end

  def messages
    @errors
  end

  def empty?
    @errors.empty?
  end

  # needed by Rails form builder.
  def [](name)
    @errors[name] || []
  end
end
