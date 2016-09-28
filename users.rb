class Users < ModelBase
  attr_accessor :fname, :lname
  @@table_name = 'users'
  def self.all
    everybody = QuestionsDatabase.instance.execute("SELECT * FROM users")
    everybody.map { |user_data| Users.new(user_data) }
  end

  def self.find_by_name(fname, lname)
    query = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ?, lname = ?
    SQL
    return nil unless query
    query.map { |query_data| Users.new(query_data) }
  end

  def self.find_by_id(id)
    super(id, @@table_name)
  end

  # def self.find_by_id(id)
  #   query = QuestionsDatabase.instance.execute(<<-SQL, id)
  #     SELECT
  #       *
  #     FROM
  #       users
  #     WHERE
  #       id = ?
  #   SQL
  #   return nil unless query
  #   query.map { |query_data| Users.new(query_data) }
  # end

  def self.find_where(options)
    super(@@table_name, options)
  end

  def self.find_by_reply_id(id)
    query = QuestionsDatabase.instance.execute(<<-SQL, reply_id)
      SELECT
        *
      FROM
        users
      WHERE
        reply_id = ?
    SQL
    return nil unless query
    query.map { |query_data| Users.new(query_data) }
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise "User already exists in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "User doesn't exist in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end

  def average_karma
    query = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        CAST(COUNT(ql.user_id) AS FLOAT) / COUNT(DISTINCT(questions.id))
      FROM
        questions
      LEFT OUTER JOIN
        question_likes AS ql ON ql.question_id = questions.id
      WHERE
        questions.user_id = ?
    SQL
    return nil unless query
    return query.map(&:values).flatten.reduce(:+)

  end

  def liked_questions
    QuestionFollowers.liked_questions_for_user_id(@id)
  end

  def followed_question
    QuestionFollowers.followed_questions_for_user_id(@id)
  end

  def authored_questions
    Questions.find_by_user_id(@id)
  end

  def authored_replies
    Replies.find_by_user_id(@id)
  end
end
