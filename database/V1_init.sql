DROP SCHEMA public CASCADE;
CREATE SCHEMA IF NOT EXISTS public;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE "user"
(
    id    UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    name  TEXT                                        NOT NULL,
    email TEXT                                        NOT NULL UNIQUE
);

CREATE TABLE label
(
    id   UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    name TEXT                                        NOT NULL UNIQUE
);

CREATE TABLE course
(
    id     UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    stages INTEGER                                     NOT NULL
);

CREATE TABLE content
(
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    path         TEXT                                        NOT NULL,
    title        TEXT                                        NOT NULL,
    mail_content TEXT                                        NOT NULL
);

CREATE TABLE user_labels
(
    id       UUID PRIMARY KEY DEFAULT uuid_generate_v4()   NOT NULL,
    user_id  UUID REFERENCES "user" (id) ON DELETE CASCADE NOT NULL,
    label_id UUID REFERENCES label (id) ON DELETE CASCADE  NOT NULL,
    matching INT2                                          NOT NULL,
    UNIQUE (user_id, label_id)
);

CREATE TABLE user_courses
(
    id        UUID PRIMARY KEY DEFAULT uuid_generate_v4()   NOT NULL,
    user_id   UUID REFERENCES "user" (id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES course (id) ON DELETE CASCADE NOT NULL,
    stage     INTEGER                                       NOT NULL,
    UNIQUE (user_id, course_id)
);

CREATE TABLE content_labels
(
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4()    NOT NULL,
    content_id UUID REFERENCES content (id) ON DELETE CASCADE NOT NULL,
    label_id   UUID REFERENCES label (id) ON DELETE CASCADE   NOT NULL,
    matching   INT2                                           NOT NULL,
    UNIQUE (content_id, label_id)
);

CREATE TABLE course_contents
(
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4()    NOT NULL,
    course_id  UUID REFERENCES course (id) ON DELETE CASCADE  NOT NULL,
    content_id UUID REFERENCES content (id) ON DELETE CASCADE NOT NULL,
    stage      INTEGER                                        NOT NULL,
    UNIQUE (course_id, content_id)
);