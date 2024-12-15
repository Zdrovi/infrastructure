DROP SCHEMA public CASCADE;
CREATE SCHEMA IF NOT EXISTS public;

CREATE TABLE "user"
(
    id    SERIAL PRIMARY KEY,
    name  TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
);

CREATE TABLE label
(
    id   SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE course
(
    id     SERIAL PRIMARY KEY,
    stages INTEGER NOT NULL
);

CREATE TABLE content
(
    id           SERIAL PRIMARY KEY,
    path         TEXT NOT NULL,
    title        TEXT NOT NULL,
    mail_content TEXT NOT NULL
);

CREATE TABLE user_labels
(
    id       SERIAL PRIMARY KEY,
    user_id  INTEGER REFERENCES "user" (id) ON DELETE CASCADE,
    label_id INTEGER REFERENCES label (id) ON DELETE CASCADE,
    matching INT2 NOT NULL,
    UNIQUE (user_id, label_id)
);

CREATE TABLE user_courses
(
    id        SERIAL PRIMARY KEY,
    user_id   INTEGER REFERENCES "user" (id) ON DELETE CASCADE,
    course_id INTEGER REFERENCES course (id) ON DELETE CASCADE,
    stage     INTEGER NOT NULL,
    UNIQUE (user_id, course_id)
);

CREATE TABLE content_labels
(
    id         SERIAL PRIMARY KEY,
    content_id INTEGER REFERENCES content (id) ON DELETE CASCADE,
    label_id   INTEGER REFERENCES label (id) ON DELETE CASCADE,
    matching   INT2 NOT NULL,
    UNIQUE (content_id, label_id)
);

CREATE TABLE course_contents
(
    id         SERIAL PRIMARY KEY,
    course_id  INTEGER REFERENCES course (id) ON DELETE CASCADE,
    content_id INTEGER REFERENCES content (id) ON DELETE CASCADE,
    stage      INTEGER NOT NULL,
    UNIQUE (course_id, content_id)
);