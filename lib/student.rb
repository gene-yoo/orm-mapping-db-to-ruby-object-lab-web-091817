class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    student = self.new
    student.id = row[0]
    student.name = row[1]
    student.grade = row[2]
    student
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = <<-SQL
            SELECT * FROM students
          SQL
    all_students = DB[:conn].execute(sql)
    all_students.map do |student_row|
      self.new_from_db(student_row)
    end
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
            SELECT * FROM students WHERE name = ?
          SQL
    student_row = DB[:conn].execute(sql, name).flatten
    self.new_from_db(student_row)
  end

  def self.count_all_students_in_grade_9
    sql = <<-SQL
            SELECT * FROM students WHERE grade = ?
          SQL
    all_students = DB[:conn].execute(sql, "9")
    all_students.map do |student_row|
      self.new_from_db(student_row)
    end
  end

  def self.students_below_12th_grade
    self.all.select do |student|
      student.grade.to_i < 12
    end
  end

  def self.first_X_students_in_grade_10(num)
    sql = <<-SQL
            SELECT * FROM students WHERE grade = ? LIMIT ?
          SQL
    all_students = DB[:conn].execute(sql, "10", num)
    all_students.map do |student_row|
      self.new_from_db(student_row)
    end
  end

  def self.first_student_in_grade_10
    sql = <<-SQL
            SELECT * FROM students WHERE grade = ? LIMIT ?
          SQL
    first_student = DB[:conn].execute(sql, "10", 1).flatten
    self.new_from_db(first_student)
  end

  def self.all_students_in_grade_X(grade)
    sql = <<-SQL
            SELECT * FROM students WHERE grade = ?
          SQL
    all_students = DB[:conn].execute(sql, grade)
    all_students.map do |student_row|
      self.new_from_db(student_row)
    end
  end

  # ----- GIVEN METHODS BELOW -----
  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
