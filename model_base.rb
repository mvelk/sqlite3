class ModelBase

  def self.find_by_id(id, table_name)
    table_name.delete!(";")
    query = QuestionsDatabase.instance.execute("SELECT * FROM #{table_name} WHERE id = #{id}")
    return nil unless query
    query.map { |query_data| self.new(query_data) }
  end

  def self.find_where(table_name, options)
    table_name.delete!(";")
    where_conditions_string = options.map { |key, value| value.is_a?(String) ? "#{key} = '#{value}'" : "#{key} = #{value}" }.join("AND")
    query_string_base = "SELECT * FROM #{table_name}"
    query_string = query_string_base + " WHERE " + where_conditions_string
    p query_string
    query = QuestionsDatabase.instance.execute(query_string)
    return nil unless query
    query.map { |query_data| self.new(query_data) }
  end

end
