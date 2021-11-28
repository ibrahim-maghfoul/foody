class Recipe {
  final String title;
  final String image;
  final String id;
  final String note;
  final String tips;
  final String categorie;
  final String difficulty;
  final List nutritions;
  final List instructions;
  final List ingredients;
  final List methods;
  final int rate;

  Recipe({
    required this.title,
    required this.id,
    required this.image,
    required this.note,
    required this.tips,
    required this.categorie,
    required this.difficulty,
    required this.nutritions,
    required this.instructions,
    required this.ingredients,
    required this.methods,
    required this.rate,
  });
}

class Branch {
  final String title;
  final String id;
  final List<String> courses;
  final List<String> exercices;
  final List<String> exams;
  final List<String> resumes;
  final List<String> videos;
  Branch({
    required this.title,
    required this.id,
    required this.courses,
    required this.exercices,
    required this.exams,
    required this.resumes,
    required this.videos,
  });
}

class Course {
  final String title;
  final String id;
  final List<Branch> branch;
  Course({required this.title, required this.id, required this.branch});
}

class Subject {
  final String title;
  final String id;
  final List<Course> courses;
  Subject({required this.title, required this.id, required this.courses});
}

class Grade {
  final String title;
  final String id;
  final List<Subject> subjects;
  Grade({required this.title, required this.id, required this.subjects});
}

var grade = Grade(
  title: "title",
  id: "id",
  subjects: [
    Subject(
      title: "title",
      id: "id",
      courses: [
        Course(
          title: "title",
          id: "id",
          branch: [
            Branch(
              title: "title",
              id: "id",
              courses: [],
              exercices: [],
              exams: [],
              resumes: [],
              videos: [],
            ),
            Branch(
              title: "title",
              id: "id",
              courses: [],
              exercices: [],
              exams: [],
              resumes: [],
              videos: [],
            )
          ],
        ),
        Course(
          title: "title",
          id: "id",
          branch: [
            Branch(
              title: "title",
              id: "id",
              courses: [],
              exercices: [],
              exams: [],
              resumes: [],
              videos: [],
            ),
            Branch(
              title: "title",
              id: "id",
              courses: [],
              exercices: [],
              exams: [],
              resumes: [],
              videos: [],
            )
          ],
        )
      ],
    ),
    Subject(
      title: "title",
      id: "id",
      courses: [
        Course(
          title: "title",
          id: "id",
          branch: [
            Branch(
              title: "title",
              id: "id",
              courses: [],
              exercices: [],
              exams: [],
              resumes: [],
              videos: [],
            ),
            Branch(
              title: "title",
              id: "id",
              courses: [],
              exercices: [],
              exams: [],
              resumes: [],
              videos: [],
            )
          ],
        ),
        Course(
          title: "title",
          id: "id",
          branch: [
            Branch(
              title: "title",
              id: "id",
              courses: [],
              exercices: [],
              exams: [],
              resumes: [],
              videos: [],
            ),
            Branch(
              title: "title",
              id: "id",
              courses: [],
              exercices: [],
              exams: [],
              resumes: [],
              videos: [],
            )
          ],
        )
      ],
    )
  ],
);
