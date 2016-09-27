class QuestionFollowers
  attr_accessor :question_id, :user_id

  def self.all
    questions_followers = QuestionsDatabase.instance.execute("SELECT * FROM questions_followers")
    questions_followers.map { |question_follower_data| QuestionFollowers.new(question_follower_data) }
  end

  def self.followers_for_question_id(question_id)
    query = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        questions_followers AS qf
      JOIN
        users ON qf.user_id = users.id
      WHERE
        qf.question_id = ?
    SQL
    return nil unless query
    query.map { |qd| Users.new(qd) }
  end

  def self.followed_questions_for_user_id(user_id)
    query = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions_followers AS qf
      JOIN
        questions ON qf.question_id = questions.id
      WHERE
        qf.user_id = ?
    SQL
    return nil unless query
    query.map { |qd| Questions.new(qd) }
  end

  def self.most_followed_questions(n)
    query = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        questions_followers AS qf ON questions.id = qf.question_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(qf.user_id)
      LIMIT
        ?
    SQL
    return nil unless query
    query.map { |qd| Questions.new(qd) }
  end

  def initialize(options)
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def create
    raise "Question follower already exists in DB" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id)
      INSERT INTO
        questions_followers (question_id, user_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "Question follow does not exist in DB" unless @id
    QuestionData.instance.execute(<<-SQL, @question_id, @user_id, @id)
      UPDATE
        questions_followers
      SET
        question_id = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end

end
