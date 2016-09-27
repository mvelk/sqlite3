require_relative 'manifest'

class Questions
  attr_accessor :title, :body, :user_id

  def self.all
    questions = QuestionsDatabase.instance.execute('SELECT * FROM questions')
    questions.map { |question_data| Questions.new(question_data) }
  end

  def self.find_by_id(id)
    query = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil if query.empty?
    query.map { |query_data| Questions.new(query_data) }
  end

  def self.most_followed(n)
    QuestionFollowers.most_followed_questions(n)
  end

  def self.find_by_user_id(user_id)
    query = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    return nil unless query
    query.map { |query_data| Questions.new(query_data) }
  end

  def self.most_liked(n)
    QuestionLikes.most_liked_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end


  def followers
    QuestionFollowers.followed_questions_for_question_id(@id)
  end


  def replies
    Replies.find_by_question_id(@id)
  end

  def likers
    QuestionLikes.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLikes.num_likes_for_question_id(@id)
  end

  def create
    raise "Question already exists in DB" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO
        questions (title, body, user_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "Question doesn't exist in DB" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id, @id)
      UPDATE
        questions
      SET
        title = ?, body = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end

  def author
    Users.find_by_id(@user_id)
  end
end
