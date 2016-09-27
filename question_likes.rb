class QuestionLikes
  def self.all
    question_likes = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    question_likes.map { |question_like_data| QuestionLikes.new(question_like_data) }
  end

  def self.likers_for_question_id(question_id)
    query = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        question_likes AS ql ON ql.user_id = users.id
      WHERE
        ql.question_id = ?
    SQL
    return nil unless query
    query.map { |query_data| Users.new(query_data) }
  end

  def self.num_likes_for_question_id(question_id)
    query = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(users.id)
      FROM
        users
      JOIN
        question_likes AS ql ON users.id = ql.user_id
      WHERE
        ql.question_id = ?
    SQL
    return 0 unless query
    query.map(&:values).flatten.reduce(:+)
  end

  def self.liked_questions_for_user_id(user_id)
    query = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_likes AS ql ON questions.id = ql.question_id
      WHERE
        ql.user_id = ?
    SQL
    return nil unless query
    query.map { |query_data| Questions.new(query_data) }
  end

  def self.most_liked_questions(n)
    query = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
      JOIN
        question_likes AS ql ON ql.question_id = questions.id
      GROUP BY
        ql.question_id
      LIMIT
        ?
    SQL
    return nil unless query
    query.map { |qd| Questions.new(qd) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end


  def create
    raise "Question like already exists in the DB" if @id

    # NB:INSERT INTO REQUIRES TABLE NAME AND VARIABLES!!!! DON'T SCREW THIS UP

    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id)
      INSERT INTO
        question_likes (question_id, user_id)
      VALUES
        (?, ?)
    SQL

    @id = QuestionDatabases.instance.last_insert_row_id
  end

  def update
    raise "Question doesn't exist in the DB" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id, @id)
      UPDATE
        question_likes
      SET
        question_id = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end

end
