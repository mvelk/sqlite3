class Replies
  attr_accessor :question_id, :user_id, :reply_id, :body

  def self.all
    replyies = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    replyies.map { |reply| Replies.new(reply) }
  end

  def self.find_by_user_id(user_id)
    query = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil unless query
    query.map { |query_data| Replies.new(query_data) }
  end

  def self.find_by_question_id(question_id)
    query = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil unless query
    query.map { |query_data| Replies.new(query_data) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
    @reply_id = options['reply_id']
    @body = options['body']
  end

  def author
    Users.find_by_id(@user_id)
  end

  def question
    Questions.find_by_id(@question_id)
  end

  def parent_reply
    Replies.find_by_id(@reply_id)
  end

  def child_replies
    Replies.find_by_reply_id(@id)
  end

  def create
    raise "Reply already exists" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id, @reply_id, @body)
      INSERT INTO
        replies (question_id, user_id, reply_id, body)
      VALUES
        (?, ?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "Reply doesn't exist in DB" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id, @reply_id, @body, @id)
      UPDATE
        replies
      SET
        question_id = ?, user_id = ?, reply_id = ?, body = ?
      WHERE
        id = ?
    SQL
  end
end
