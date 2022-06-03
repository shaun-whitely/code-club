% This is a mostly working solution that greedily finds pairings between
% students and teachers, based on some criteria in valid_pairing. It currently
% doesn't find all solutions. For example, it won't allocate Wilma to any
% teacher because all the teachers have been used up by the time we get there.

student(alice).
student(bob).
student(fred).
student(wilma).
teacher(lorem).
teacher(ipsum).
teacher(fred).
teacher(wilma).

zen_level(alice, 2).
zen_level(bob, 4).
zen_level(lorem, 3).
zen_level(ipsum, 5).
zen_level(fred, 2).
zen_level(wilma, 2).

valid_pairing(Student, Teacher) :-
  student(Student),
  teacher(Teacher),
  zen_level(Student, StudentZen),
  zen_level(Teacher, TeacherZen),
  StudentZen < TeacherZen.

no_valid_pairings(_, []).

no_valid_pairings(Student, [T|Teachers]) :-
  not(valid_pairing(Student, T)),
  no_valid_pairings(Student, Teachers).

all_students(Students) :- findall(Person, student(Person), Students).
all_teachers(Teachers) :- findall(Person, teacher(Person), Teachers).

% True if Pairings contains mappings from students to teachers, with UnallocatedStudents and
% UnallocatedTeachers unable to be allocated, either because the number of students and teachers
% differ, or because there is no suitable teacher for a given student.
%
% Example:
% ?- all_pairings(Pairings, US, UT).
% Pairings = [alice-lorem, bob-ipsum],
% US = UT, UT = [fred, wilma] ;
% Pairings = [alice-ipsum, fred-lorem],
% US = [bob, wilma],
% UT = [fred, wilma] ;
% false.
all_pairings(Pairings, UnallocatedStudents, UnallocatedTeachers) :-
  all_students(Students),
  all_teachers(Teachers),
  student_teacher_pairings(Students, Teachers, Pairings, UnallocatedStudents, UnallocatedTeachers).

% if everyone has been allocated, there's nothing to do
student_teacher_pairings([], [], [], [], []).
% if there are no teachers, don't allocate anyone
student_teacher_pairings([S|Students], [], [], [S|Students], []).
% if there are no students, don't allocate anyone
student_teacher_pairings([], [T|Teachers], [], [], [T|Teachers]).

student_teacher_pairings([S|Students], Teachers, [S-T|Pairings], UnallocatedS, UnallocatedT) :-
  valid_pairing(S, T),
  select(T, Teachers, Teachers1),
  student_teacher_pairings(Students, Teachers1, Pairings, UnallocatedS, UnallocatedT).

student_teacher_pairings([S|Students], Teachers, Pairings, [S|UnallocatedS], UnallocatedT) :-
  no_valid_pairings(S, Teachers),
  student_teacher_pairings(Students, Teachers, Pairings, UnallocatedS, UnallocatedT).
